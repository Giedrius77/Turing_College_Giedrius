-- Task - 1

-- 1.1 You’ve been tasked to create a detailed overview of all individual customers (these are defined by customerType = ‘I’ and/or stored in an individual table). Write a query that provides:

-- Identity information : CustomerId, Firstname, Last Name, FullName (First Name & Last Name).
-- An Extra column called addressing_title i.e. (Mr. Achong), if the title is missing - Dear Achong.
-- Contact information : Email, phone, account number, CustomerType.
-- Location information : City, State & Country, address.
-- Sales: number of orders, total amount (with Tax), date of the last order.

-- Copy only the top 200 rows from your written select ordered by total amount (with tax).
-- Hint: Few customers have multiple addresses, to avoid duplicate data take their latest available address by choosing max(AddressId)

WITH 
customer AS (SELECT cus.CustomerID,con.Firstname,con.LastName,
CONCAT(con.Firstname, ' ', con.LastName) AS full_name,
CASE WHEN con.Title IS NOT NULL THEN CONCAT(con.Title, ' ', con.LastName) ELSE CONCAT('Dear', ' ', con.LastName) END AS addressing_title,
con.EmailAddress,
con.Phone,
cus.AccountNumber,
cus.CustomerType
FROM `adwentureworks_db.customer` AS cus
JOIN `adwentureworks_db.individual` AS ind ON cus.CustomerID = ind.CustomerID
JOIN `adwentureworks_db.contact` AS con ON ind.ContactID = con.ContactId),

address AS (SELECT cus_add.CustomerID,addr.city, addr.AddressLine1, addr.AddressLine2, sta_pro.Name AS State, cou_reg.Name AS Country,cus_add.ModifiedDate,
ROW_NUMBER() OVER (PARTITION BY cus_add.CustomerID ORDER BY cus_add.AddressID DESC) AS number
FROM `adwentureworks_db.customeraddress` AS cus_add
JOIN `adwentureworks_db.address` AS addr ON cus_add.AddressID = addr.AddressID
JOIN `adwentureworks_db.stateprovince` AS sta_pro ON addr.StateProvinceID = sta_pro.StateProvinceID
JOIN `adwentureworks_db.countryregion` AS cou_reg ON sta_pro.CountryRegionCode = cou_reg.CountryRegionCode),

sales AS (SELECT header.CustomerID, COUNT(header.SalesOrderID) AS number_orders, ROUND(SUM(header.TotalDue),3) AS total_amount, MAX(header.OrderDate) AS date_last_order
FROM `adwentureworks_db.salesorderheader` AS header
GROUP BY header.CustomerID)

SELECT c.*, a.* EXCEPT (CustomerID, ModifiedDate, number), s.* EXCEPT (CustomerID)
FROM customer AS c
JOIN address AS a ON c.CustomerID = a.CustomerID
JOIN sales AS s ON c.CustomerID = s.CustomerID
ORDER BY s.total_amount DESC
LIMIT 200;

-- 1.2 Business finds the original query valuable to analyze customers and now want to get the data from the first query for the top 200 customers with the highest total amount (with tax) who have not ordered for the last 365 days. How would you identify this segment?
-- Hints:
-- You can use temp table, cte and/or subquery of the 1.1 select.
-- Note that the database is old and the current date should be defined by finding the latest order date in the orders table.

WITH 
customer AS (SELECT cus.CustomerID,con.Firstname,con.LastName,
CONCAT(con.Firstname, ' ', con.LastName) AS full_name,
CASE WHEN con.Title IS NOT NULL THEN CONCAT(con.Title, ' ', con.LastName) ELSE CONCAT('Dear', ' ', con.LastName) END AS addressing_title,
con.EmailAddress,
con.Phone,
cus.AccountNumber,
cus.CustomerType
FROM `adwentureworks_db.customer` AS cus
JOIN `adwentureworks_db.individual` AS ind ON cus.CustomerID = ind.CustomerID
JOIN `adwentureworks_db.contact` AS con ON ind.ContactID = con.ContactId),

sales AS (SELECT header.CustomerID, COUNT(header.SalesOrderID) AS number_orders, ROUND(SUM(header.TotalDue),3) AS total_amount, MAX(header.OrderDate) AS date_last_order
FROM `adwentureworks_db.salesorderheader` AS header
GROUP BY header.CustomerID)

