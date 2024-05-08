-- 5. What is the lifetime average amount spent in terms of total_amt_usd 
-- for the top 10 total spending accounts?

/* 1st STEP:
First, we just want to find the top 10 accounts in terms of highest total_amt_usd.*/

SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_amt
FROM accounts AS a
JOIN orders AS o
ON o.account_id = a.id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;

/* 2nd STEP:
Now, we just want the average of these 10 amounts.*/

SELECT ROUND(AVG(total_amt),2) AS avg_total_amt
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_amt
        FROM accounts AS a
        JOIN orders AS o
        ON o.account_id = a.id
        GROUP BY 1, 2
        ORDER BY 3 DESC
        LIMIT 10)t1;