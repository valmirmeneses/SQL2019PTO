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
    c.Name AS CategoryName
FROM 
    Production.ProductCategory c
INNER JOIN 
    Production.ProductSubcategory s ON c.ProductCategoryID = s.ProductCategoryID
INNER JOIN 
    Production.Product p ON s.ProductSubcategoryID = p.ProductSubcategoryID;
