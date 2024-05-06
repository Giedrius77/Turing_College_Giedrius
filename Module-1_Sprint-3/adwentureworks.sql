-- 1. An overview of Products

-- 1.1 You’ve been asked to extract the data on products from the Product table where there exists a product subcategory. And also include the name of the ProductSubcategory.

-- Columns needed: ProductId, Name, ProductNumber, size, color, ProductSubcategoryId, Subcategory name.
-- Order results by SubCategory name.

SELECT p.ProductID, p.Name, p.ProductNumber, p.Size, p.Color, psc.ProductSubcategoryID, psc.Name AS SubCategory
FROM `tc-da-1.adwentureworks_db.product` AS p
JOIN `tc-da-1.adwentureworks_db.productsubcategory` AS psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
ORDER BY SubCategory
LIMIT 5;

-- 1.2 In 1.1 query you have a product subcategory but see that you could use the category name.

-- Find and add the product category name.
-- Afterwards order the results by Category name.

SELECT p.ProductID, p.Name, p.ProductNumber, p.Size, p.Color, psc.ProductSubcategoryID, psc.Name AS SubCategoryName, pc.Name AS Category
FROM `tc-da-1.adwentureworks_db.product` AS p
JOIN `tc-da-1.adwentureworks_db.productsubcategory` AS psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN `tc-da-1.adwentureworks_db.productcategory` AS pc
ON psc.ProductCategoryID = pc.ProductCategoryID
ORDER BY pc.Name
LIMIT 5;

-- 1.3 Use the established query to select the most expensive (price listed over 2000) bikes that are still actively sold (does not have a sales end date)

-- Order the results from most to least expensive bike.

SELECT p.ProductID, p.Name, p.ProductNumber, p.ListPrice, psc.Name AS SubCategory, pc.Name AS Category
FROM `tc-da-1.adwentureworks_db.product` AS p
JOIN `tc-da-1.adwentureworks_db.productsubcategory` AS psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN `tc-da-1.adwentureworks_db.productcategory` AS pc
ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE (pc.Name = 'Bikes' AND p.ListPrice > 2000) AND p.SellEndDate IS NULL
ORDER BY p.ListPrice DESC
LIMIT 5;

-- Rows counts per individual tables

SELECT 
    (SELECT COUNT(*) FROM `tc-da-1.adwentureworks_db.product`) AS Total_ProductID,
    (SELECT COUNT(*) FROM `tc-da-1.adwentureworks_db.productsubcategory`) AS Total_ProductSubcategoryID,
    (SELECT COUNT(*) FROM `tc-da-1.adwentureworks_db.productcategory`) AS Total_ProductCategoryID
    

-- 2. Reviewing work orders

-- 2.1 Create an aggregated query to select the:

-- Number of unique work orders.
-- Number of unique products.
-- Total actual cost.
-- For each location Id from the 'workoderrouting' table for orders in January 2004.

SELECT l.LocationID, COUNT(wo.OrderQty) AS no_work_orders, COUNT(DISTINCT p.Name) AS no_unique_product, SUM(wor.ActualCost) AS actual_cost
FROM `tc-da-1.adwentureworks_db.workorderrouting` AS wor
JOIN `tc-da-1.adwentureworks_db.location` AS l
ON wor.LocationID = l.LocationID
JOIN `tc-da-1.adwentureworks_db.workorder` AS wo
ON wor.WorkOrderID = wo.WorkOrderID
JOIN `tc-da-1.adwentureworks_db.product` AS p
ON wo.ProductID = p.ProductID
WHERE wor.ModifiedDate BETWEEN '2004-01-01' AND '2004-02-01'
GROUP BY l.LocationID
ORDER BY SUM(wor.ActualCost) DESC;

-- 2.2 Update your 2.1 query by adding the name of the location 
-- and also add the average days amount between actual start date and actual end date per each location.

SELECT l.LocationID, l.Name, 
  COUNT(wo.OrderQty) AS no_work_orders, 
  COUNT(DISTINCT p.Name) AS no_unique_product, 
  SUM(wor.ActualCost) AS actual_cost, 
  CAST(AVG(DATE_DIFF(wor.ActualEndDate, wor.ActualStartDate, day))AS DECIMAL) AS avg_days_diff
