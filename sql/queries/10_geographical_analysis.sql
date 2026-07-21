USE retail_business_intelligence;

-- 71. Revenue by Customer State
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- 72. Top 10 Revenue Cities
SELECT
    c.customer_city,
    c.customer_state,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_city,c.customer_state
ORDER BY revenue DESC
LIMIT 10;

-- 73. Orders by Customer State
SELECT
    customer_state,
    COUNT(*) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY customer_state
ORDER BY total_orders DESC;

-- 74. Top Seller States
SELECT
    seller_state,
    COUNT(*) AS total_sellers
FROM sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;

-- 75. Revenue by Seller State
SELECT
    s.seller_state,
    ROUND(SUM(oi.price),2) AS revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;

-- 76. Average Review Score by Customer State
SELECT
    c.customer_state,
    ROUND(AVG(r.review_score),2) AS average_rating
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN reviews r
ON o.order_id = r.order_id
GROUP BY c.customer_state
ORDER BY average_rating DESC;

-- 77. Average Delivery Time by Customer State
SELECT
    c.customer_state,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),2
    ) AS average_delivery_days
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_status='delivered'
GROUP BY c.customer_state
ORDER BY average_delivery_days;

-- 78. Top 10 Cities by Number of Customers
SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM customers
GROUP BY customer_city,customer_state
ORDER BY customers DESC
LIMIT 10;

-- 79. Top 10 States by Average Order Value
SELECT
    c.customer_state,
    ROUND(AVG(p.payment_value),2) AS average_order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY average_order_value DESC
LIMIT 10;

-- 80. State Revenue Ranking
SELECT
    customer_state,
    revenue,
    DENSE_RANK() OVER(ORDER BY revenue DESC) AS state_rank
FROM
(
    SELECT
        c.customer_state,
        SUM(p.payment_value) AS revenue
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    JOIN payments p
    ON o.order_id = p.order_id
    GROUP BY c.customer_state
) t;