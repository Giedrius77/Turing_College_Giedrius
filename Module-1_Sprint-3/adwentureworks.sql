-- 1. An overview of Products

-- 1.1 You’ve been asked to extract the data on products from the Product table where there exists a product subcategory. And also include the name of the ProductSubcategory.

-- Columns needed: ProductId, Name, ProductNumber, size, color, ProductSubcategoryId, Subcategory name.
-- Order results by SubCategory name.

SELECT p.ProductID, p.Name, p.ProductNumber, p.Size, p.Color, psc.ProductSubcategoryID, psc.Name AS SubCategory
FROM `tc-da-1.adwentureworks_db.product` AS p
JOIN `adwentureworks_db.productsubcategory` AS psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
ORDER BY SubCategory
LIMIT 5;

-- 1.2 In 1.1 query you have a product subcategory but see that you could use the category name.

-- Find and add the product category name.
-- Afterwards order the results by Category name.

SELECT p.ProductID, p.Name, p.ProductNumber, p.Size, p.Color, psc.ProductSubcategoryID, psc.Name AS SubCategoryName, pc.Name AS Category
FROM `tc-da-1.adwentureworks_db.product` AS p
JOIN `adwentureworks_db.productsubcategory` AS psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN `adwentureworks_db.productcategory` AS pc
ON psc.ProductCategoryID = pc.ProductCategoryID
ORDER BY pc.Name
LIMIT 5;

-- 1.3 Use the established query to select the most expensive (price listed over 2000) bikes that are still actively sold (does not have a sales end date)

-- Order the results from most to least expensive bike.

SELECT p.ProductID, p.Name, p.ProductNumber, p.ListPrice, psc.Name AS SubCategory, pc.Name AS Category
FROM `tc-da-1.adwentureworks_db.product` AS p
JOIN `adwentureworks_db.productsubcategory` AS psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN `adwentureworks_db.productcategory` AS pc
ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE (pc.Name = 'Bikes' AND p.ListPrice > 2000) AND p.SellEndDate IS NULL
ORDER BY p.ListPrice DESC
LIMIT 5;

-- Rows counts per individual tables

SELECT 
    (SELECT COUNT(*) FROM `tc-da-1.adwentureworks_db.product`) AS Total_ProductID,
    (SELECT COUNT(*) FROM `adwentureworks_db.productsubcategory`) AS Total_ProductSubcategoryID,
    (SELECT COUNT(*) FROM `adwentureworks_db.productcategory`) AS Total_ProductCategoryID
    

-- 2. Reviewing work orders

-- 2.1 Create an aggregated query to select the:

-- Number of unique work orders.
-- Number of unique products.
-- Total actual cost.
-- For each location Id from the 'workoderrouting' table for orders in January 2004.

