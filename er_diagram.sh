#!/usr/bin/env bash
set -euo pipefail

# Colors
CYAN=$'\033[0;36m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
PURPLE=$'\033[0;35m'
BOLD=$'\033[1m'
NC=$'\033[0m'

clear

cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                    SEMI-EXAM ER DIAGRAM                                          ║
║                                   PostgreSQL Database Schema                                      ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

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
     │ FK: prodid ──────┼─────────────│ compname         │                      │
     └──────────────────┘             │ compnynme        │                      │
                                      │ FK: prodid ──────┼──────────────────────┤
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
     │ FK: custid ──────┼───┐         └──────────────────┘
     └──────────────────┘   │
              ▲             │
              │             │
              │ 1:N (make)  │
              │             │
     ┌──────────────────┐   │         ┌──────────────────┐
     │     Invoice      │   │         │     customer     │
     │──────────────────│   │         │──────────────────│
     │ PK: invocid      │   └────────►│ PK: custid       │
     │ unitprce         │             │ usrname          │
     │ prcttotl         │  1:N (pay)  │ email            │
     │ quantity         │────────────►│ passwrd          │
     │ date             │             │ phone            │
     │ plprod           │             │ regdate          │
     │ pay              │             │ adress           │
     └──────────────────┘             │ FK: invocid      │
                                      └──────────────────┘

╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                    RELATIONSHIP SUMMARY                                          ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  #  │ Relationship Name │  From Entity    │  To Entity      │ Cardinality │ Foreign Key         ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  1  │ has               │  product        │  Stock          │    1:N      │ Stock.prodid        ║
║  2  │ authorize         │  product        │  Autoriz_staff  │    1:N      │ Autoriz_staff.prodid║
║  3  │ authorize         │  Autoriz_staff  │  Delivery       │    1:N      │ Delivery.staffid    ║
║  4  │ autoriz staff     │  product        │  Delivery       │    1:N      │ Delivery.prodid     ║
║  5  │ pay               │  Invoice        │  customer       │    1:N      │ customer.invocid    ║
║  6  │ make              │  customer       │  order          │    1:N      │ order.custid        ║
║  7  │ contains          │  order          │  Delivery       │    1:N      │ Delivery.orderid    ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                   FOREIGN KEY REFERENCES                                         ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                                  ║
║   Stock.prodid            ────────────────────────────────────►  product.prodid                  ║
║                                                                                                  ║
║   Autoriz_staff.prodid    ────────────────────────────────────►  product.prodid                  ║
║                                                                                                  ║
║   Delivery.staffid        ────────────────────────────────────►  Autoriz_staff.id                ║
║                                                                                                  ║
║   Delivery.orderid        ────────────────────────────────────►  order.orderid                   ║
║                                                                                                  ║
║   Delivery.prodid         ────────────────────────────────────►  product.prodid                  ║
║                                                                                                  ║
║   customer.invocid        ────────────────────────────────────►  Invoice.invocid                 ║
║                                                                                                  ║
║   order.custid            ────────────────────────────────────►  customer.custid                 ║
║                                                                                                  ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                      TABLE SUMMARY                                               ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  Table           │ Primary Key │ Foreign Keys                    │ Attributes                   ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  product         │ prodid      │ -                               │ price, prodcatgry, prodname, ║
║                  │             │                                 │ image, proddescr             ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  Invoice         │ invocid     │ -                               │ unitprce, prcttotl, quantity,║
║                  │             │                                 │ date, plprod, pay            ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  customer        │ custid      │ invocid -> Invoice              │ usrname, email, passwrd,     ║
║                  │             │                                 │ phone, regdate, adress       ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  order           │ orderid     │ custid -> customer              │ payment, orderdate, quantity,║
║                  │             │                                 │ prodid, prodname, deliveid   ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  Stock           │ stockid     │ prodid -> product               │ quantty, date                ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  Autoriz_staff   │ id          │ prodid -> product               │ name, adress, compname,      ║
║                  │             │                                 │ compnynme                    ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║  Delivery        │ delvid      │ staffid -> Autoriz_staff        │ date, custname, quantity     ║
║                  │             │ orderid -> order                │                              ║
║                  │             │ prodid -> product               │                              ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════╝

EOF

echo ""
echo "${GREEN}ER Diagram displayed successfully!${NC}"
echo ""
