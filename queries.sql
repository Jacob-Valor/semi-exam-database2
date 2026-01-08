-- ============================================
-- SEMI-EXAM ER DIAGRAM QUERIES
-- Display all table data and relationships
-- ============================================

\pset border 2
\pset format aligned

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════════╗'
\echo '║                         SEMI-EXAM DATABASE RESULTS                           ║'
\echo '╚══════════════════════════════════════════════════════════════════════════════╝'
\echo ''

-- ============================================
-- TABLE 1: product
-- ============================================
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  TABLE: product                                                              │'
\echo '│  Relationships: has -> Stock, authorize -> Autoriz_staff, -> Delivery       │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    prodid AS "ID",
    prodname AS "Product Name",
    prodcatgry AS "Category",
    price AS "Price",
    image AS "Image",
    LEFT(proddescr, 40) || '...' AS "Description"
FROM product;

\echo ''

-- ============================================
-- TABLE 2: Invoice
-- ============================================
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  TABLE: Invoice                                                              │'
\echo '│  Relationship: pay -> customer (1:N)                                         │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    invocid AS "ID",
    unitprce AS "Unit Price",
    quantity AS "Qty",
    prcttotl AS "Total",
    date AS "Date",
    plprod AS "Product",
    pay AS "Payment"
FROM Invoice;

\echo ''

-- ============================================
-- TABLE 3: customer
-- ============================================
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  TABLE: customer                                                             │'
\echo '│  Relationships: Invoice -> customer (pay), customer -> order (make)          │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    custid AS "ID",
    usrname AS "Username",
    email AS "Email",
    phone AS "Phone",
    regdate AS "Reg Date",
    invocid AS "Invoice FK"
FROM customer;

\echo ''

-- ============================================
-- TABLE 4: order
-- ============================================
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  TABLE: order                                                                │'
\echo '│  Relationships: customer -> order (make), order -> Delivery (contains)       │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    orderid AS "ID",
    payment AS "Payment",
    orderdate AS "Order Date",
    quantity AS "Qty",
    prodid AS "Prod ID",
    prodname AS "Product",
    deliveid AS "Deliv ID",
    custid AS "Cust FK"
FROM "order";

\echo ''

-- ============================================
-- TABLE 5: Stock
-- ============================================
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  TABLE: Stock                                                                │'
\echo '│  Relationship: product -> Stock (has) 1:N                                    │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    stockid AS "ID",
    quantty AS "Quantity",
    date AS "Date",
    prodid AS "Product FK"
FROM Stock;

\echo ''

-- ============================================
-- TABLE 6: Autoriz_staff
-- ============================================
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  TABLE: Autoriz_staff                                                        │'
\echo '│  Relationships: product -> Autoriz_staff, Autoriz_staff -> Delivery          │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    id AS "ID",
    name AS "Name",
    compname AS "Company",
    prodid AS "Product FK"
FROM Autoriz_staff;

\echo ''

-- ============================================
-- TABLE 7: Delivery
-- ============================================
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  TABLE: Delivery                                                             │'
\echo '│  FK: staffid -> Autoriz_staff, orderid -> order, prodid -> product           │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    delvid AS "ID",
    date AS "Date",
    custname AS "Customer",
    quantity AS "Qty",
    staffid AS "Staff FK",
    orderid AS "Order FK",
    prodid AS "Prod FK"
FROM Delivery;

\echo ''

-- ============================================
-- RELATIONSHIP QUERIES (JOINs)
-- ============================================
\echo '╔══════════════════════════════════════════════════════════════════════════════╗'
\echo '║                         RELATIONSHIP DEMONSTRATIONS                          ║'
\echo '╚══════════════════════════════════════════════════════════════════════════════╝'
\echo ''

-- Relationship 1: product -> Stock (has)
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  RELATIONSHIP 1: product -> Stock (has) 1:N                                  │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    p.prodid AS "Prod ID",
    p.prodname AS "Product",
    s.stockid AS "Stock ID",
    s.quantty AS "Quantity",
    s.date AS "Stock Date"
FROM product p
JOIN Stock s ON p.prodid = s.prodid;

\echo ''

-- Relationship 2: Invoice -> customer (pay)
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  RELATIONSHIP 2: Invoice -> customer (pay) 1:N                               │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    i.invocid AS "Inv ID",
    i.prcttotl AS "Total",
    i.pay AS "Payment",
    c.custid AS "Cust ID",
    c.usrname AS "Customer"
FROM Invoice i
JOIN customer c ON i.invocid = c.invocid;

\echo ''

-- Relationship 3: product -> Autoriz_staff (authorize)
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  RELATIONSHIP 3: product -> Autoriz_staff (authorize) 1:N                    │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    p.prodid AS "Prod ID",
    p.prodname AS "Product",
    a.id AS "Staff ID",
    a.name AS "Staff Name",
    a.compname AS "Company"
FROM product p
JOIN Autoriz_staff a ON p.prodid = a.prodid;

\echo ''

-- Relationship 4: Autoriz_staff -> Delivery (authorize)
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  RELATIONSHIP 4: Autoriz_staff -> Delivery (authorize) 1:N                   │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    a.id AS "Staff ID",
    a.name AS "Staff",
    d.delvid AS "Deliv ID",
    d.date AS "Deliv Date",
    d.custname AS "Customer"
FROM Autoriz_staff a
JOIN Delivery d ON a.id = d.staffid;

\echo ''

-- Relationship 5: customer -> order (make)
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  RELATIONSHIP 5: customer -> order (make) 1:N                                │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    c.custid AS "Cust ID",
    c.usrname AS "Customer",
    o.orderid AS "Order ID",
    o.orderdate AS "Order Date",
    o.payment AS "Payment"
FROM customer c
JOIN "order" o ON c.custid = o.custid;

\echo ''

-- Relationship 6: order -> Delivery (contains)
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  RELATIONSHIP 6: order -> Delivery (contains) 1:N                            │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    o.orderid AS "Order ID",
    o.prodname AS "Product",
    d.delvid AS "Deliv ID",
    d.date AS "Deliv Date",
    d.quantity AS "Qty"
FROM "order" o
JOIN Delivery d ON o.orderid = d.orderid;

\echo ''

-- Relationship 7: product -> Delivery (autoriz staff)
\echo '┌──────────────────────────────────────────────────────────────────────────────┐'
\echo '│  RELATIONSHIP 7: product -> Delivery (autoriz staff) 1:N                     │'
\echo '└──────────────────────────────────────────────────────────────────────────────┘'
SELECT 
    p.prodid AS "Prod ID",
    p.prodname AS "Product",
    d.delvid AS "Deliv ID",
    d.date AS "Date",
    d.custname AS "Customer"
FROM product p
JOIN Delivery d ON p.prodid = d.prodid;

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════════╗'
\echo '║                              QUERY COMPLETE                                  ║'
\echo '╚══════════════════════════════════════════════════════════════════════════════╝'
\echo ''