SELECT c.full_name, s.total_amount, s.date_last_order AS last_year_order
FROM customer AS c
JOIN sales AS s ON c.CustomerID = s.CustomerID
WHERE (s.date_last_order < (SELECT MAX(OrderDate) - INTERVAL 365 DAY FROM adwentureworks_db.salesorderheader))
ORDER BY s.total_amount DESC
LIMIT 200;



-- 1.3 Enrich your original 1.1 SELECT by creating a new column in the view that marks active & inactive customers based on whether they have ordered anything during the last 365 days.
-- Copy only the top 500 rows from your written select ordered by CustomerId desc.

WITH 
customer AS (SELECT cus.CustomerID,con.Firstname,con.LastName,
CONCAT(con.Firstname, ' ', con.LastName) AS full_name,
CASE WHEN con.Title IS NOT NULL THEN CONCAT(con.Title, ' ', con.LastName) ELSE CONCAT('Dear', ' ', con.LastName) END AS addressing_title,
con.EmailAddress,
con.Phone,
cus.AccountNumber,
cus.CustomerType
FROM `adwentureworks_db.customer` AS cus
JOIN `adwentureworks_db.individual` AS ind ON cus.CustomerID = ind.CustomerID
JOIN `adwentureworks_db.contact` AS con ON ind.ContactID = con.ContactId),

sales AS (SELECT header.CustomerID, COUNT(header.SalesOrderID) AS number_orders, ROUND(SUM(header.TotalDue),3) AS total_amount, MAX(header.OrderDate) AS date_last_order
FROM `adwentureworks_db.salesorderheader` AS header
GROUP BY header.CustomerID)

SELECT c.CustomerID, c.full_name, s.number_orders,
CASE WHEN s.date_last_order >= (SELECT MAX(OrderDate) - INTERVAL 365 DAY FROM adwentureworks_db.salesorderheader) THEN 'Active' ELSE 'Inactive' END AS customer_status
FROM customer AS c
JOIN sales AS s ON c.CustomerID = s.CustomerID
ORDER BY s.CustomerID DESC
LIMIT 500;


-- 1.4 Business would like to extract data on all active customers from North America. Only customers that have either ordered no less than 2500 in total amount (with Tax) or ordered 5 + times should be presented.
-- In the output for these customers divide their address line into two columns, i.e.:
-- Order the output by country, state and date_last_order.

WITH 
customer AS (SELECT cus.CustomerID,con.Firstname,con.LastName,
CONCAT(con.Firstname, ' ', con.LastName) AS full_name,
CASE WHEN con.Title IS NOT NULL THEN CONCAT(con.Title, ' ', con.LastName) ELSE CONCAT('Dear', ' ', con.LastName) END AS addressing_title,
con.EmailAddress,
con.Phone,
cus.AccountNumber,
cus.CustomerType
FROM `adwentureworks_db.customer` AS cus
JOIN `adwentureworks_db.individual` AS ind ON cus.CustomerID = ind.CustomerID
JOIN `adwentureworks_db.contact` AS con ON ind.ContactID = con.ContactId),

address AS (SELECT cus_add.CustomerID,addr.city, addr.AddressLine1, addr.AddressLine2, sta_pro.Name AS State, cou_reg.Name AS Country,cus_add.ModifiedDate,
ROW_NUMBER() OVER (PARTITION BY cus_add.CustomerID ORDER BY cus_add.AddressID DESC) AS number
FROM `adwentureworks_db.customeraddress` AS cus_add
JOIN `adwentureworks_db.address` AS addr ON cus_add.AddressID = addr.AddressID
JOIN `adwentureworks_db.stateprovince` AS sta_pro ON addr.StateProvinceID = sta_pro.StateProvinceID
JOIN `adwentureworks_db.countryregion` AS cou_reg ON sta_pro.CountryRegionCode = cou_reg.CountryRegionCode),

