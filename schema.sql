-- ============================================
-- SEMI-EXAM ER DIAGRAM SCHEMA
-- PostgreSQL Database Schema
-- ============================================

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS Delivery CASCADE;
DROP TABLE IF EXISTS Autoriz_staff CASCADE;
DROP TABLE IF EXISTS Stock CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS Invoice CASCADE;
DROP TABLE IF EXISTS product CASCADE;

-- ============================================
-- TABLE 1: product (No dependencies)
-- ============================================
CREATE TABLE product (
    prodid      SERIAL PRIMARY KEY,
    price       DECIMAL(10,2) NOT NULL,
    prodcatgry  VARCHAR(100),
    prodname    VARCHAR(200) NOT NULL,
    image       VARCHAR(500),
    proddescr   TEXT
);

COMMENT ON TABLE product IS 'Product catalog table';
COMMENT ON COLUMN product.prodid IS 'Primary key - Product ID';
COMMENT ON COLUMN product.price IS 'Product price';
COMMENT ON COLUMN product.prodcatgry IS 'Product category';
COMMENT ON COLUMN product.prodname IS 'Product name';
COMMENT ON COLUMN product.image IS 'Product image URL/path';
COMMENT ON COLUMN product.proddescr IS 'Product description';

-- ============================================
-- TABLE 2: Invoice (No dependencies)
-- ============================================
CREATE TABLE Invoice (
    invocid     SERIAL PRIMARY KEY,
    unitprce    DECIMAL(10,2) NOT NULL,
    prcttotl    DECIMAL(10,2) NOT NULL,
    quantity    INTEGER NOT NULL,
    date        DATE NOT NULL,
    plprod      VARCHAR(200),
    pay         VARCHAR(50)
);

COMMENT ON TABLE Invoice IS 'Invoice records table';
COMMENT ON COLUMN Invoice.invocid IS 'Primary key - Invoice ID';
COMMENT ON COLUMN Invoice.unitprce IS 'Unit price';
COMMENT ON COLUMN Invoice.prcttotl IS 'Price total';
COMMENT ON COLUMN Invoice.quantity IS 'Quantity';
COMMENT ON COLUMN Invoice.date IS 'Invoice date';
COMMENT ON COLUMN Invoice.plprod IS 'Product placeholder';
COMMENT ON COLUMN Invoice.pay IS 'Payment method';

-- ============================================
-- TABLE 3: customer (FK: invocid -> Invoice)
-- Relationship: Invoice -> customer (1:N) "pay"
-- ============================================
CREATE TABLE customer (
    custid      SERIAL PRIMARY KEY,
    usrname     VARCHAR(100) NOT NULL,
    email       VARCHAR(200) NOT NULL,
    passwrd     VARCHAR(255) NOT NULL,
    phone       VARCHAR(20),
    regdate     DATE NOT NULL,
    adress      TEXT,
    invocid     INTEGER REFERENCES Invoice(invocid) ON DELETE SET NULL
);

COMMENT ON TABLE customer IS 'Customer information table';
COMMENT ON COLUMN customer.custid IS 'Primary key - Customer ID';
COMMENT ON COLUMN customer.usrname IS 'Username';
COMMENT ON COLUMN customer.email IS 'Email address';
COMMENT ON COLUMN customer.passwrd IS 'Password (hashed)';
COMMENT ON COLUMN customer.phone IS 'Phone number';
COMMENT ON COLUMN customer.regdate IS 'Registration date';
COMMENT ON COLUMN customer.adress IS 'Address';
COMMENT ON COLUMN customer.invocid IS 'FK -> Invoice (pay relationship)';

-- ============================================
-- TABLE 4: order (FK: custid -> customer)
-- Relationship: customer -> order (1:N) "make"
-- Note: "order" is a reserved word, must be quoted
-- ============================================
CREATE TABLE "order" (
    orderid     SERIAL PRIMARY KEY,
    payment     VARCHAR(50),
    orderdate   DATE NOT NULL,
    quantity    INTEGER NOT NULL,
    prodid      INTEGER,
    prodname    VARCHAR(200),
    deliveid    INTEGER,
    custid      INTEGER REFERENCES customer(custid) ON DELETE SET NULL
);

COMMENT ON TABLE "order" IS 'Order records table';
COMMENT ON COLUMN "order".orderid IS 'Primary key - Order ID';
COMMENT ON COLUMN "order".payment IS 'Payment method';
COMMENT ON COLUMN "order".orderdate IS 'Order date';
COMMENT ON COLUMN "order".quantity IS 'Order quantity';
COMMENT ON COLUMN "order".prodid IS 'Product ID reference';
COMMENT ON COLUMN "order".prodname IS 'Product name';
COMMENT ON COLUMN "order".deliveid IS 'Delivery ID reference';
COMMENT ON COLUMN "order".custid IS 'FK -> customer (make relationship)';

