-- 1. An overview of Products

-- 1.1 You’ve been asked to extract the data on products from the Product table where there exists a product subcategory. And also include the name of the ProductSubcategory.

-- Columns needed: ProductId, Name, ProductNumber, size, color, ProductSubcategoryId, Subcategory name.
-- Order results by SubCategory name.

SELECT p.ProductID, p.Name, p.ProductNumber, p.Size, p.Color, psc.ProductSubcategoryID, psc.Name AS SubCategory
FROM `tc-da-1.adwentureworks_db.product` AS p
JOIN `adwentureworks_db.productsubcategory` AS psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
ORDER BY SubCategory
LIMIT 6;

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