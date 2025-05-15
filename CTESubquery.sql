-- The second query is the CTE rewritten using subqueries
SET STATISTICS IO, TIME, XML ON;
GO
DBCC FREEPROCCACHE 
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
