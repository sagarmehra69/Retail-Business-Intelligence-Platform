USE retail_business_intelligence;

-- CTEs | Window Functions | Business Intelligence

-- 81. Monthly Revenue with Running Total
WITH monthly_revenue AS
(
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
        SUM(p.payment_value) AS revenue
    FROM orders o
    JOIN payments p
        ON o.order_id = p.order_id
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue,2) AS revenue,
    ROUND(
        SUM(revenue) OVER(
            ORDER BY month
        ),2
    ) AS running_total
FROM monthly_revenue;

-- 82. Month-over-Month Revenue Growth %
WITH monthly_revenue AS
(
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
        SUM(p.payment_value) AS revenue
    FROM orders o
    JOIN payments p
        ON o.order_id=p.order_id
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue,2) AS revenue,
    ROUND(
        (
            revenue -
            LAG(revenue)
            OVER(ORDER BY month)
        )
        /
        LAG(revenue)
        OVER(ORDER BY month)
        *100,
        2
    ) AS mom_growth_percent
FROM monthly_revenue;

-- 83. Top 5 Products in Every Category
SELECT *
FROM
(
    SELECT
        ct.product_category_name_english,
        p.product_id,
        SUM(oi.price) AS revenue,
        ROW_NUMBER() OVER
        (
            PARTITION BY
            ct.product_category_name_english
            ORDER BY
            SUM(oi.price) DESC
        ) AS rn

    FROM order_items oi
    JOIN products p
        ON oi.product_id=p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name=
           ct.product_category_name
    GROUP BY
        ct.product_category_name_english,
        p.product_id

)t
WHERE rn<=5;

-- 84. Top 20% Customers by Spending (NTILE)
WITH customer_sales AS
(
SELECT
c.customer_unique_id,
SUM(p.payment_value) total_spent
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN payments p
ON o.order_id=p.order_id
GROUP BY c.customer_unique_id
)
SELECT
customer_unique_id,
ROUND(total_spent,2),
NTILE(5)
OVER(
ORDER BY total_spent DESC
) customer_group
FROM customer_sales;

-- 85. Customer Lifetime Value Ranking
WITH customer_value AS
(
SELECT

c.customer_unique_id,

SUM(payment_value) total_value

FROM customers c

JOIN orders o
ON c.customer_id=o.customer_id

JOIN payments p
ON o.order_id=p.order_id

GROUP BY customer_unique_id
)

SELECT

customer_unique_id,

ROUND(total_value,2),

DENSE_RANK()
OVER(
ORDER BY total_value DESC
) lifetime_rank

FROM customer_value;

-- =====================================================

-- Q86. 7-Day Moving Average Revenue

WITH daily_sales AS
(
SELECT

DATE(order_purchase_timestamp) sales_date,

SUM(payment_value) revenue

FROM orders o

JOIN payments p
ON o.order_id=p.order_id

GROUP BY sales_date
)

SELECT

sales_date,

ROUND(revenue,2),

ROUND(
AVG(revenue)
OVER(
ORDER BY sales_date
ROWS BETWEEN 6 PRECEDING
AND CURRENT ROW
),2
) moving_average

FROM daily_sales;

-- =====================================================

-- Q87. Revenue Contribution (Pareto Analysis)

WITH category_sales AS
(
SELECT

ct.product_category_name_english category,

SUM(oi.price) revenue

FROM order_items oi

JOIN products p
ON oi.product_id=p.product_id

LEFT JOIN category_translation ct
ON p.product_category_name=
ct.product_category_name

GROUP BY category
)

SELECT

category,

ROUND(revenue,2),

ROUND(

SUM(revenue)
OVER(
ORDER BY revenue DESC
)

/

SUM(revenue)
OVER()

*100

,2)

AS cumulative_percentage

FROM category_sales;

-- =====================================================

-- Q88. Seller Revenue Ranking

SELECT

seller_id,

SUM(price) revenue,

ROW_NUMBER()
OVER(
ORDER BY SUM(price) DESC
) seller_rank

FROM order_items

GROUP BY seller_id;

-- =====================================================

-- Q89. Highest Revenue Order Per Month

WITH order_sales AS
(
SELECT

DATE_FORMAT(
o.order_purchase_timestamp,
'%Y-%m'
) month,

o.order_id,

SUM(payment_value) revenue

FROM orders o

JOIN payments p
ON o.order_id=p.order_id

GROUP BY
month,
o.order_id
)

SELECT *

FROM
(

SELECT

*,

ROW_NUMBER()
OVER(
PARTITION BY month
ORDER BY revenue DESC
) rn

FROM order_sales

)t

WHERE rn=1;

-- =====================================================

-- Q90. RFM Analysis

WITH rfm AS
(
SELECT

c.customer_unique_id,

DATEDIFF(
MAX(o.order_purchase_timestamp),
MIN(o.order_purchase_timestamp)
) recency,

COUNT(DISTINCT o.order_id) frequency,

SUM(payment_value) monetary

FROM customers c

JOIN orders o
ON c.customer_id=o.customer_id

JOIN payments p
ON o.order_id=p.order_id

GROUP BY customer_unique_id
)

SELECT

customer_unique_id,

recency,

frequency,

ROUND(monetary,2),

CASE

WHEN monetary>=1000 THEN 'VIP'

WHEN monetary>=500 THEN 'Premium'

WHEN monetary>=200 THEN 'Regular'

ELSE 'Low Value'

END customer_segment

FROM rfm;