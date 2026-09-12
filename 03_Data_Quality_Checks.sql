/*==============================================================
  OLIST E-COMMERCE ANALYSIS
  FILE: 03_Data_Quality_Checks.sql
  PURPOSE: Check NULLs, duplicates, invalid ranges and potential
           standardization issues before cleaning the data.
==============================================================*/

/*==============================================================
  1. NULL CHECKS
==============================================================*/

-- Customers
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS customer_unique_id_nulls,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_nulls,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS state_nulls
FROM customers;

-- Orders
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS status_nulls,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS purchase_timestamp_nulls,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS approved_at_nulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS carrier_date_nulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS customer_delivery_date_nulls,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS estimated_delivery_date_nulls
FROM orders;

-- Products
SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS name_length_nulls,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS description_length_nulls,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS photos_qty_nulls,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS weight_nulls,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS length_nulls,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS width_nulls
FROM products;

-- Sellers
SELECT
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_nulls,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS state_nulls
FROM sellers;

-- Geolocation
SELECT
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS zip_code_nulls,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS latitude_nulls,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS longitude_nulls,
    SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS state_nulls
FROM geolocation;

-- Order Items
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS order_item_id_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS shipping_limit_date_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_value_nulls
FROM order_items;

-- Payments
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS payment_sequential_nulls,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS payment_type_nulls,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS payment_installments_nulls,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS payment_value_nulls
FROM order_payments;

-- Reviews
SELECT
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS review_id_nulls,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS review_score_nulls,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS comment_title_nulls,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS comment_message_nulls,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS creation_date_nulls,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS answer_timestamp_nulls
FROM order_reviews;

/*==============================================================
  2. INVESTIGATE WHY ORDER DATES ARE NULL
==============================================================*/

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS approved_nulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS carrier_nulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS customer_delivery_nulls
FROM orders
GROUP BY order_status;

/*==============================================================
  3. DUPLICATE CHECKS FOR EXPECTED UNIQUE KEYS
==============================================================*/

-- Customers
SELECT customer_id, COUNT(*) AS total_rows
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Orders
SELECT order_id, COUNT(*) AS total_rows
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Products
SELECT product_id, COUNT(*) AS total_rows
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Sellers
SELECT seller_id, COUNT(*) AS total_rows
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Order items: order_id + order_item_id should identify an item line.
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS total_rows
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Payments: order_id + payment_sequential identifies payment sequence rows.
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS total_rows
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- Reviews: review_id is expected to identify a review.
SELECT review_id, COUNT(*) AS total_rows
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

/*==============================================================
  4. GEOLOCATION DUPLICATE INVESTIGATION
  NOTE: A repeated ZIP prefix alone is not automatically a duplicate.
        We check the complete location record before deleting rows.
==============================================================*/

SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS total_rows
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY total_rows DESC;

/*==============================================================
  5. INVALID RANGE CHECKS
==============================================================*/

-- Item price should not be negative.
SELECT *
FROM order_items
WHERE price < 0;

-- Freight should not be negative.
SELECT *
FROM order_items
WHERE freight_value < 0;

-- Review scores should be between 1 and 5.
SELECT *
FROM order_reviews
WHERE review_score < 1
   OR review_score > 5;

-- Product physical dimensions/weight should not be negative.
SELECT *
FROM products
WHERE product_weight_g < 0
   OR product_length_cm < 0
   OR product_height_cm < 0
   OR product_width_cm < 0;

/*==============================================================
  6. STANDARDIZATION CHECKS
==============================================================*/

-- Detect category values that differ only by case/extra spaces.
SELECT
    LOWER(TRIM(product_category_name)) AS normalized_category,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_category_name) AS different_versions
FROM products
GROUP BY LOWER(TRIM(product_category_name))
HAVING COUNT(DISTINCT product_category_name) > 1
ORDER BY different_versions DESC;

-- Detect values that differ because of accents/case.
SELECT
    product_category_name COLLATE Latin1_General_100_CI_AI AS normalized_category,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_category_name) AS different_versions
FROM products
GROUP BY product_category_name COLLATE Latin1_General_100_CI_AI
HAVING COUNT(DISTINCT product_category_name) > 1
ORDER BY different_versions DESC;

-- City standardization preview.
SELECT
    geolocation_city AS old_city,
    LOWER(
        LTRIM(RTRIM(
            geolocation_city COLLATE Latin1_General_100_CI_AI
        ))
    ) AS normalized_city
FROM geolocation;
