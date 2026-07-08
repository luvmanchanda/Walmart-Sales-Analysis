-- ==========================================
-- Walmart Project Queries - MySQL
-- ==========================================

-- View all records
SELECT *
FROM walmart;

-- ==========================================
-- Count Total Records
-- ==========================================

SELECT COUNT(*) AS total_records
FROM walmart;

-- ==========================================
-- Count Transactions by Payment Method
-- ==========================================

SELECT
    payment_method,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY payment_method;

-- ==========================================
-- Count Distinct Branches
-- ==========================================

SELECT COUNT(DISTINCT branch) AS total_branches
FROM walmart;

-- ==========================================
-- Find Minimum Quantity Sold
-- ==========================================

SELECT MIN(quantity) AS minimum_quantity
FROM walmart;

-- ==========================================
-- Q1. Find Different Payment Methods,
-- Number of Transactions and Quantity Sold
-- ==========================================

SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

-- ==========================================
-- Q2. Highest Rated Category in Each Branch
-- ==========================================

SELECT
    branch,
    category,
    avg_rating
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY AVG(rating) DESC
        ) AS rnk
    FROM walmart
    GROUP BY branch, category
) ranked
WHERE rnk = 1;

-- ==========================================
-- Q3. Busiest Day for Each Branch
-- ==========================================

SELECT
    branch,
    day_name,
    total_transactions
FROM (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date,'%d/%m/%Y')) AS day_name,
        COUNT(*) AS total_transactions,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM walmart
    GROUP BY branch, day_name
) ranked
WHERE rnk = 1;

-- If 'date' column is already DATE datatype,
-- replace:
-- DAYNAME(STR_TO_DATE(date,'%d/%m/%Y'))
-- with:
-- DAYNAME(date)

-- ==========================================
-- Q4. Total Quantity Sold per Payment Method
-- ==========================================

SELECT
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

-- ==========================================
-- Q5. Average, Minimum and Maximum Rating
-- by City and Category
-- ==========================================

SELECT
    city,
    category,
    MIN(rating) AS minimum_rating,
    MAX(rating) AS maximum_rating,
    ROUND(AVG(rating),2) AS average_rating
FROM walmart
GROUP BY city, category
ORDER BY city, category;

-- ==========================================
-- Q6. Total Profit by Category
-- (Assumes profit_margin is stored as decimal,
-- e.g. 0.20 = 20%)
-- ==========================================

SELECT
    category,
    ROUND(SUM(unit_price * quantity * profit_margin),2) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- If profit_margin is stored as 20 instead of 0.20,
-- use:
-- unit_price * quantity * (profit_margin/100)

-- ==========================================
-- Q7. Most Common Payment Method
-- for Each Branch
-- ==========================================

WITH payment_cte AS
(
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER
        (
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
)

SELECT
    branch,
    payment_method AS preferred_payment_method
FROM payment_cte
WHERE rnk = 1;

-- ==========================================
-- Q8. Sales Shift Analysis
-- ==========================================

SELECT
    branch,
    CASE
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, total_invoices DESC;

-- If time column is already TIME datatype,
-- replace HOUR(TIME(time))
-- with HOUR(time)

-- ==========================================


-- ==========================================
-- Notes
-- ==========================================
-- 1. If 'date' is already DATE datatype,
--    remove STR_TO_DATE() from all queries.
--
-- 2. If 'time' is already TIME datatype,
--    use HOUR(time) instead of HOUR(TIME(time)).
--
-- 3. If your dataset contains only one year's data,
--    Q9 will not return meaningful results.
--
-- 4. Avoid using reserved words like 'rank'
--    as aliases; use 'rnk' instead.