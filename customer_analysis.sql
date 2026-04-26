CREATE DATABASE customer_analysis;
USE customer_analysis;



-- CUSTOMER SHOPPING ANALYSIS (MySQL)
SHOW COLUMNS FROM customer_data;
ALTER TABLE customer_data
CHANGE `ï»¿Customer ID` customer_id INT;

-- Q1. Total revenue by gender
SELECT `Gender`, 
       SUM(`Purchase Amount (USD)`) AS revenue
FROM customer_data
GROUP BY `Gender`;



-- Q2. Customers who used discount but spent above average
SELECT customer_id,
       `Purchase Amount (USD)`
FROM customer_data
WHERE `Discount Applied` = 'Yes'
AND `Purchase Amount (USD)` >= (
    SELECT AVG(`Purchase Amount (USD)`)
    FROM customer_data
);



-- Q3. Top 5 products by average rating
SELECT `Item Purchased`,
       ROUND(AVG(`Review Rating`), 2) AS avg_rating
FROM customer_data
GROUP BY `Item Purchased`
ORDER BY avg_rating DESC
LIMIT 5;



-- Q4. Average purchase by shipping type
SELECT `Shipping Type`,
       ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_purchase
FROM customer_data
WHERE `Shipping Type` IN ('Standard','Express')
GROUP BY `Shipping Type`;


-- Q5. Subscription vs spending
SELECT `Subscription Status`,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_spend,
       ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue
FROM customer_data
GROUP BY `Subscription Status`
ORDER BY total_revenue DESC;


-- Q6. Top 5 products with highest discount usage
SELECT `Item Purchased`,
       ROUND(100 * SUM(CASE WHEN `Discount Applied` = 'Yes' THEN 1 ELSE 0 END)/COUNT(*), 2) AS discount_rate
FROM customer_data
GROUP BY `Item Purchased`
ORDER BY discount_rate DESC
LIMIT 5;



-- Q7. Customer segmentation (New, Returning, Loyal)
WITH customer_type AS (
    SELECT `customer_id`,
           `Previous Purchases`,
           CASE 
               WHEN `Previous Purchases` = 1 THEN 'New'
               WHEN `Previous Purchases` BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM customer_data
)
SELECT customer_segment,
       COUNT(*) AS total_customers
FROM customer_type
GROUP BY customer_segment;



-- Q8. Top 3 products per category
WITH item_counts AS (
    SELECT `Category`,
           `Item Purchased`,
           COUNT(`customer_id`) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY `Category` ORDER BY COUNT(`customer_id`) DESC) AS item_rank
    FROM customer_data
    GROUP BY `Category`, `Item Purchased`
)
SELECT item_rank,
       `Category`,
       `Item Purchased`,
       total_orders
FROM item_counts
WHERE item_rank <= 3;



-- Q9. Repeat buyers vs subscription
SELECT `Subscription Status`,
       COUNT(`customer_id`) AS repeat_buyers
FROM customer_data
WHERE `Previous Purchases` > 5
GROUP BY `Subscription Status`;



-- Q10. Revenue by Age
SELECT 
    CASE 
        WHEN `Age` BETWEEN 18 AND 25 THEN 'Young Adult'
        WHEN `Age` BETWEEN 26 AND 40 THEN 'Adult'
        WHEN `Age` BETWEEN 41 AND 60 THEN 'Middle-aged'
        ELSE 'Senior'
    END AS age_group,
    
    SUM(`Purchase Amount (USD)`) AS total_revenue

FROM customer_data

GROUP BY age_group

ORDER BY total_revenue DESC;

DESCRIBE customer_data;