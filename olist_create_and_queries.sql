-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS olist_ecommerce;
USE olist_ecommerce;

-- Step 2: Create Tables
CREATE TABLE olist_customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE olist_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

CREATE TABLE olist_order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value FLOAT
);

-- Add other tables here if needed (products, sellers, items, etc.)

-- Step 3: SQL Analysis Queries

-- 1️⃣ Revenue Over Time
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    SUM(payment_value) AS total_revenue
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- 2️⃣ Top Product Categories
SELECT 
    product_category_name, COUNT(*) AS total_sold
FROM olist_order_items oi
JOIN olist_products p ON oi.product_id = p.product_id
GROUP BY product_category_name
ORDER BY total_sold DESC
LIMIT 10;

-- 3️⃣ Average Delivery Time
SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))) AS avg_delivery_days
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL;

-- 4️⃣ WHERE Clause Example
SELECT * 
FROM olist_orders
WHERE order_status = 'delivered';

-- 5️⃣ HAVING Clause Example
SELECT customer_id, COUNT(*) AS total_orders
FROM olist_orders
GROUP BY customer_id
HAVING total_orders > 3;

-- 6️⃣ LEFT JOIN Example
SELECT o.order_id, c.customer_city, o.order_status
FROM olist_orders o
LEFT JOIN olist_customers c ON o.customer_id = c.customer_id
LIMIT 10;

-- 7️⃣ Subquery Example
SELECT * 
FROM olist_customers
WHERE customer_id IN (
    SELECT customer_id
    FROM olist_orders
    WHERE order_status = 'canceled'
);

-- 8️⃣ Average Revenue Per User
SELECT 
    c.customer_id, 
    ROUND(AVG(p.payment_value), 2) AS avg_revenue
FROM olist_customers c
JOIN olist_orders o ON c.customer_id = o.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
GROUP BY c.customer_id
LIMIT 10;
-- 9️⃣ Create a View: Top Customers with Total Spend
CREATE VIEW top_customers AS
SELECT c.customer_id, SUM(p.payment_value) AS total_spent
FROM olist_customers c
JOIN olist_orders o ON c.customer_id = o.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
GROUP BY c.customer_id
HAVING total_spent > 1000;
SELECT * FROM top_customers LIMIT 10;
-- 🔟 Index on order_id for performance
CREATE INDEX idx_order_id ON olist_orders(order_id);
