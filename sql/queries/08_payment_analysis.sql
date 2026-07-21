USE retail_business_intelligence;

-- =====================================================
-- PAYMENT ANALYSIS
-- =====================================================

-- Q51. Revenue by Payment Type

SELECT
    payment_type,
    ROUND(SUM(payment_value),2) AS revenue
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;

-- =====================================================

-- Q52. Number of Transactions by Payment Type

SELECT
    payment_type,
    COUNT(*) AS transactions
FROM payments
GROUP BY payment_type
ORDER BY transactions DESC;

-- =====================================================

-- Q53. Average Payment Value by Payment Type

SELECT
    payment_type,
    ROUND(AVG(payment_value),2) AS avg_payment
FROM payments
GROUP BY payment_type
ORDER BY avg_payment DESC;

-- =====================================================

-- Q54. Average Installments by Payment Type

SELECT
    payment_type,
    ROUND(AVG(payment_installments),2) AS avg_installments
FROM payments
GROUP BY payment_type
ORDER BY avg_installments DESC;

-- =====================================================

-- Q55. Top 10 Highest Payments

SELECT
    order_id,
    payment_type,
    payment_value
FROM payments
ORDER BY payment_value DESC
LIMIT 10;

-- =====================================================

-- Q56. Monthly Revenue by Payment Type

SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    p.payment_type,
    ROUND(SUM(p.payment_value),2) AS revenue
FROM payments p
JOIN orders o
ON p.order_id = o.order_id
GROUP BY month,p.payment_type
ORDER BY month,revenue DESC;

-- =====================================================

-- Q57. Payment Type Contribution %

SELECT
    payment_type,
    ROUND(SUM(payment_value),2) AS revenue,
    ROUND(
        SUM(payment_value)*100/
        (SELECT SUM(payment_value) FROM payments),
        2
    ) AS contribution_percentage
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;

-- =====================================================

-- Q58. Payment Installment Distribution

SELECT
    payment_installments,
    COUNT(*) AS total_orders
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;

-- =====================================================

-- Q59. Ranking Payment Types by Revenue

SELECT
    payment_type,
    revenue,
    DENSE_RANK() OVER(ORDER BY revenue DESC) AS revenue_rank
FROM
(
    SELECT
        payment_type,
        SUM(payment_value) AS revenue
    FROM payments
    GROUP BY payment_type
) t;

-- =====================================================

-- Q60. Monthly Average Payment Value

SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(AVG(p.payment_value),2) AS avg_payment
FROM payments p
JOIN orders o
ON p.order_id = o.order_id
GROUP BY month
ORDER BY month;