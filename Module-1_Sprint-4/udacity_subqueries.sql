-- 1. Provide the name of the sales_rep in each region 
-- with the largest amount of total_amt_usd sales.

/* 1st STEP */
SELECT sr.name AS sale_rep_name, r.name AS region_name, SUM(o.total_amt_usd) AS total_amt_usd
    FROM sales_reps AS sr
    JOIN region AS r
    ON sr.region_id = r.id
    JOIN accounts AS a
    ON a.sales_rep_id = sr.id
    JOIN orders AS o
    ON o.account_id = a.id
GROUP BY 1, 2
ORDER BY 3 DESC;

/* 2nd STEP */
SELECT region_name, MAX(total_amt_usd) AS total_amt_usd
        FROM (SELECT sr.name AS sale_rep_name, r.name AS region_name, SUM(o.total_amt_usd) AS total_amt_usd
                FROM sales_reps AS sr
                JOIN region AS r
                ON sr.region_id = r.id
                JOIN accounts AS a
                ON a.sales_rep_id = sr.id
                JOIN orders AS o
                ON o.account_id = a.id
                GROUP BY 1, 2) t1
        GROUP BY 1;

/* 3rd STEP */
SELECT t3.sale_rep_name, t3.region_name, t3.total_amt_usd
FROM(SELECT region_name, MAX(total_amt_usd) AS total_amt_usd
        FROM (SELECT sr.name AS sale_rep_name, r.name AS region_name, SUM(o.total_amt_usd) AS total_amt_usd
                FROM sales_reps AS sr
                JOIN region AS r
                ON sr.region_id = r.id
                JOIN accounts AS a
                ON a.sales_rep_id = sr.id
                JOIN orders AS o
                ON o.account_id = a.id
                GROUP BY 1, 2) t1
        GROUP BY 1) t2
JOIN (SELECT sr.name AS sale_rep_name, r.name AS region_name, SUM(o.total_amt_usd) AS total_amt_usd
        FROM sales_reps AS sr
        JOIN region AS r
        ON sr.region_id = r.id
        JOIN accounts AS a
        ON a.sales_rep_id = sr.id
        JOIN orders AS o
        ON o.account_id = a.id
        GROUP BY 1, 2
        ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt_usd = t2.total_amt_usd;

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

-- 3. How many accounts had more total purchases than the account name 
-- which has bought the most standard_qty paper throughout their lifetime as a customer?


-- 4. For the customer that spent the most (in total over their lifetime as a customer) 
-- total_amt_usd, how many web_events did they have for each channel?


-- 5. What is the lifetime average amount spent in terms of total_amt_usd 
-- for the top 10 total spending accounts?


-- 6. What is the lifetime average amount spent in terms of total_amt_usd, 
-- including only the companies that spent more per order, on average, than the average of all orders.