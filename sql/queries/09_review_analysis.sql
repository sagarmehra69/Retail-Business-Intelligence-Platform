USE retail_business_intelligence;

-- 61. Average Review Score
SELECT
    ROUND(AVG(review_score),2) AS average_review_score
FROM reviews;

-- 62. Review Score Distribution
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score DESC;

-- 63. Monthly Average Review Score
SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(AVG(r.review_score),2) AS average_rating
FROM reviews r
JOIN orders o
ON r.order_id = o.order_id
GROUP BY month
ORDER BY month;

-- 64. Top 10 Highest Rated Product Categories
SELECT
    ct.product_category_name_english,
    ROUND(AVG(r.review_score),2) AS average_rating
FROM reviews r
JOIN orders o
ON r.order_id = o.order_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
HAVING COUNT(*) >= 20
ORDER BY average_rating DESC
LIMIT 10;

-- 65. Top 10 Lowest Rated Product Categories

SELECT
    ct.product_category_name_english,
    ROUND(AVG(r.review_score),2) AS average_rating
FROM reviews r
JOIN orders o
ON r.order_id = o.order_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
HAVING COUNT(*) >= 20
ORDER BY average_rating ASC
LIMIT 10;

-- 66. Review Score by Seller
SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score),2) AS average_rating
FROM reviews r
JOIN orders o
ON r.order_id = o.order_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY oi.seller_id
ORDER BY average_rating DESC
LIMIT 10;

-- 67. Rating Distribution Percentage
SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM reviews),
        2
    ) AS percentage
FROM reviews
GROUP BY review_score
ORDER BY review_score;

-- 68. Orders with 1-Star Reviews
SELECT
    order_id,
    review_score
FROM reviews
WHERE review_score = 1;

-- 69. Ranking Product Categories by Rating
SELECT
    category,
    average_rating,
    DENSE_RANK() OVER(ORDER BY average_rating DESC) AS rating_rank
FROM
(
    SELECT
        ct.product_category_name_english AS category,
        ROUND(AVG(r.review_score),2) AS average_rating
    FROM reviews r
    JOIN orders o
    ON r.order_id = o.order_id
    JOIN order_items oi
    ON o.order_id = oi.order_id
    JOIN products p
    ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
    GROUP BY category
) t;

-- 70. Customer Satisfaction KPI
SELECT
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END) AS satisfied_customers,
    ROUND(
        SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END)
        *100.0/COUNT(*),
        2
    ) AS satisfaction_percentage
FROM reviews;