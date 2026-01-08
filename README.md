# Semi-Exam Database Project

A PostgreSQL database implementation based on an ER (Entity-Relationship) Diagram for a product ordering and delivery system.

## Overview

This project implements a complete database schema with 7 tables and 7 relationships, running on PostgreSQL 17 via Docker.

## ER Diagram

```
                                      ┌──────────────────┐
                                      │     product      │
                                      │──────────────────│
                                      │ PK: prodid       │
                                      │ price            │
                                      │ prodcatgry       │
                                      │ prodname         │
                                      │ image            │
                                      │ proddescr        │
                                      └────────┬─────────┘
                                               │
              ┌────────────────────────────────┼────────────────────────────────┐
              │                                │                                │
              │ 1:N (has)                      │ 1:N (authorize)                │ 1:N (autoriz staff)
              ▼                                ▼                                │
     ┌──────────────────┐             ┌──────────────────┐                      │
     │      Stock       │             │  Autoriz_staff   │                      │
     │──────────────────│             │──────────────────│                      │
     │ PK: stockid      │             │ PK: id           │                      │
     │ quantty          │             │ name             │                      │
     │ date             │             │ adress           │                      │
     │ FK: prodid       │             │ compname         │                      │
     └──────────────────┘             │ compnynme        │                      │
                                      │ FK: prodid       │                      │
                                      └────────┬─────────┘                      │
                                               │                                │
                                               │ 1:N (authorize)                │
                                               ▼                                │
     ┌──────────────────┐  1:N        ┌──────────────────┐                      │
     │      order       │─────────────│     Delivery     │◄─────────────────────┘
     │──────────────────│ (contains)  │──────────────────│
     │ PK: orderid      │             │ PK: delvid       │
     │ payment          │             │ date             │
     │ orderdate        │             │ custname         │
     │ quantity         │             │ quantity         │
     │ prodid           │             │ FK: staffid      │
     │ prodname         │             │ FK: orderid      │
     │ deliveid         │             │ FK: prodid       │
     │ FK: custid       │             └──────────────────┘
     └──────────────────┘
              ▲
              │
              │ 1:N (make)
              │
     ┌──────────────────┐             ┌──────────────────┐
     │     Invoice      │             │     customer     │
     │──────────────────│             │──────────────────│
     │ PK: invocid      │  1:N (pay)  │ PK: custid       │
     │ unitprce         │────────────►│ usrname          │
     │ prcttotl         │             │ email            │
     │ quantity         │             │ passwrd          │
     │ date             │             │ phone            │
     │ plprod           │             │ regdate          │
     │ pay              │             │ adress           │
     └──────────────────┘             │ FK: invocid      │
                                      └──────────────────┘
```

## Tables

| #   | Table           | Primary Key | Description              |
| --- | --------------- | ----------- | ------------------------ |
| 1   | `product`       | prodid      | Product catalog          |
| 2   | `Invoice`       | invocid     | Invoice records          |
| 3   | `customer`      | custid      | Customer information     |
| 4   | `order`         | orderid     | Customer orders          |
| 5   | `Stock`         | stockid     | Inventory/stock levels   |
| 6   | `Autoriz_staff` | id          | Authorized staff members |
| 7   | `Delivery`      | delvid      | Delivery records         |

## Relationships

| #   | Name          | From          | To            | Cardinality | Foreign Key            |
| --- | ------------- | ------------- | ------------- | ----------- | ---------------------- |
| 1   | has           | product       | Stock         | 1:N         | `Stock.prodid`         |
| 2   | authorize     | product       | Autoriz_staff | 1:N         | `Autoriz_staff.prodid` |
| 3   | authorize     | Autoriz_staff | Delivery      | 1:N         | `Delivery.staffid`     |
| 4   | autoriz staff | product       | Delivery      | 1:N         | `Delivery.prodid`      |
| 5   | pay           | Invoice       | customer      | 1:N         | `customer.invocid`     |
| 6   | make          | customer      | order         | 1:N         | `order.custid`         |
| 7   | contains      | order         | Delivery      | 1:N         | `Delivery.orderid`     |

## Prerequisites

- Docker
- Docker Compose
- Bash shell

## Quick Start

### 1. Setup Environment

```bash
# Copy environment template (optional - .env is already configured)
cp .env.example .env
```

### 2. Start Database

```bash
./db.sh start
```

### 3. Create Schema and Insert Data

```bash
./db.sh run schema.sql
./db.sh run seed.sql
```

### 4. View Data

```bash
./db.sh run queries.sql
```

### 5. Display ER Diagram

```bash
./er_diagram.sh
```

## Available Commands

| Command                  | Description                         |
| ------------------------ | ----------------------------------- |
| `./db.sh start`          | Start PostgreSQL database container |
| `./db.sh open`           | Open interactive psql shell         |
| `./db.sh run <file.sql>` | Execute a SQL file                  |
| `./db.sh status`         | Show database container status      |
| `./db.sh close`          | Stop and remove database container  |
| `./er_diagram.sh`        | Display ASCII ER diagram            |

## Project Files

```
semi-exam/
├── .env                 # Database credentials
├── .env.example         # Environment template
├── docker-compose.yml   # PostgreSQL 17 container config
├── db.sh                # Database management script
├── schema.sql           # CREATE TABLE statements
├── seed.sql             # Sample data (3 records per table)
├── queries.sql          # SELECT queries with JOINs
├── er_diagram.sh        # ASCII ER diagram display
└── README.md            # This file
```

## Database Connection

```
Host:     localhost
Port:     5433
Database: semi_exam_db
User:     app_user
Password: secret123
```

### Connection String

```
postgresql://app_user:secret123@localhost:5433/semi_exam_db
```

### Connect with psql

```bash
# Using db.sh
./db.sh open

# Direct connection
psql postgresql://app_user:secret123@localhost:5433/semi_exam_db
```

## Sample Data

Each table contains 3 sample records:

### Products

| ID  | Name                | Category    | Price   |
| --- | ------------------- | ----------- | ------- |
| 1   | Wireless Headphones | Electronics | $299.99 |
| 2   | Smartphone Pro      | Electronics | $599.99 |
| 3   | Phone Case Premium  | Accessories | $49.99  |

### Customers

| ID  | Username   | Email                |
| --- | ---------- | -------------------- |
| 1   | john_doe   | john.doe@email.com   |
| 2   | jane_smith | jane.smith@email.com |
| 3   | bob_wilson | bob.wilson@email.com |

## SQL Examples

### Select all products with stock

```sql
SELECT p.prodname, p.price, s.quantty
FROM product p
JOIN Stock s ON p.prodid = s.prodid;
```

### Get customer orders with delivery info

```sql
SELECT c.usrname, o.orderdate, d.date AS delivery_date
FROM customer c
JOIN "order" o ON c.custid = o.custid
JOIN Delivery d ON o.orderid = d.orderid;
```

### View staff authorized for products

```sql
SELECT p.prodname, a.name AS staff_name, a.compname
FROM product p
JOIN Autoriz_staff a ON p.prodid = a.prodid;
```

## Cleanup

```bash
# Stop database
./db.sh close

# Remove all data (including volume)
docker compose down -v
```
