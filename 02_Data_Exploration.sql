/*==============================================================
  OLIST E-COMMERCE ANALYSIS
  FILE: 02_Data_Exploration.sql
  PURPOSE: Understand the structure, size and basic content of
           each table before performing data quality checks.
==============================================================*/

/*==============================================================
  1. QUICK VIEW OF EACH TABLE
==============================================================*/

-- Customers
SELECT TOP 10 * FROM customers;

-- Orders
SELECT TOP 10 * FROM orders;

-- Geolocation
SELECT TOP 10 * FROM geolocation;

-- Products
SELECT TOP 10 * FROM products;

-- Sellers
SELECT TOP 10 * FROM sellers;

-- Order Reviews
SELECT TOP 10 * FROM order_reviews;

-- Order Payments
SELECT TOP 10 * FROM order_payments;

-- Order Items
SELECT TOP 10 * FROM order_items;

/*==============================================================
  2. CUSTOMER EXPLORATION
==============================================================*/

-- Number of customer records vs. real unique customers.
SELECT COUNT(*) AS customer_records
FROM customers;

SELECT COUNT(DISTINCT customer_unique_id) AS real_customers
FROM customers;

-- Customer distribution by state.
SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Most frequent customer ZIP-code prefixes.
SELECT
    customer_zip_code_prefix,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_zip_code_prefix
ORDER BY total_customers DESC;

/*==============================================================
  3. DISTINCT VALUE EXPLORATION
==============================================================*/

-- Customer states.
SELECT DISTINCT customer_state
FROM customers;

-- Customer cities.
SELECT DISTINCT customer_city
FROM customers;

-- Payment methods.
SELECT DISTINCT payment_type
FROM order_payments;

-- Review score distribution.
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY total_reviews DESC;

/*==============================================================
  4. PRODUCT CATEGORY TRANSLATION
==============================================================*/

-- Inspect the original translation table.
SELECT *
FROM product_category_name_translation;

-- Match Portuguese category names to English translations.
SELECT
    p.product_category_name AS category_portuguese,
    t.column1 AS category_portuguese_translation,
    t.column2 AS category_english
FROM products AS p
JOIN product_category_name_translation AS t
    ON p.product_category_name = t.column1;

/*==============================================================
  5. DATABASE COLUMN METADATA
==============================================================*/

-- Example: inspect data types and NULLability of order_payments.
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_payments';
