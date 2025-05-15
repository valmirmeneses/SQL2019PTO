-- CTE 1
SET STATISTICS IO, TIME, XML ON;

WITH Sales AS (
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
        Sales.Customer c ON c.CustomerID = soh.CustomerID
),
CustomerSales AS (
    SELECT 
        CustomerId, 
        CustomerTotalPrice = SUM(LinePrice)
    FROM 
        Sales
    GROUP BY 
        CustomerId
),
ProductSales AS (
    SELECT 
        ProductId, 
        ProductName, 
        ProductTotalPrice = SUM(LinePrice)
    FROM 
        Sales
    GROUP BY 
        ProductId, 
        ProductName
)
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
    Sales s
JOIN 
    CustomerSales cs ON cs.CustomerId = s.CustomerId
JOIN 
    ProductSales ps ON ps.ProductId = s.ProductId;

SET STATISTICS IO, TIME, XML OFF;

-- The second query is the CTE rewritten using subqueries
SET STATISTICS IO, TIME, XML ON;

SELECT 
    s.CustomerId, 
    s.ProductId, 
    s.ProductName, 
    s.OrderQty, 
    s.UnitPrice, 
    s.LinePrice, 
    cs.CustomerTotalPrice, 
    ps.ProductTotalPrice
FROM (
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
        Sales.Customer c ON c.CustomerID = soh.CustomerID
) s
JOIN (
    SELECT 
        CustomerId, 
        CustomerTotalPrice = SUM(LinePrice)
    FROM (
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
            Sales.Customer c ON c.CustomerID = soh.CustomerID
    ) s
    GROUP BY 
        CustomerId
) cs ON cs.CustomerId = s.CustomerId
JOIN (
    SELECT 
        ProductId, 
        ProductName, 
        ProductTotalPrice = SUM(LinePrice)
    FROM (
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
            Sales.Customer c ON c.CustomerID = soh.CustomerID
    ) s
    GROUP BY 
        ProductId, 
        ProductName
) ps ON ps.ProductId = s.ProductId;

SET STATISTICS IO, TIME, XML OFF;

-- CTE rewritten using views
IF OBJECT_ID('[Sales].[Sales]', 'V') IS NOT NULL DROP VIEW [Sales].[Sales];
GO

CREATE VIEW Sales.Sales AS 
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

IF OBJECT_ID('[Sales].[CustomerSales]', 'V') IS NOT NULL DROP VIEW [Sales].[CustomerSales];
GO

CREATE VIEW Sales.CustomerSales AS
SELECT 
    CustomerId, 
    CustomerTotalPrice = SUM(LinePrice)
FROM 
    Sales.Sales
GROUP BY 
    CustomerId;
GO

IF OBJECT_ID('[Sales].[ProductSales]', 'V') IS NOT NULL  DROP VIEW [Sales].[ProductSales];
GO

CREATE VIEW Sales.ProductSales AS
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
