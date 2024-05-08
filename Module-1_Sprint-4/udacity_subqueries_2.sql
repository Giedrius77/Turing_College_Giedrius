-- 2. For the region with the largest (sum) of sales total_amt_usd, 
-- how many total (count) orders were placed?

SELECT r.name AS region_name, 
    SUM(o.total_amt_usd) AS max_total_amt_usd, 
    COUNT(o.id) AS total_order
FROM sales_reps AS sr
JOIN region AS r
ON sr.region_id = r.id
JOIN accounts AS a
ON a.sales_rep_id = sr.id
JOIN orders AS o
ON o.account_id = a.id
GROUP BY region_name
ORDER BY max_total_amt_usd DESC;

-- Udacity solution
SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name;