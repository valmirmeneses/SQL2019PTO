CREATE PROCEDURE Sales.CountSalesOrderByStatus
AS
SELECT COUNT(*)
FROM Sales.SalesOrderDetailEnlarged AS sod
INNER JOIN Sales.SalesOrderHeaderEnlarged AS soh
       ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.STATUS;
