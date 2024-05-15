-- 6. What is the lifetime average amount spent in terms of total_amt_usd, 
-- including only the companies that spent more per order, on average, than the average of all orders.

/* 1st STEP:
First, we want to pull the average of all accounts in terms of total_amt_usd:*/

SELECT ROUND(AVG(o.total_amt_usd),2) AS avg_total_amt
FROM orders AS o
;
-- udacity
SELECT AVG(o.total_amt_usd) avg_all 
FROM orders o

/* 2nd STEP:
Then, we want to only pull the accounts with more than this average amount.*/

SELECT o.account_id, a.name, ROUND(AVG(o.total_amt_usd),2) AS avg_total_amt
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY 1, 2
HAVING ROUND(AVG(o.total_amt_usd),2) > (SELECT ROUND(AVG(o.total_amt_usd),2) AS avg_total_amt
                                FROM orders AS o)
ORDER BY 3 DESC;

-- udacity
SELECT o.account_id, AVG(o.total_amt_usd) 
FROM orders o 
GROUP BY 1 
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all 
                                FROM orders o)
ORDER BY 2 DESC;

/*3rd STEP:
Finally, we just want the average of these values.*/

SELECT CAST(AVG(avg_total_amt) AS INTEGER) AS avg_total_avg
FROM (SELECT o.account_id, a.name, ROUND(AVG(o.total_amt_usd),2) AS avg_total_amt
        FROM orders AS o
        JOIN accounts AS a
        ON o.account_id = a.id
    GROUP BY 1, 2
    HAVING ROUND(AVG(o.total_amt_usd),2) > (SELECT ROUND(AVG(o.total_amt_usd),2) AS avg_total_amt
                                                FROM orders AS o)) t1;

-- udacity
SELECT AVG(avg_amt) 
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt 
        FROM orders o 
    GROUP BY 1 
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                    FROM orders o)) temp_table; 

/* 4th STEP using WITH */

/* Udacity */

WITH t1 AS ( SELECT AVG(o.total_amt_usd) avg_all FROM orders o 
    JOIN accounts a ON a.id = o.account_id), 
t2 AS ( SELECT o.account_id, AVG(o.total_amt_usd) avg_amt FROM orders o 
GROUP BY 1 
HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1)) 

SELECT AVG(avg_amt) 
FROM t2