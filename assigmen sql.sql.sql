-- ============================================================================
-- Assignment #2 – PostgreSQL Implementation & Querying
-- Student Information
-- Name: Dilmurod Rakhimberganov
-- Course: Big Data analistics 
-- Date: 21.05.2026
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. DROPPING EXISTING TABLES (To prevent conflicts during re-runs)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ----------------------------------------------------------------------------
-- 2. DATABASE SCHEMA CREATION
-- ----------------------------------------------------------------------------

-- Customers Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- Products Table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

-- Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0)
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0)
);

-- Payments Table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(30) NOT NULL
);

-- ----------------------------------------------------------------------------
-- 3. DATA INSERTION (Sample Data)
-- ----------------------------------------------------------------------------

-- Inserting Customers
INSERT INTO customers (full_name, email, city) VALUES
('Ali Karimov', 'ali@gmail.com', 'Berlin'),
('Sara Lee', 'sara@gmail.com', 'Paris'),
('John Smith', 'john@gmail.com', 'London'),
('Emma Brown', 'emma@gmail.com', 'Rome'),
('David Miller', 'david@gmail.com', 'Madrid'),
('Sophia White', 'sophia@gmail.com', 'Berlin'),
('Daniel Green', 'daniel@gmail.com', 'Amsterdam'),
('Lina Scott', 'lina@gmail.com', 'Prague'),
('Michael Stone', 'michael@gmail.com', 'Vienna'),
('Olivia Adams', 'olivia@gmail.com', 'Warsaw');

-- Inserting Products
INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('Laptop', 'Electronics', 1200.00, 20),
('Smartphone', 'Electronics', 800.00, 30),
('Keyboard', 'Accessories', 50.00, 100),
('Mouse', 'Accessories', 35.00, 120),
('Monitor', 'Electronics', 250.00, 40),
('Chair', 'Furniture', 150.00, 15),
('Desk', 'Furniture', 300.00, 10),
('Headphones', 'Electronics', 90.00, 60),
('USB Cable', 'Accessories', 10.00, 200),
('Tablet', 'Electronics', 500.00, 25);

-- Inserting Orders
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2026-05-01', 1250.00),
(2, '2026-05-02', 850.00),
(3, '2026-05-03', 300.00),
(4, '2026-05-04', 90.00),
(5, '2026-05-05', 510.00),
(6, '2026-05-06', 1300.00),
(7, '2026-05-07', 70.00),
(8, '2026-05-08', 450.00),
(9, '2026-05-09', 900.00),
(10, '2026-05-10', 1100.00);

-- Inserting Order Items
INSERT INTO order_items (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 1, 1200.00),
(1, 3, 1, 50.00),
(2, 2, 1, 800.00),
(2, 4, 1, 35.00),
(3, 5, 1, 250.00),
(3, 9, 5, 50.00),
(4, 8, 1, 90.00),
(5, 10, 1, 500.00),
(5, 9, 1, 10.00),
(6, 1, 1, 1200.00),
(6, 4, 2, 70.00),
(7, 3, 1, 50.00),
(7, 9, 2, 20.00),
(8, 6, 3, 450.00),
(9, 2, 1, 800.00),
(9, 3, 2, 100.00),
(10, 1, 1, 1200.00);

-- Inserting Payments
INSERT INTO payments (order_id, payment_method, payment_status) VALUES
(1, 'Credit Card', 'Paid'),
(2, 'PayPal', 'Paid'),
(3, 'Cash', 'Paid'),
(4, 'Credit Card', 'Pending'),
(5, 'PayPal', 'Paid'),
(6, 'Credit Card', 'Paid'),
(7, 'Cash', 'Pending'),
(8, 'PayPal', 'Paid'),
(9, 'Credit Card', 'Paid'),
(10, 'Bank Transfer', 'Pending');

-- ----------------------------------------------------------------------------
-- 4. SQL QUERIES AND ANALYSIS
-- ----------------------------------------------------------------------------

-- Query 1: Total Revenue by Product Category
-- Analysis: Calculates the total revenue generated from each product category 
-- to identify the most profitable areas.
SELECT p.category,
       SUM(oi.subtotal) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
HAVING SUM(oi.subtotal) > 100
ORDER BY total_revenue DESC;

-- Query 2: Customers from Berlin
-- Analysis: Filters customers based on city for targeted regional marketing campaigns.
SELECT *
FROM customers
WHERE city = 'Berlin';

-- Query 3: Orders Between Specific Dates
-- Analysis: Shows all orders made during a selected time period to track performance.
SELECT *
FROM orders
WHERE order_date BETWEEN '2026-05-01' AND '2026-05-07'
ORDER BY total_amount DESC;

-- Query 4: Customer Orders Using JOIN
-- Analysis: Combines customer and order information to analyze customer purchasing power.
SELECT c.full_name,
       o.order_id,
       o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.total_amount DESC;

-- Query 5: Top Spending Customer (Subquery)
-- Analysis: Identifies the customer who spent the most money overall for loyalty programs.
SELECT full_name
FROM customers
WHERE customer_id = (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
);
