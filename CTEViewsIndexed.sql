
-- CTE rewritten using views
-- CTE 1
SET STATISTICS IO, TIME, XML ON;
GO
DBCC FREEPROCCACHE 
GO
IF OBJECT_ID('[Sales].[Sales]', 'V') IS NOT NULL DROP VIEW [Sales].[Sales];
GO

CREATE VIEW Sales.Sales WITH SCHEMABINDING AS 
SELECT 
    c.CustomerId, 
    p.ProductId, 
    ProductName = p.Name, 
    sod.OrderQty, 
    sod.UnitPrice, 
    LinePrice = OrderQty * UnitPrice
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Sales.SalesOrderHeader soh ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product p ON p.ProductID = sod.ProductID
JOIN 
    Sales.Customer c ON c.CustomerID = soh.CustomerID;

GO
IF NOT EXISTS (SELECT * FROM [AdventureWorks].sys.indexes WHERE object_id = OBJECT_ID('Sales.Sales') AND name = 'IX_Sales_CustomerId_ProductId')
CREATE UNIQUE CLUSTERED INDEX IX_Sales_CustomerId_ProductId ON Sales.Sales (CustomerId,ProductID);
IF NOT EXISTS (SELECT * FROM [AdventureWorks].sys.indexes WHERE object_id = OBJECT_ID('Sales.Sales') AND name = 'IX_SalesData_ColumnStore')
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_SalesData_ColumnStore ON Sales.Sales ([LinePrice]);
GO

IF OBJECT_ID('[Sales].[CustomerSales]', 'V') IS NOT NULL DROP VIEW [Sales].[CustomerSales];
GO

CREATE VIEW Sales.CustomerSales WITH SCHEMABINDING AS
SELECT 
    CustomerId, 
    CustomerTotalPrice = SUM(LinePrice)
FROM 
    Sales.Sales
GROUP BY 
    CustomerId;
GO
IF NOT EXISTS (SELECT * FROM [AdventureWorks].sys.indexes WHERE object_id = OBJECT_ID('Sales.CustomerSales') AND name = 'IX_CustomerSales_CustomerId')
CREATE UNIQUE CLUSTERED INDEX IX_CustomerSales_CustomerId ON Sales.CustomerSales (CustomerId);
GO

IF OBJECT_ID('[Sales].[ProductSales]', 'V') IS NOT NULL  DROP VIEW [Sales].[ProductSales];
GO

CREATE VIEW [Sales].[ProductSales] WITH SCHEMABINDING AS
SELECT 
    ProductId, 
    ProductName, 
    ProductTotalPrice = SUM(LinePrice)
FROM 
    Sales.Sales
GROUP BY 
    ProductId, 
    ProductName;
GO
IF NOT EXISTS (SELECT * FROM [AdventureWorks].sys.indexes WHERE object_id = OBJECT_ID('Sales.ProductSales') AND name = 'IX_ProductSales_ProductId')
CREATE UNIQUE CLUSTERED INDEX IX_ProductSales_ProductId ON Sales.ProductSales (ProductId);
GO

SELECT 
    s.CustomerId, 
    s.ProductId, 
    s.ProductName, 
    s.OrderQty, 
    s.UnitPrice, 
    s.LinePrice, 
    cs.CustomerTotalPrice, 
    ps.ProductTotalPrice
FROM 
    Sales.Sales s
JOIN 
    Sales.CustomerSales cs ON cs.CustomerId = s.CustomerId
JOIN 
    Sales.ProductSales ps ON ps.ProductId = s.ProductId;

SET STATISTICS IO, TIME, XML OFF;