FROM `tc-da-1.adwentureworks_db.workorderrouting` AS wor
  JOIN `tc-da-1.adwentureworks_db.product` AS p
  ON wor.ProductID = p.ProductID
  JOIN `tc-da-1.adwentureworks_db.location` AS l
  ON wor.LocationID = l.LocationID
  JOIN `tc-da-1.adwentureworks_db.workorder` AS wo
  ON wor.WorkOrderID = wo.WorkOrderID
WHERE wor.ModifiedDate BETWEEN '2004-01-01' AND '2004-02-01'
GROUP BY l.LocationID, l.Name
ORDER BY SUM(wor.ActualCost) DESC;

-- 2.3 Select all the expensive work Orders (above 300 actual cost) that happened throught January 2004.
-- I can't find right solution regard ActualCost above 300!!!! 

SELECT wo.WorkOrderID AS WorkOrderID, wor.ActualCost AS actual_cost
FROM `tc-da-1.adwentureworks_db.workorderrouting` AS wor
JOIN `tc-da-1.adwentureworks_db.workorder` AS wo
ON wor.WorkOrderID = wo.WorkOrderID 
-- JOIN `adwentureworks_db.product`AS p
-- ON wo.ProductID = p.ProductID
-- JOIN `adwentureworks_db.transactionhistory` AS th
-- ON th.ProductID = p.ProductID
-- JOIN `adwentureworks_db.transactionhistoryarchive` AS tha
-- ON th.TransactionID = tha.TransactionID
WHERE wor.ModifiedDate BETWEEN '2004-01-01' AND '2004-02-01'
ORDER BY actual_cost
LIMIT 5;
-- WHERE wor.ActualCost > 300 AND


-- Task 3. Query validation

-- Below you will find 2 queries that need to be fixed/updated.
-- Doubleclick on the cell of the query and you will see it in the original format, copy it into your Bigquery interface and try to fix it there.
-- Once you have it fixed, copy into your spreadsheet of results among previous task results.

-- 3.1 Your colleague has written a query to find the list of orders connected to special offers. The query works fine but the numbers are off, investigate where the potential issue lies.

-- First JOIN path was inccorect, instead of productID must be SpecialOfferID

SELECT sales_detail.SalesOrderId
,sales_detail.OrderQty
,sales_detail.UnitPrice
,sales_detail.LineTotal
,sales_detail.ProductId
,sales_detail.SpecialOfferID
,spec_offer_product.ModifiedDate
,spec_offer.Category
,spec_offer.Description

FROM `tc-da-1.adwentureworks_db.salesorderdetail` AS sales_detail

LEFT JOIN `tc-da-1.adwentureworks_db.specialofferproduct` AS spec_offer_product
ON sales_detail.SpecialOfferID = spec_offer_product.SpecialOfferID

LEFT JOIN `tc-da-1.adwentureworks_db.specialoffer` AS spec_offer
ON sales_detail.SpecialOfferID = spec_offer.SpecialOfferID

ORDER BY LineTotal DESC
LIMIT 20;


-- 3.2 Your colleague has written this query to collect basic Vendor information. The query does not work, look into the query and find ways to fix it. Can you provide any feedback on how to make this query be easier to debug/read?

-- Fixed and debugged: make all allies easy to read, complete all joins based on SELECT query.

SELECT vendor.VendorID AS NameID
,vendor.Name
,vendor.CreditRating
,vendor.ActiveFlag
,vendor_contact.ContactId
,contacttype.ContactTypeId
,vendoraddress.AddressId
,address.City

FROM `tc-da-1.adwentureworks_db.vendor` AS vendor

JOIN `tc-da-1.adwentureworks_db.vendorcontact` AS vendor_contact 
ON vendor.VendorID = vendor_contact.VendorID

LEFT JOIN `tc-da-1.adwentureworks_db.contacttype` AS contacttype
ON vendor_contact.ContactTypeID = contacttype.ContactTypeID

LEFT JOIN `tc-da-1.adwentureworks_db.vendoraddress` AS vendoraddress
ON vendor.VendorID = vendoraddress.VendorID

LEFT JOIN `tc-da-1.adwentureworks_db.address` AS address 
ON vendoraddress.AddressID = address.AddressID

ORDER BY NameID
LIMIT 5;