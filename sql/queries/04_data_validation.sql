USE retail_business_intelligence;

-- DATA QUALITY VALIDATION
-- Row Count

SELECT 'customers' AS table_name, COUNT(*) AS rowss FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;

-- NULL VALUE CHECKS

SELECT COUNT(*) AS null_customer_id
FROM customers
WHERE customer_id IS NULL;

SELECT COUNT(*) AS null_order_id
FROM orders
WHERE order_id IS NULL;

SELECT COUNT(*) AS null_product_id
FROM products
WHERE product_id IS NULL;

SELECT COUNT(*) AS null_seller_id
FROM sellers
WHERE seller_id IS NULL;


-- DUPLICATE CHECKS

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Negative Prices

SELECT *
FROM order_items
WHERE price < 0;

-- Negative Freight

SELECT *
FROM order_items
WHERE freight_value < 0;

-- Invalid Review Scores

SELECT *
FROM reviews
WHERE review_score NOT BETWEEN 1 AND 5;

-- Negative Payment

SELECT *
FROM payments
WHERE payment_value < 0;

-- DATE VALIDATION

SELECT *
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- REFERENTIAL INTEGRITY CHECKS

SELECT COUNT(*)
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*)
FROM order_items oi
LEFT JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*)
FROM order_items oi
LEFT JOIN sellers s
ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

SELECT 'DATA VALIDATION COMPLETED' AS STATUS;