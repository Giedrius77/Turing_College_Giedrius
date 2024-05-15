-- 4. For the customer that spent the most (in total over their lifetime as a customer) 
-- total_amt_usd, how many web_events did they have for each channel?

/* 1st STEP:
Here, we first want to pull the customer with the most spent in lifetime value.*/

SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_amt_usd
FROM accounts AS a
JOIN orders AS o
ON o.account_id = a.id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1;

/* 2nd STEP:
Now, we want to look at the number of events on each channel this company had, 
which we can match with just the id.*/

SELECT a.name, we.channel, COUNT(*) AS total_event
FROM accounts AS a
JOIN web_events AS we
ON we.account_id = a.id AND a.id = (SELECT id 
                        FROM(SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_amt_usd
                                FROM accounts AS a
                                JOIN orders AS o
                                ON o.account_id = a.id
                                GROUP BY 1, 2
                                ORDER BY 3 DESC
                                LIMIT 1) t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

/* 4th STEP using WITH */

WITH t1 AS (SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_amt_usd
                FROM accounts AS a
                JOIN orders AS o
                ON o.account_id = a.id
                GROUP BY 1, 2
                ORDER BY 3 DESC
                LIMIT 1)

SELECT a.name, we.channel, COUNT(*) AS total_event
FROM accounts AS a
JOIN web_events AS we
ON we.account_id = a.id AND a.id = (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

/* Udacity */

WITH t1 AS (
      SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
      LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;