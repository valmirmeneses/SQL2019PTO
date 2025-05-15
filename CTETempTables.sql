-- Enable statistics
SET STATISTICS IO, TIME, XML ON;
GO

-- Clear the procedure cache
DBCC FREEPROCCACHE;
GO
dbcc freesystemcache ('SQL Plans');

IF OBJECT_ID('tempdb..#SalesData') IS NOT NULL DROP TABLE #SalesData;
-- Insert data into temporary tables
SELECT 
    c.CustomerId, 
    p.ProductId, 
    p.Name AS ProductName, 
    sod.OrderQty, 
    sod.UnitPrice, 
    sod.OrderQty * sod.UnitPrice AS LinePrice
INTO #SalesData
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Sales.SalesOrderHeader soh ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product p ON p.ProductID = sod.ProductID
JOIN 
    Sales.Customer c ON c.CustomerID = soh.CustomerID;


IF NOT EXISTS (SELECT * FROM tempdb.sys.indexes WHERE object_id = OBJECT_ID('tempdb..#SalesData') AND name = 'IX_SalesData_ProductId')
CREATE NONCLUSTERED INDEX IX_SalesData_ProductId ON #SalesData (ProductId) INCLUDE ([CustomerId]);
IF NOT EXISTS (SELECT * FROM tempdb.sys.indexes WHERE object_id = OBJECT_ID('tempdb..#SalesData') AND name = 'IX_SalesData_ColumnStore')
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_SalesData_ColumnStore ON #SalesData ([OrderQty], [UnitPrice], [LinePrice]);

IF OBJECT_ID('tempdb..#CustomerTotal') IS NOT NULL DROP TABLE #CustomerTotal;
SELECT 
    CustomerId, 
    SUM(LinePrice) AS CustomerTotalPrice
INTO #CustomerTotal 
FROM 
    #SalesData
GROUP BY 
    CustomerId;

IF NOT EXISTS (SELECT * FROM tempdb.sys.indexes WHERE object_id = OBJECT_ID('tempdb..#CustomerTotal') AND name = 'IX_CustomerTotal_CustomerId')
CREATE NONCLUSTERED INDEX IX_CustomerTotal_CustomerId ON #CustomerTotal (CustomerId);

IF OBJECT_ID('tempdb..#ProductTotal') IS NOT NULL DROP TABLE #ProductTotal;
SELECT 
    ProductId, 
    ProductName, 
    SUM(LinePrice) AS ProductTotalPrice
Into #ProductTotal
FROM 
    #SalesData
GROUP BY 
    ProductId, 
    ProductName;

-- Create indexes on temporary tables if they do not already exist
IF NOT EXISTS (SELECT * FROM tempdb.sys.indexes WHERE object_id = OBJECT_ID('tempdb..#ProductTotal') AND name = 'IX_ProductTotal_ProductId')
CREATE NONCLUSTERED INDEX IX_ProductTotal_ProductId ON #ProductTotal (ProductId);

-- Execute the final query using the temporary tables and indexes
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
    #SalesData s
JOIN 
    #CustomerTotal cs ON cs.CustomerId = s.CustomerId
JOIN 
    #ProductTotal ps ON ps.ProductId = s.ProductId;

-- Disable statistics
SET STATISTICS IO, TIME, XML OFF;
