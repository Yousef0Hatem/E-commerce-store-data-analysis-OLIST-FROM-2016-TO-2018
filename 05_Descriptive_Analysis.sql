/*==============================================================
  OLIST E-COMMERCE ANALYSIS
  FILE: 05_Descriptive_Analysis.sql
  PURPOSE: Core descriptive metrics that summarize customers,
           orders, products, sellers, payments, revenue and delivery.
==============================================================*/

/*==============================================================
  1. CORE BUSINESS COUNTS
==============================================================*/

-- Real unique customers.
SELECT COUNT(DISTINCT customer_unique_id) AS real_customers
FROM customers;

-- Delivered orders.
SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';

-- Products.
SELECT COUNT(product_id) AS total_products
FROM products;

-- Sellers.
SELECT COUNT(seller_id) AS total_sellers
FROM sellers;

-- Number of payment methods.
SELECT COUNT(DISTINCT payment_type) AS payment_methods
FROM order_payments;

/*==============================================================
  2. REVENUE AND ORDER VALUE
==============================================================*/

-- Total product sales and total freight.
SELECT
    SUM(price) AS total_product_sales,
    SUM(freight_value) AS total_freight
FROM order_items;

-- Average item price.
SELECT AVG(price) AS average_item_price
FROM order_items;

-- Average order value = product price + freight aggregated per order.
SELECT
    AVG(order_total) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_total
    FROM order_items
    GROUP BY order_id
) AS OrderTotals;

-- Highest-value orders.
SELECT
    order_id,
    SUM(price + freight_value) AS order_total
FROM order_items
GROUP BY order_id
ORDER BY order_total DESC;

/*==============================================================
  3. DELIVERY OVERVIEW
==============================================================*/

-- Average delivery time for delivered orders.
SELECT
    AVG(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Delivery time by order.
SELECT
    order_id,
    DATEDIFF(
        DAY,
        order_purchase_timestamp,
        order_delivered_customer_date
    ) AS delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
ORDER BY delivery_days DESC;

-- Overall delivery time range.
SELECT
    COUNT(*) AS total_delivered_orders,
    AVG(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days,
    MIN(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS minimum_delivery_days,
    MAX(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS maximum_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

/*==============================================================
  4. REVENUE BY CUSTOMER STATE
==============================================================*/

SELECT
    C.customer_state,
    COUNT(DISTINCT O.order_id) AS total_orders,
    SUM(OI.price + OI.freight_value) AS total_revenue,
    SUM(OI.price + OI.freight_value) * 1.0
        / COUNT(DISTINCT O.order_id) AS average_order_value
FROM orders AS O
JOIN customers AS C
    ON O.customer_id = C.customer_id
JOIN order_items AS OI
    ON O.order_id = OI.order_id
GROUP BY C.customer_state
ORDER BY total_revenue DESC;

/*==============================================================
  5. ORDERS BY MONTH
==============================================================*/

SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;

/*==============================================================
  6. PRODUCT CATEGORY PERFORMANCE
==============================================================*/

-- Number of item lines sold by category.
SELECT
    p.product_category_name AS category,
    COUNT(*) AS total_items_sold
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC;

-- Revenue by category.
SELECT
    p.product_category_name AS category,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

/*==============================================================
  7. SELLER PERFORMANCE BASICS
==============================================================*/

SELECT
    seller_id,
    COUNT(*) AS total_items_sold
FROM order_items
GROUP BY seller_id
ORDER BY total_items_sold DESC;

/*==============================================================
  8. TOP CUSTOMERS AND REPEAT PURCHASES
==============================================================*/

-- Customers with the highest number of orders.
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders AS o
JOIN customers AS c
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

-- Customers with more than one order.
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders AS o
JOIN customers AS c
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;

/*==============================================================
  9. REPEAT CUSTOMER RATE
==============================================================*/

WITH CustomerOrders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    100.0 *
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        / COUNT(*) AS repeat_rate
FROM CustomerOrders;

/*==============================================================
  10. DELIVERY TIME BUCKETS
==============================================================*/

WITH DeliveryData AS (
    SELECT
        order_id,
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) AS delivery_days
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT
    CASE
        WHEN delivery_days <= 5 THEN '0-5 days'
        WHEN delivery_days <= 10 THEN '6-10 days'
        WHEN delivery_days <= 15 THEN '11-15 days'
        WHEN delivery_days <= 20 THEN '16-20 days'
        ELSE 'More than 20 days'
    END AS delivery_bucket,
    COUNT(*) AS total_orders
FROM DeliveryData
GROUP BY
    CASE
        WHEN delivery_days <= 5 THEN '0-5 days'
        WHEN delivery_days <= 10 THEN '6-10 days'
        WHEN delivery_days <= 15 THEN '11-15 days'
        WHEN delivery_days <= 20 THEN '16-20 days'
        ELSE 'More than 20 days'
    END
ORDER BY total_orders DESC;

/*==============================================================
  11. ACTUAL VS ESTIMATED DELIVERY
==============================================================*/

SELECT
    order_id,
    DATEDIFF(
        DAY,
        order_estimated_delivery_date,
        order_delivered_customer_date
    ) AS delivery_difference_days,
    CASE
        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) < 0 THEN 'Early'
        WHEN DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) = 0 THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

/*==============================================================
  12. TOP 10 PRODUCTS
==============================================================*/

SELECT TOP 10
    product_id,
    COUNT(*) AS total_items_sold
FROM order_items
GROUP BY product_id
ORDER BY total_items_sold DESC;
