#!/usr/bin/env bash
set -euo pipefail

# Always run from the script directory so compose + .env resolve correctly.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load .env so connection details match docker-compose.
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

# Set variables with fallback to empty strings
POSTGRES_USER="${POSTGRES_USER:-}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
POSTGRES_DB="${POSTGRES_DB:-}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

export POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB POSTGRES_PORT

# Colors & Styles
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
PURPLE=$'\033[0;35m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m' # No Color

# --- Logging Helpers ---
log_info() {
  printf "${BLUE}INFO:  %s${NC}\n" "$*"
}

log_success() {
  printf "${GREEN}OK:    %s${NC}\n" "$*"
}

log_warn() {
  printf "${YELLOW}WARN:  %s${NC}\n" "$*"
}

log_error() {
  printf "${RED}ERROR: %s${NC}\n" "$*" >&2
}

die() {
  log_error "$*"
  exit 1
}

# --- Checks ---
require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

ensure_config() {
  [[ -f .env ]] || die "Missing .env. Create one from .env.example."
  [[ -n "${POSTGRES_USER}" ]] || die "POSTGRES_USER is not set in .env"
  [[ -n "${POSTGRES_PASSWORD}" ]] || die "POSTGRES_PASSWORD is not set in .env"
  [[ -n "${POSTGRES_DB}" ]] || die "POSTGRES_DB is not set in .env"
  [[ "${POSTGRES_PORT}" =~ ^[0-9]+$ ]] || die "POSTGRES_PORT must be a number (got: ${POSTGRES_PORT})"
}

# --- Usage ---
usage() {
  cat <<EOF
${BOLD}PostgreSQL Manager - Semi Exam${NC}

${YELLOW}Usage:${NC} $0 {start|open|close|status|run}

  ${CYAN}start${NC}   Start PostgreSQL database
  ${CYAN}open${NC}    Open psql shell
  ${CYAN}close${NC}   Stop PostgreSQL database
  ${CYAN}status${NC}  Show database health/status
  ${CYAN}run${NC}     Run a SQL file (usage: $0 run <file.sql>)

${YELLOW}Notes:${NC}
  - Ensure .env exists (copy from .env.example).
  - 'stop' is an alias for 'close'.
EOF
}

db_container_running() {
  docker compose ps --services --filter "status=running" | grep -q '^db$'
}

ADMIN_PSQL_USER=""

sql_quote_literal() {
  local value="${1:-}"
  value=${value//\'/\'\'}
  printf "'%s'" "$value"
}

example_postgres_user() {
  [[ -f .env.example ]] || return 1
  local line
  while IFS= read -r line; do
    [[ $line == POSTGRES_USER=* ]] || continue
    echo "${line#POSTGRES_USER=}"
    return 0
  done < .env.example
  return 1
}

detect_admin_psql_user() {
  local candidates=("$POSTGRES_USER" "postgres")
  local example_user=""
  if example_user="$(example_postgres_user 2>/dev/null)"; then
    if [[ -n "$example_user" && "$example_user" != "$POSTGRES_USER" && "$example_user" != "postgres" ]]; then
      candidates+=("$example_user")
    fi
  fi

  local user ok rc
  for user in "${candidates[@]}"; do
    set +e
    ok="$(docker compose exec -T -u postgres db psql -v ON_ERROR_STOP=1 -U "$user" -d postgres -tA -c \
      "SELECT CASE WHEN rolsuper OR (rolcreaterole AND rolcreatedb) THEN 1 ELSE 0 END FROM pg_roles WHERE rolname = current_user;" 2>/dev/null)"
    rc=$?
    set -e
    if [[ $rc -eq 0 && "$ok" == "1" ]]; then
      ADMIN_PSQL_USER="$user"
      return 0
    fi
  done
  return 1
}

psql_admin() {
  local database="${1:-postgres}"
  shift || true

  if [[ -z "${ADMIN_PSQL_USER}" ]]; then
    if ! detect_admin_psql_user; then
      die "Could not find an admin role to manage the existing data volume. If you changed POSTGRES_USER/POSTGRES_PASSWORD after the volume was created, run: docker compose down -v && ./db.sh start"
    fi
  fi

  docker compose exec -T -u postgres -e PGPASSWORD="$POSTGRES_PASSWORD" db \
    psql -v ON_ERROR_STOP=1 -U "$ADMIN_PSQL_USER" -d "$database" "$@"
}

wait_for_db() {
  printf "Waiting for PostgreSQL to accept connections..."
  for _ in {1..30}; do
    if docker compose exec -T -u postgres db pg_isready -U postgres -d postgres >/dev/null 2>&1; then
      printf "\r${GREEN}OK:    PostgreSQL is accepting connections.${NC}   \n"
      return 0
    fi
    sleep 1
  done
  echo ""
  die "PostgreSQL did not become ready in time."
}

ensure_role_exists() {
  printf "Ensuring role '${BOLD}%s${NC}' exists...\n" "$POSTGRES_USER"
  set +e
  psql_admin postgres -v username="$POSTGRES_USER" -v password="$POSTGRES_PASSWORD" <<'SQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'username') THEN
    EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', :'username', :'password');
  ELSE
    EXECUTE format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'username', :'password');
  END IF;
END$$;
SQL
  rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    log_error "Could not create/update role '$POSTGRES_USER'."
    log_info "If you changed .env after the volume was created, run: docker compose down -v && ./db.sh start"
    exit 1
  fi
}

