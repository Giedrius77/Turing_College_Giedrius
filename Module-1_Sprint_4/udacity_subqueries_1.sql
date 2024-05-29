-- 1. Provide the name of the sales_rep in each region 
-- with the largest amount of total_amt_usd sales.

/* 1st STEP: 
First, I wanted to find the total_amt_usd totals associated with each sales rep, 
and I also wanted the region in which they were located. The query below provided this information.*/
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

/* 2nd STEP:
Next, I pulled the max for each region, and then we can use this to pull those rows in our final result.*/
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

/* 3rd STEP:
Essentially, this is a JOIN of these two tables, where the region and amount match.*/

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

/* 4th STEP - using WITH */

WITH t1 AS (SELECT sr.name AS sale_rep_name, r.name AS region_name, SUM(o.total_amt_usd) AS total_amt_usd
                FROM sales_reps AS sr
                JOIN region AS r
                ON sr.region_id = r.id
                JOIN accounts AS a
                ON a.sales_rep_id = sr.id
                JOIN orders AS o
                ON o.account_id = a.id
                GROUP BY 1, 2
                ORDER BY 3 DESC)

SELECT t1.sale_rep_name, t1.region_name, t1.total_amt_usd
FROM (SELECT region_name, MAX(total_amt_usd) AS total_amt_usd
        FROM t1
        GROUP BY 1) t2
JOIN t1
ON t1.region_name = t2.region_name AND t1.total_amt_usd = t2.total_amt_usd;

/* Udacity */

WITH t1 AS (
     SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
      FROM sales_reps s
      JOIN accounts a
      ON a.sales_rep_id = s.id
      JOIN orders o
      ON o.account_id = a.id
      JOIN region r
      ON r.id = s.region_id
      GROUP BY 1,2
      ORDER BY 3 DESC), 
t2 AS (
      SELECT region_name, MAX(total_amt) total_amt
      FROM t1
      GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;