sales AS (SELECT header.CustomerID, COUNT(header.SalesOrderID) AS number_orders, ROUND(SUM(header.TotalDue),3) AS total_amount, MAX(header.OrderDate) AS date_last_order,
CASE WHEN MAX(header.OrderDate) >= (SELECT MAX(OrderDate) - INTERVAL 365 DAY FROM adwentureworks_db.salesorderheader) THEN 'Active' ELSE 'Inactive' END AS customer_status
FROM `adwentureworks_db.salesorderheader` AS header
GROUP BY header.CustomerID)

SELECT c.CustomerID, c.full_name, a.Country, a.AddressLine1, SUBSTR(a.AddressLine1, 0, STRPOS(a.AddressLine1, ' ')-1) AS address_no, 
SUBSTR(a.AddressLine1, STRPOS(a.AddressLine1, ' ')) AS Address_st, s.number_orders, s.total_amount, s.date_last_order
FROM customer AS c
JOIN address AS a ON c.CustomerID = a.CustomerID
JOIN sales AS s ON c.CustomerID = s.CustomerID
WHERE (customer_status = 'Active' AND a.Country IN ('United States', 'Canada')) AND (s.number_orders >= 5 OR s.total_amount >= 2500)
ORDER BY a.Country, a.State, s.date_last_order;

-- Task - 2. Reporting Sales’ numbers
-- Main tables to start from: salesorderheader.

-- 2.1 Create a query of monthly sales numbers in each Country & region. Include in the query a number of orders, customers and sales persons in each month with a total amount with tax earned. Sales numbers from all types of customers are required.
-- Result Hint:

