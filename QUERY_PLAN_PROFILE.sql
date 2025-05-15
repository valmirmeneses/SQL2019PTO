DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
SELECT 
    soh.SalesOrderID, 
    soh.OrderDate, 
    SUM(sod.LineTotal) AS TotalLineAmount
FROM 
    Sales.SalesOrderHeaderEnlarged AS soh
    INNER JOIN Sales.SalesOrderDetailEnlarged AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE 
    soh.OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
GROUP BY 
    soh.SalesOrderID, 
    soh.OrderDate
--OPTION(USE HINT ('QUERY_PLAN_PROFILE'));