ensure_database_exists() {
  printf "Ensuring database '${BOLD}%s${NC}' exists...\n" "$POSTGRES_DB"
  local db_lit owner_lit
  db_lit="$(sql_quote_literal "$POSTGRES_DB")"
  owner_lit="$(sql_quote_literal "$POSTGRES_USER")"
  set +e
  psql_admin postgres <<SQL
SELECT format('CREATE DATABASE %I OWNER %I', $db_lit, $owner_lit)
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = $db_lit);
\gexec

SELECT format('ALTER DATABASE %I OWNER TO %I', $db_lit, $owner_lit)
FROM pg_database d
JOIN pg_roles r ON r.oid = d.datdba
WHERE d.datname = $db_lit AND r.rolname <> ${owner_lit}::name;
\gexec
SQL
  rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    log_error "Could not create/find database '$POSTGRES_DB'."
    log_info "If you changed .env after the volume was created, run: docker compose down -v && ./db.sh start"
    exit 1
  fi
}

# --- Commands ---

start_db() {
  require_cmd docker
  ensure_config

  # Check if port is already in use by another container
  if docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -q ":${POSTGRES_PORT}->5432" && ! docker compose ps --services --filter "status=running" | grep -q '^db$'; then
    log_error "Port $POSTGRES_PORT is already in use by another container."
    log_info "Stop it first or change POSTGRES_PORT in .env"
    exit 1
  fi

  printf "${BLUE}Starting PostgreSQL 17...${NC}\n"
  printf "   User: ${BOLD}%s${NC}\n" "$POSTGRES_USER"
  printf "   DB:   ${BOLD}%s${NC}\n" "$POSTGRES_DB"
  printf "   Port: ${BOLD}%s${NC}\n" "$POSTGRES_PORT"

  set +e
  docker compose up -d --wait 2>/dev/null
  up_rc=$?
  set -e
  if [[ $up_rc -ne 0 ]]; then
    docker compose up -d
  fi

  wait_for_db
  ensure_role_exists
  ensure_database_exists

  log_success "PostgreSQL is running."
  echo ""
  printf "   ${CYAN}Connect:${NC} ${BOLD}psql postgresql://%s:%s@localhost:%s/%s${NC}\n" "$POSTGRES_USER" "$POSTGRES_PASSWORD" "$POSTGRES_PORT" "$POSTGRES_DB"
}

open_psql() {
  require_cmd docker
  ensure_config

  if ! db_container_running; then
    log_error "Database container is not running."
    log_info "Start it first with: $0 start"
    exit 1
  fi

  wait_for_db
  ensure_role_exists
  ensure_database_exists

  printf "${CYAN}Opening psql shell...${NC}\n"
  docker compose exec -e PGPASSWORD="$POSTGRES_PASSWORD" db \
    psql -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB"
}

run_sql() {
  require_cmd docker
  ensure_config

  local sql_file="${1:-}"
  if [[ -z "$sql_file" ]]; then
    die "Usage: $0 run <file.sql>"
  fi

  if [[ ! -f "$sql_file" ]]; then
    die "SQL file not found: $sql_file"
  fi

  if ! db_container_running; then
    log_error "Database container is not running."
    log_info "Start it first with: $0 start"
    exit 1
  fi

  printf "${CYAN}Running SQL file: %s${NC}\n" "$sql_file"
  docker compose exec -T -e PGPASSWORD="$POSTGRES_PASSWORD" db \
    psql -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$sql_file"
}

close_db() {
  require_cmd docker
  printf "${YELLOW}Stopping PostgreSQL database...${NC}\n"
  docker compose down
  log_success "PostgreSQL database stopped."
}

show_status() {
  require_cmd docker
  printf "${PURPLE}Database status:${NC}\n"
  docker compose ps
}

# --- Main ---
case "${1:-}" in
  start)
    start_db
    ;;
  open)
    open_psql
    ;;
  close)
    close_db
    ;;
  status)
    show_status
    ;;
  stop)
    close_db
    ;;
  run)
    run_sql "${2:-}"
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
esac
