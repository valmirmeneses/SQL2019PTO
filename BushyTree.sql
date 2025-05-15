USE AdventureWorks;
GO
DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO

SELECT 
    p.Name AS ProductName, 
    s.Name AS SubcategoryName, 
    c.Name AS CategoryName, 
    v.Name AS VendorName
FROM 
    Production.Product p
INNER JOIN 
    Production.ProductSubcategory s ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN 
    Production.ProductCategory c ON s.ProductCategoryID = c.ProductCategoryID
INNER JOIN 
    Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
INNER JOIN 
    Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID;
