/*==============================================================
  OLIST E-COMMERCE ANALYSIS
  FILE: 06_Business_Analysis.sql
  PURPOSE: Answer the main business questions and produce
           portfolio-ready analysis outputs.
==============================================================*/

/*==============================================================
  BUSINESS QUESTION 1
  What percentage of delivered orders were late?
==============================================================*/

SELECT
    COUNT(*) AS total_delivered_orders,
    SUM(
        CASE
            WHEN DATEDIFF(
                DAY,
                order_estimated_delivery_date,
                order_delivered_customer_date
            ) > 0 THEN 1
            ELSE 0
        END
    ) AS late_orders,
    100.0 *
        SUM(
            CASE
                WHEN DATEDIFF(
                    DAY,
                    order_estimated_delivery_date,
                    order_delivered_customer_date
                ) > 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS late_rate
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

/*==============================================================
  BUSINESS QUESTION 2
  Which customer states have the highest late-delivery rate?
==============================================================*/

SELECT
    c.customer_state,
    COUNT(*) AS total_delivered_orders,
    SUM(
        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0 THEN 1
            ELSE 0
        END
    ) AS late_orders,
    100.0 *
        SUM(
            CASE
                WHEN DATEDIFF(
                    DAY,
                    o.order_estimated_delivery_date,
                    o.order_delivered_customer_date
                ) > 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS late_rate
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_rate DESC;

/*==============================================================
  BUSINESS QUESTION 3
  Which sellers have the highest late-order rate?
==============================================================*/

SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT
        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0 THEN o.order_id
        END
    ) AS late_orders,
    100.0 *
        COUNT(DISTINCT
            CASE
                WHEN DATEDIFF(
                    DAY,
                    o.order_estimated_delivery_date,
                    o.order_delivered_customer_date
                ) > 0 THEN o.order_id
            END
        ) / COUNT(DISTINCT o.order_id) AS late_rate
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY late_rate DESC;

/*==============================================================
  BUSINESS QUESTION 4
  Which product categories have the highest late-order rate?
==============================================================*/

SELECT
    p.product_category_name AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT
        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0 THEN o.order_id
        END
    ) AS late_orders,
    100.0 *
        COUNT(DISTINCT
            CASE
                WHEN DATEDIFF(
                    DAY,
                    o.order_estimated_delivery_date,
                    o.order_delivered_customer_date
                ) > 0 THEN o.order_id
            END
        ) / COUNT(DISTINCT o.order_id) AS late_rate
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY late_rate DESC;

/*==============================================================
  BUSINESS QUESTION 5
  Does delivery performance relate to customer satisfaction?
==============================================================*/

SELECT
    CASE
        WHEN DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) < 0 THEN 'Early'
        WHEN DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) = 0 THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    AVG(r.review_score * 1.0) AS average_review_score
FROM orders AS o
JOIN order_reviews AS r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) < 0 THEN 'Early'
        WHEN DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) = 0 THEN 'On Time'
        ELSE 'Late'
    END
ORDER BY average_review_score DESC;

/*==============================================================
  BUSINESS QUESTION 6
  Which seller/state combinations have the most late orders?
==============================================================*/

SELECT
    c.customer_state,
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT
        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0 THEN o.order_id
        END
    ) AS late_orders,
    100.0 *
        COUNT(DISTINCT
            CASE
                WHEN DATEDIFF(
                    DAY,
                    o.order_estimated_delivery_date,
                    o.order_delivered_customer_date
                ) > 0 THEN o.order_id
            END
        ) / COUNT(DISTINCT o.order_id) AS late_rate
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    c.customer_state,
    oi.seller_id
ORDER BY
    c.customer_state,
    late_orders DESC;

/*==============================================================
  BUSINESS QUESTION 7
  How long do customers wait for delivery, and does it vary by
  state, seller and category?
==============================================================*/

-- Overall delivery performance.
SELECT
    COUNT(*) AS total_delivered_orders,
    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days,
    MIN(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        )
    ) AS minimum_delivery_days,
    MAX(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        )
    ) AS maximum_delivery_days
FROM orders AS o
WHERE o.order_delivered_customer_date IS NOT NULL;

-- Average delivery time by customer state.
SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY average_delivery_days DESC;

