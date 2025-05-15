-- CTE 1
SET STATISTICS IO, TIME, XML ON;
GO
DBCC FREEPROCCACHE 
GO
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

---SET STATISTICS IO, TIME, XML OFF;
