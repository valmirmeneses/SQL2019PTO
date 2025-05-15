
DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
SELECT o.SalesOrderID, od.ProductID, od.OrderQty
FROM Sales.SalesOrderHeaderEnlarged o
INNER JOIN Sales.SalesOrderDetailEnlarged od ON o.SalesOrderID = od.SalesOrderID;


DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
SELECT o.SalesOrderID, od.ProductID, od.OrderQty
FROM Sales.SalesOrderHeaderEnlarged o
INNER LOOP JOIN Sales.SalesOrderDetailEnlarged od ON o.SalesOrderID = od.SalesOrderID;

DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
SELECT o.SalesOrderID, od.ProductID, od.OrderQty
FROM Sales.SalesOrderHeaderEnlarged o
INNER HASH JOIN Sales.SalesOrderDetailEnlarged od ON o.SalesOrderID = od.SalesOrderID;

DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
SELECT o.SalesOrderID, od.ProductID, od.OrderQty
FROM Sales.SalesOrderHeaderEnlarged o
INNER MERGE JOIN Sales.SalesOrderDetailEnlarged od ON o.SalesOrderID = od.SalesOrderID;