SELECT DATE_SUB(DATE_ADD(DATE_TRUNC(DATE(header.OrderDate), MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY) AS order_month,
CountryRegionCode, Name AS Region, 
COUNT(DISTINCT SalesOrderID) AS number_orders, 
COUNT(DISTINCT customer.CustomerID) AS number_customers,
COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
CAST(SUM(TotalDue) AS INTEGER) AS Total_w_tax
FROM `adwentureworks_db.salesorderheader` AS header
JOIN `adwentureworks_db.salesterritory` AS territory ON header.TerritoryID = territory.TerritoryID
JOIN `adwentureworks_db.customer` AS customer ON header.CustomerID = customer.CustomerID
GROUP BY order_month, CountryRegionCode, Name

-- 2.2 Enrich 2.1 query with the cumulative_sum of the total amount with tax earned per country & region.
-- Hint: use CTE or subquery.
-- Result Hint:

WITH t1 AS (
SELECT DATE_SUB(DATE_ADD(DATE_TRUNC(DATE(header.OrderDate), MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY) AS order_month,
CountryRegionCode, Name AS Region, 
COUNT(DISTINCT SalesOrderID) AS number_orders, 
COUNT(DISTINCT customer.CustomerID) AS number_customers,
COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
CAST(SUM(TotalDue) AS INTEGER) AS Total_w_tax
FROM `adwentureworks_db.salesorderheader` AS header
JOIN `adwentureworks_db.salesterritory` AS territory ON header.TerritoryID = territory.TerritoryID
JOIN `adwentureworks_db.customer` AS customer ON header.CustomerID = customer.CustomerID
GROUP BY order_month, CountryRegionCode, Name)

SELECT t1.*, 
SUM(t1.Total_w_tax) OVER (PARTITION BY t1.CountryRegionCode, t1.Region ORDER BY t1.order_month) AS cumulative_sum
FROM t1;


-- 2.3 Enrich 2.2 query by adding ‘sales_rank’ column that ranks rows from best to worst for each country based on total amount with tax earned each month. I.e. the month where the (US, Southwest) region made the highest total amount with tax earned will be ranked 1 for that region and vice versa.
-- Result Hint (with region filtered on France):

WITH t1 AS (
SELECT DATE_SUB(DATE_ADD(DATE_TRUNC(DATE(header.OrderDate), MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY) AS order_month,
CountryRegionCode, Name AS Region, 
COUNT(DISTINCT SalesOrderID) AS number_orders, 
COUNT(DISTINCT customer.CustomerID) AS number_customers,
COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
CAST(SUM(TotalDue) AS INTEGER) AS Total_w_tax
FROM `adwentureworks_db.salesorderheader` AS header
JOIN `adwentureworks_db.salesterritory` AS territory ON header.TerritoryID = territory.TerritoryID
JOIN `adwentureworks_db.customer` AS customer ON header.CustomerID = customer.CustomerID
GROUP BY order_month, CountryRegionCode, Name)

SELECT t1.*, 
RANK() OVER (PARTITION BY t1.CountryRegionCode, t1.Region ORDER BY t1.Total_w_tax DESC) AS country_sales_rank,
SUM(t1.Total_w_tax) OVER (PARTITION BY t1.CountryRegionCode, t1.Region ORDER BY t1.order_month) AS cumulative_sum
FROM t1


-- 2.4 Enrich 2.3 query by adding taxes on a country level:
-- As taxes can vary in country based on province, the needed column is ‘mean_tax_rate’ -> average tax rate in a country.
-- Also, as not all regions have data on taxes, you also want to be transparent and show the ‘perc_provinces_w_tax’ -> a column representing the percentage of provinces with available tax rates for each country (i.e. If US has 53 provinces, and 10 of them have tax rates, then for US it should show 0,19)

-- Hint: If a state has multiple tax rates, choose the higher one. Do not double count a state in country average rate calculation if it has multiple tax rates.
-- Hint: Ignore the isonlystateprovinceFlag rate mechanic, it is beyond the scope of this exercise. Treat all tax rates as equal.
-- Result Hint (with region filtered on US):

WITH t2 AS
(WITH t1 AS (
SELECT DATE_SUB(DATE_ADD(DATE_TRUNC(DATE(header.OrderDate), MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY) AS order_month,
territory.CountryRegionCode, territory.Name AS Region, 
COUNT(DISTINCT SalesOrderID) AS number_orders, 
COUNT(DISTINCT customer.CustomerID) AS number_customers,
COUNT(DISTINCT SalesPersonID) AS no_salesPersons,
CAST(SUM(TotalDue) AS INTEGER) AS Total_w_tax,
MAX(tax.TaxRate) AS MaxTaxRate
FROM `adwentureworks_db.salesorderheader` AS header
JOIN `adwentureworks_db.salesterritory` AS territory ON header.TerritoryID = territory.TerritoryID
JOIN `adwentureworks_db.customer` AS customer ON header.CustomerID = customer.CustomerID
JOIN `adwentureworks_db.stateprovince` AS province ON territory.TerritoryID = province.TerritoryID
JOIN `adwentureworks_db.salestaxrate` AS tax ON province.StateProvinceID = tax.StateProvinceID
GROUP BY order_month, territory.CountryRegionCode, territory.Name)

SELECT t1.*, 
RANK() OVER (PARTITION BY t1.CountryRegionCode, t1.Region ORDER BY t1.Total_w_tax DESC) AS country_sales_rank,
SUM(t1.Total_w_tax) OVER (PARTITION BY t1.CountryRegionCode, t1.Region ORDER BY t1.order_month) AS cumulative_sum
FROM t1),

tax_data AS (
SELECT 
region.Name, province.CountryRegionCode,
ROUND(AVG(TaxRate),1) AS mean_tax_rate,
COUNT(DISTINCT tax.StateProvinceID) AS provinces_with_tax,
ROUND((COUNT(DISTINCT tax.StateProvinceID) / COALESCE(total_provinces.total_provinces, 1)),2) AS perc_provinces_w_tax
FROM `adwentureworks_db.salestaxrate` AS tax
JOIN `adwentureworks_db.stateprovince` AS province ON tax.StateProvinceID = province.StateProvinceID
JOIN `adwentureworks_db.countryregion` AS region ON province.CountryRegionCode = region.CountryRegionCode
LEFT JOIN (SELECT CountryRegionCode, COUNT(DISTINCT StateProvinceID) AS total_provinces
FROM `adwentureworks_db.stateprovince`
GROUP BY CountryRegionCode) AS total_provinces ON province.CountryRegionCode = total_provinces.CountryRegionCode
GROUP BY region.Name, province.CountryRegionCode, total_provinces.total_provinces)

SELECT t2.* EXCEPT(MaxTaxRate), tax_data.mean_tax_rate, tax_data.perc_provinces_w_tax
FROM t2
LEFT JOIN tax_data ON t2.CountryRegionCode = tax_data.CountryRegionCode
-- WHERE t2.CountryRegionCode = 'US'