-- ============================================
-- TABLE 5: Stock (FK: prodid -> product)
-- Relationship: product -> Stock (1:N) "has"
-- ============================================
CREATE TABLE Stock (
    stockid     SERIAL PRIMARY KEY,
    quantty     INTEGER NOT NULL,
    date        DATE NOT NULL,
    prodid      INTEGER REFERENCES product(prodid) ON DELETE CASCADE
);

COMMENT ON TABLE Stock IS 'Stock/Inventory table';
COMMENT ON COLUMN Stock.stockid IS 'Primary key - Stock ID';
COMMENT ON COLUMN Stock.quantty IS 'Quantity in stock';
COMMENT ON COLUMN Stock.date IS 'Stock date';
COMMENT ON COLUMN Stock.prodid IS 'FK -> product (has relationship)';

-- ============================================
-- TABLE 6: Autoriz_staff (FK: prodid -> product)
-- Relationship: product -> Autoriz_staff (1:N) "authorize"
-- ============================================
CREATE TABLE Autoriz_staff (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    adress      TEXT,
    compname    VARCHAR(200),
    compnynme   VARCHAR(200),
    prodid      INTEGER REFERENCES product(prodid) ON DELETE SET NULL
);

COMMENT ON TABLE Autoriz_staff IS 'Authorized staff table';
COMMENT ON COLUMN Autoriz_staff.id IS 'Primary key - Staff ID';
COMMENT ON COLUMN Autoriz_staff.name IS 'Staff name';
COMMENT ON COLUMN Autoriz_staff.adress IS 'Staff address';
COMMENT ON COLUMN Autoriz_staff.compname IS 'Company name';
COMMENT ON COLUMN Autoriz_staff.compnynme IS 'Company name (alternate)';
COMMENT ON COLUMN Autoriz_staff.prodid IS 'FK -> product (authorize relationship)';

-- ============================================
-- TABLE 7: Delivery (FK: staffid, orderid, prodid)
-- Relationships:
--   - Autoriz_staff -> Delivery (1:N) "authorize"
--   - order -> Delivery (1:N) "contains"
--   - product -> Delivery (1:N) "autoriz staff"
-- ============================================
CREATE TABLE Delivery (
    delvid      SERIAL PRIMARY KEY,
    date        DATE NOT NULL,
    custname    VARCHAR(100),
    quantity    INTEGER NOT NULL,
    staffid     INTEGER REFERENCES Autoriz_staff(id) ON DELETE SET NULL,
    orderid     INTEGER REFERENCES "order"(orderid) ON DELETE SET NULL,
    prodid      INTEGER REFERENCES product(prodid) ON DELETE SET NULL
);

COMMENT ON TABLE Delivery IS 'Delivery records table';
COMMENT ON COLUMN Delivery.delvid IS 'Primary key - Delivery ID';
COMMENT ON COLUMN Delivery.date IS 'Delivery date';
COMMENT ON COLUMN Delivery.custname IS 'Customer name';
COMMENT ON COLUMN Delivery.quantity IS 'Delivery quantity';
COMMENT ON COLUMN Delivery.staffid IS 'FK -> Autoriz_staff (authorize relationship)';
COMMENT ON COLUMN Delivery.orderid IS 'FK -> order (contains relationship)';
COMMENT ON COLUMN Delivery.prodid IS 'FK -> product (autoriz staff relationship)';

-- ============================================
-- CREATE INDEXES FOR FOREIGN KEYS
-- ============================================
CREATE INDEX idx_customer_invocid ON customer(invocid);
CREATE INDEX idx_order_custid ON "order"(custid);
CREATE INDEX idx_stock_prodid ON Stock(prodid);
CREATE INDEX idx_autoriz_staff_prodid ON Autoriz_staff(prodid);
CREATE INDEX idx_delivery_staffid ON Delivery(staffid);
CREATE INDEX idx_delivery_orderid ON Delivery(orderid);
CREATE INDEX idx_delivery_prodid ON Delivery(prodid);

-- ============================================
-- SCHEMA CREATION COMPLETE
-- ============================================
\echo ''
\echo '============================================'
\echo '  SCHEMA CREATED SUCCESSFULLY!'
\echo '============================================'
\echo ''
\echo 'Tables created:'
\echo '  1. product'
\echo '  2. Invoice'
\echo '  3. customer'
\echo '  4. order'
\echo '  5. Stock'
\echo '  6. Autoriz_staff'
\echo '  7. Delivery'
\echo ''

-- Show all tables
\dt