-- Average delivery time by seller.
SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY average_delivery_days DESC;

-- Average delivery time by category.
SELECT
    p.product_category_name AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY average_delivery_days DESC;

/*==============================================================
  BUSINESS QUESTION 8
  How does delivery duration relate to customer satisfaction?
==============================================================*/

SELECT
    CASE
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 5
            THEN '0-5 Days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 10
            THEN '6-10 Days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 15
            THEN '11-15 Days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 20
            THEN '16-20 Days'
        ELSE '21+ Days'
    END AS delivery_time_group,
    COUNT(DISTINCT o.order_id) AS total_orders,
    AVG(r.review_score * 1.0) AS average_review_score
FROM orders AS o
JOIN order_reviews AS r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 5
            THEN '0-5 Days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 10
            THEN '6-10 Days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 15
            THEN '11-15 Days'
        WHEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 20
            THEN '16-20 Days'
        ELSE '21+ Days'
    END
ORDER BY
    MIN(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        )
    );

/*==============================================================
  BUSINESS QUESTION 9
  What proportion of customers are one-time vs repeat customers?
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
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS customer_percentage
FROM CustomerOrders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END;

/*==============================================================
  BUSINESS QUESTION 10
  Do repeat customers spend more than one-time customers?
==============================================================*/

WITH CustomerOrders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
CustomerValue AS (
    SELECT
        c.customer_unique_id,
        COALESCE(SUM(oi.price + oi.freight_value), 0) AS total_spend
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN co.total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    AVG(cv.total_spend) AS average_customer_spend
FROM CustomerOrders AS co
JOIN CustomerValue AS cv
    ON co.customer_unique_id = cv.customer_unique_id
GROUP BY
    CASE
        WHEN co.total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END;

/*==============================================================
  BUSINESS QUESTION 11
  Seller performance profile: volume, lateness, delivery time,
  and customer satisfaction.

  NOTE: This combines the same business dimensions explored in
  the original analysis. For a final dashboard, review possible
  row multiplication when joining item-level and review-level data.
==============================================================*/

SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT
        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0 THEN o.order_id
        END
    ) AS late_orders,
    100.0 *
        COUNT(DISTINCT
            CASE
                WHEN DATEDIFF(
                    DAY,
                    o.order_estimated_delivery_date,
                    o.order_delivered_customer_date
                ) > 0 THEN o.order_id
            END
        ) / COUNT(DISTINCT o.order_id) AS late_rate,
    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days,
    AVG(r.review_score * 1.0) AS average_review_score
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN order_reviews AS r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY late_rate DESC;

/*==============================================================
  BUSINESS QUESTION 12
  Category delivery performance.
==============================================================*/

SELECT
    p.product_category_name AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT
        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0 THEN o.order_id
        END
    ) AS late_orders,
    100.0 *
        COUNT(DISTINCT
            CASE
                WHEN DATEDIFF(
                    DAY,
                    o.order_estimated_delivery_date,
                    o.order_delivered_customer_date
                ) > 0 THEN o.order_id
            END
        ) / COUNT(DISTINCT o.order_id) AS late_rate,
    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) * 1.0
    ) AS average_delivery_days
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY late_rate DESC;

/*==============================================================
  BUSINESS QUESTION 13
  Category performance vs. customer satisfaction.
==============================================================*/

SELECT
    p.product_category_name AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    AVG(r.review_score * 1.0) AS average_review_score
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
JOIN order_reviews AS r
    ON o.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC;

/*==============================================================
  BUSINESS QUESTION 14
  Revenue performance by state.
==============================================================*/

SELECT
    c.customer_state,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

/*==============================================================
  BUSINESS QUESTION 15
  Revenue performance by category.
==============================================================*/

SELECT
    p.product_category_name AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    SUM(oi.price + oi.freight_value) * 1.0
        / COUNT(DISTINCT o.order_id) AS revenue_per_order
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

/*==============================================================
  BUSINESS QUESTION 16
  Revenue performance by seller.
==============================================================*/

SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    SUM(oi.price + oi.freight_value) * 1.0
        / COUNT(DISTINCT o.order_id) AS revenue_per_order
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
GROUP BY oi.seller_id
ORDER BY revenue_per_order DESC;
