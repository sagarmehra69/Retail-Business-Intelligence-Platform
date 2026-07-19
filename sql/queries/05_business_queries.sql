USE retail_business_intelligence;

-- EXECUTIVE KPI DASHBOARD

-- 01. Total Revenue
SELECT
    ROUND(SUM(payment_value),2) AS total_revenue
FROM payments;

-- 02. Total Orders
SELECT
    COUNT(*) AS total_orders
FROM orders;

-- 03. Total Customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;

-- 04. Total Sellers
SELECT
    COUNT(*) AS total_sellers
FROM sellers;

-- 05. Total Products
SELECT
    COUNT(*) AS total_products
FROM products;

-- 06. Average Order Value (AOV)
SELECT
    ROUND(AVG(payment_value),2) AS average_order_value
FROM payments;

-- 07. Average Review Score
SELECT
    ROUND(AVG(review_score),2) AS average_rating
FROM reviews;

-- 08. Total Freight Cost
SELECT
    ROUND(SUM(freight_value),2) AS total_freight
FROM order_items;

-- 09. Average Freight Cost
SELECT
    ROUND(AVG(freight_value),2) AS average_freight
FROM order_items;

-- 10. Total Delivered Orders
SELECT
    COUNT(*) AS delivered_orders
FROM orders
WHERE order_status='delivered';

-- SALES ANALYSIS

-- 11. Monthly Revenue Trend
SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- 12. Monthly Order Trend
SELECT
    DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

-- 13. Top 10 Highest Revenue Months
SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY month
ORDER BY revenue DESC
LIMIT 10;

-- 14. Revenue by Order Status
SELECT
    o.order_status,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;

-- 15. Average Revenue per Order Status
SELECT
    o.order_status,
    ROUND(AVG(p.payment_value),2) AS avg_order_value
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY o.order_status
ORDER BY avg_order_value DESC;

-- 16. Top 10 Highest Value Orders
SELECT
    o.order_id,
    ROUND(SUM(p.payment_value),2) AS total_order_value
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY o.order_id
ORDER BY total_order_value DESC
LIMIT 10;

-- 17. Daily Revenue Trend
SELECT
    DATE(order_purchase_timestamp) AS order_date,
    ROUND(SUM(payment_value),2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY order_date
ORDER BY order_date;

-- 18. Revenue by Day of Week
SELECT
    DAYNAME(order_purchase_timestamp) AS day_name,
    ROUND(SUM(payment_value),2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY day_name
ORDER BY revenue DESC;

-- 19. Quarterly Revenue
SELECT
    CONCAT(
        YEAR(order_purchase_timestamp), '-Q', QUARTER(order_purchase_timestamp)) AS quarter,
        ROUND(SUM(payment_value),2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY quarter
ORDER BY quarter;

-- 20. Monthly Average Order Value
SELECT
    DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(AVG(payment_value),2) AS average_order_value
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY month
ORDER BY month;


-- CUSTOMER ANALYTICS

-- 21. Top 10 Customers by Total Spending
SELECT 
	c.customer_unique_id,
    ROUND(SUM(p.payment_value),2) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- 22. Top 10 Customers by Number of Orders
SELECT 
	c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;

-- 23. Repeat Customers
SELECT
	COUNT(*) AS repeat_customers
FROM ( SELECT
	customer_unique_id
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(o.order_id)>1
) repeat_customer_list;

-- 24. One-Time Customers
SELECT
	COUNT(*) AS one_time_customers
FROM ( SELECT
	customer_unique_id
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(o.order_id)=1
) one_time_customers;

-- 25. Average Customer Lifetime Value (CLV)
SELECT
    ROUND(AVG(total_spent),2) AS average_customer_lifetime_value
FROM
(
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
) CLV;

-- 26. Top 10 States by Revenue
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;

-- 27. Top 10 Cities by Revenue
SELECT
	c.customer_city,
    ROUND(SUM(payment_value),2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN payments p
ON o.order_id=p.order_id
GROUP BY c.customer_city
ORDER BY revenue DESC
LIMIT 10;

-- 28. Monthly New Customers 
SELECT 
	DATE_FORMAT(order_purchase_timestamp, '%y-%m') AS month,
    COUNT(DISTINCT customer_id) AS new_customers
FROM orders
GROUP BY month
ORDER BY month;

-- 29. Customer Ranking by Spending (Window Function)
SELECT
    customer_unique_id,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS customer_rank
FROM
(
    SELECT
        c.customer_unique_id,
        ROUND(SUM(p.payment_value),2) AS total_spent
    FROM customers c
    JOIN orders o
    ON c.customer_id=o.customer_id
    JOIN payments p
    ON o.order_id=p.order_id
    GROUP BY c.customer_unique_id
) ranking;

-- 30. Customer Segmentation by Spending
	SELECT
		customer_unique_id,
		total_spent,
		
		CASE
			WHEN total_spent >=1000 THEN 'VIP'
			WHEN total_spent >=500 THEN 'Premium'
			WHEN total_spent >=200 THEN 'Regular'
			ELSE 'Low Value'
		END AS customer_segment
	FROM(
		SELECT
			c.customer_unique_id,
			SUM(p.payment_value) AS total_spent
		FROM customers c
		JOIN orders o
		ON c.customer_id=o.customer_id
		JOIN payments p
		ON o.order_id=p.order_id
		GROUP BY c.customer_unique_id
	) segment
	ORDER BY total_spent DESC;  








