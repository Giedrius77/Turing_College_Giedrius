-- 3. How many accounts had more total purchases than the account name 
-- which has bought the most standard_qty paper throughout their lifetime as a customer?

/* 1st STEP:
First, we want to find the account that had the most standard_qty paper. 
The query here pulls that account, as well as the total amount:*/

SELECT a.name AS account_name, SUM(o.standard_qty) AS total_standard_paper, SUM(o.total) AS total
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

/* 2nd STEP:
Now, I want to use this to pull all the accounts with more total sales when total standard_qty paper :*/

SELECT a.name AS account_name
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                      FROM (SELECT a.name AS account_name, SUM(o.standard_qty) AS total_standard_paper, SUM(o.total) AS total
                            FROM orders AS o
                            JOIN accounts AS a
                            ON o.account_id = a.id
                            GROUP BY 1
                            ORDER BY 2 DESC
                            LIMIT 1) t1);

/* 3rd STEP:
This is now a list of all the accounts with more total orders. 
We can get the count with just another simple subquery.*/

SELECT COUNT(*)
FROM (SELECT a.name AS account_name
        FROM orders AS o
        JOIN accounts AS a
        ON o.account_id = a.id
        GROUP BY 1
        HAVING SUM(o.total) > (SELECT total
                            FROM (SELECT a.name AS account_name, SUM(o.standard_qty) AS total_standard_paper, SUM(o.total) AS total
                                    FROM orders AS o
                                    JOIN accounts AS a
                                    ON o.account_id = a.id
                                    GROUP BY 1
                                    ORDER BY 2 DESC
                                    LIMIT 1) t1)) t2;

/* 4th STEP using WITH */

WITH t1 AS (SELECT a.name AS account_name, 
                SUM(o.standard_qty) AS total_standard_paper, 
                SUM(o.total) AS total
                        FROM orders AS o
                        JOIN accounts AS a
                        ON o.account_id = a.id
                        GROUP BY 1
                        ORDER BY 2 DESC
                        LIMIT 1),
t2 AS (SELECT a.name AS account_name
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total FROM t1))

SELECT COUNT(*)
FROM t2;

/* Udacity */

WITH t1 AS (
      SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
      FROM accounts a
      JOIN orders o
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1), 
t2 AS (
      SELECT a.name
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY 1
      HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;