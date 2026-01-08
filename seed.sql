-- ============================================
-- SEMI-EXAM ER DIAGRAM SEED DATA
-- Insert 3 records per table (21 total records)
-- ============================================

\echo ''
\echo '============================================'
\echo '  INSERTING SAMPLE DATA...'
\echo '============================================'
\echo ''

-- ============================================
-- TABLE 1: product (3 records)
-- ============================================
INSERT INTO product (price, prodcatgry, prodname, image, proddescr) VALUES
(299.99, 'Electronics', 'Wireless Headphones', 'headphones.jpg', 'High-quality wireless Bluetooth headphones with noise cancellation'),
(599.99, 'Electronics', 'Smartphone Pro', 'smartphone.jpg', 'Latest smartphone with 6.5 inch display and 128GB storage'),
(49.99, 'Accessories', 'Phone Case Premium', 'case.jpg', 'Protective silicone phone case with shock absorption');

\echo 'Inserted 3 records into: product'

-- ============================================
-- TABLE 2: Invoice (3 records)
-- ============================================
INSERT INTO Invoice (unitprce, prcttotl, quantity, date, plprod, pay) VALUES
(299.99, 299.99, 1, '2024-01-15', 'Wireless Headphones', 'Credit Card'),
(599.99, 1199.98, 2, '2024-01-16', 'Smartphone Pro', 'PayPal'),
(49.99, 149.97, 3, '2024-01-17', 'Phone Case Premium', 'Cash');

\echo 'Inserted 3 records into: Invoice'

-- ============================================
-- TABLE 3: customer (3 records)
-- FK: invocid references Invoice
-- ============================================
INSERT INTO customer (usrname, email, passwrd, phone, regdate, adress, invocid) VALUES
('john_doe', 'john.doe@email.com', 'hashed_password_123', '555-0101', '2024-01-01', '123 Main Street, New York, NY 10001', 1),
('jane_smith', 'jane.smith@email.com', 'hashed_password_456', '555-0102', '2024-01-05', '456 Oak Avenue, Los Angeles, CA 90001', 2),
('bob_wilson', 'bob.wilson@email.com', 'hashed_password_789', '555-0103', '2024-01-10', '789 Pine Road, Chicago, IL 60601', 3);

\echo 'Inserted 3 records into: customer'

-- ============================================
-- TABLE 4: order (3 records)
-- FK: custid references customer
-- ============================================
INSERT INTO "order" (payment, orderdate, quantity, prodid, prodname, deliveid, custid) VALUES
('Credit Card', '2024-01-15', 1, 1, 'Wireless Headphones', NULL, 1),
('PayPal', '2024-01-16', 2, 2, 'Smartphone Pro', NULL, 2),
('Cash', '2024-01-17', 3, 3, 'Phone Case Premium', NULL, 3);

\echo 'Inserted 3 records into: order'

-- ============================================
-- TABLE 5: Stock (3 records)
-- FK: prodid references product
-- ============================================
INSERT INTO Stock (quantty, date, prodid) VALUES
(100, '2024-01-01', 1),
(50, '2024-01-01', 2),
(200, '2024-01-01', 3);

\echo 'Inserted 3 records into: Stock'

-- ============================================
-- TABLE 6: Autoriz_staff (3 records)
-- FK: prodid references product
-- ============================================
INSERT INTO Autoriz_staff (name, adress, compname, compnynme, prodid) VALUES
('Alice Johnson', '100 Corporate Blvd, Suite 200', 'TechCorp International', 'TCI Ltd', 1),
('Charlie Brown', '200 Business Park, Building A', 'TechCorp International', 'TCI Ltd', 2),
('Diana Martinez', '300 Enterprise Way, Floor 5', 'TechCorp International', 'TCI Ltd', 3);

\echo 'Inserted 3 records into: Autoriz_staff'

-- ============================================
-- TABLE 7: Delivery (3 records)
-- FK: staffid references Autoriz_staff
-- FK: orderid references order
-- FK: prodid references product
-- ============================================
INSERT INTO Delivery (date, custname, quantity, staffid, orderid, prodid) VALUES
('2024-01-18', 'John Doe', 1, 1, 1, 1),
('2024-01-19', 'Jane Smith', 2, 2, 2, 2),
('2024-01-20', 'Bob Wilson', 3, 3, 3, 3);

\echo 'Inserted 3 records into: Delivery'

-- ============================================
-- UPDATE order.deliveid with actual delivery IDs
-- ============================================
UPDATE "order" SET deliveid = 1 WHERE orderid = 1;
UPDATE "order" SET deliveid = 2 WHERE orderid = 2;
UPDATE "order" SET deliveid = 3 WHERE orderid = 3;

\echo ''
\echo '============================================'
\echo '  SEED DATA INSERTED SUCCESSFULLY!'
\echo '============================================'
\echo ''
\echo 'Total records inserted: 21'
\echo '  - product:       3 records'
\echo '  - Invoice:       3 records'
\echo '  - customer:      3 records'
\echo '  - order:         3 records'
\echo '  - Stock:         3 records'
\echo '  - Autoriz_staff: 3 records'
\echo '  - Delivery:      3 records'
\echo ''
