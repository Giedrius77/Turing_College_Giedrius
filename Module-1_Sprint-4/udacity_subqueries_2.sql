-- 2. For the region with the largest (sum) of sales total_amt_usd, 
-- how many total (count) orders were placed?

/*1st STEP:
The first query I wrote was to pull the total_amt_usd for each region.*/
SELECT r.name AS region_name, SUM(o.total_amt_usd) AS total_amt
    FROM orders AS o
    JOIN accounts AS a
    ON o.account_id = a.id
    JOIN sales_reps AS sr
    ON a.sales_rep_id = sr.id
    JOIN region AS r
    ON sr.region_id = r.id
GROUP BY region_name;

/*2nd STEP:
Then we just want the region with the max amount from this table. 
There are two ways I considered getting this amount.
One was to pull the max using a subquery. Another way is to order descending and just pull the top value.*/

SELECT region_name, MAX(total_amt) AS total_amt
    FROM
        (SELECT r.name AS region_name, SUM(o.total_amt_usd) AS total_amt
            FROM orders AS o
            JOIN accounts AS a
            ON o.account_id = a.id
            JOIN sales_reps AS sr
            ON a.sales_rep_id = sr.id
            JOIN region AS r
            ON sr.region_id = r.id
        GROUP BY region_name) t1
GROUP BY 1;

/* OR , same result without subquery */

SELECT r.name AS region_name, SUM(o.total_amt_usd) AS total_amt
    FROM orders AS o
    JOIN accounts AS a
    ON o.account_id = a.id
    JOIN sales_reps AS sr
    ON a.sales_rep_id = sr.id
    JOIN region AS r
    ON sr.region_id = r.id
GROUP BY region_name
ORDER BY total_amt DESC;

/* 3rd STEP:
Finally, we want to pull the total orders for the region with this amount: This provides the Northeast with 2357 orders.*/

SELECT r.name AS region_name, COUNT(o.total) AS total_order
FROM orders AS o
    JOIN accounts AS a
    ON o.account_id = a.id
    JOIN sales_reps AS sr
    ON a.sales_rep_id = sr.id
    JOIN region AS r
    ON sr.region_id = r.id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = (
    SELECT MAX(total_amt) AS total_amt
    FROM
        (SELECT r.name AS region_name, SUM(o.total_amt_usd) AS total_amt
            FROM orders AS o
            JOIN accounts AS a
            ON o.account_id = a.id
            JOIN sales_reps AS sr
            ON a.sales_rep_id = sr.id
            JOIN region AS r
            ON sr.region_id = r.id
        GROUP BY 1) t1);

/* 4th STEP using WITH */

WITH t1 AS (SELECT r.name AS region_name, SUM(o.total_amt_usd) AS total_amt
            FROM orders AS o
            JOIN accounts AS a
            ON o.account_id = a.id
            JOIN sales_reps AS sr
            ON a.sales_rep_id = sr.id
            JOIN region AS r
            ON sr.region_id = r.id
        GROUP BY 1)

SELECT r.name AS region_name, COUNT(o.total) AS total_order
FROM orders AS o
    JOIN accounts AS a
    ON o.account_id = a.id
    JOIN sales_reps AS sr
    ON a.sales_rep_id = sr.id
    JOIN region AS r
    ON sr.region_id = r.id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = 
    (SELECT MAX(total_amt) AS total_amt
      FROM t1);

/* udacity */

WITH t1 AS (
      SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
      FROM sales_reps s
      JOIN accounts a
      ON a.sales_rep_id = s.id
      JOIN orders o
      ON o.account_id = a.id
      JOIN region r
      ON r.id = s.region_id
      GROUP BY r.name), 
t2 AS (
      SELECT MAX(total_amt)
      FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);