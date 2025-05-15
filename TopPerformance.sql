
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
---DBCC FREEPROCCACHE 
dbcc freesystemcache ('SQL Plans');
---- Adaptive HASH join
/*
This join type is preferred by the optimizer when the unsorted large amount of data wants to be joined. 
In the hash match join, SQL Server builds a hash table in the memory and then begins to scans the matched rows into the hash table. 
*/
SELECT  SO.AccountNumber FROM
Sales.SalesOrderHeaderEnlarged SO
INNER JOIN Sales.SalesOrderDetailEnlarged SD
ON SD.SalesOrderID = SO.SalesOrderID


---- Nested Loop
SELECT  TOP 10 SO.AccountNumber FROM
Sales.SalesOrderHeaderEnlarged SO
INNER JOIN Sales.SalesOrderDetailEnlarged SD
ON SD.SalesOrderID = SO.SalesOrderID

/*
The optimizer has started to use the nested loop join instead of the hash join. 
The nested loop join type is based on a very simple loop algorithm. 
Each row from the outer table search on the inner table rows for the rows that satisfy the join criteria. 
This join type shows a good performance in the small row numbers. 
The idea behind the execution plan changing is that the query optimizer knows the query will return a small number of rows because of the TOP clause in the query. 
Therefore optimizer tries to seek out a more optimum plan to fetch the small number of rows more quickly. 
In this circumstance, the nested loop join is the cheapest and fastest way to fetch the small number of rows for this query, and also nested loop requires fewer resources. 
Here we need to emphasize one point, the optimizer benefits from a feature that is called row goal to fulfill this query plan changing because of the TOP clause.
*/

SET STATISTICS TIME ON
SET STATISTICS IO ON
GO
SELECT  TOP 150 SO.AccountNumber 
FROM Sales.SalesOrderHeader SO
INNER  JOIN Sales.SalesOrderDetailEnlarged SD
ON SO.ModifiedDate = SD.ModifiedDate
--- SQL Server Execution Times:  CPU time = 2672 ms,  elapsed time = 2748 ms 

/*
Avoiding the table spool operator can reduce the I/O performance of the query so it helps to improve query performance. 
In general, we may observe the table spool operator with the nested loop join but we can force the optimizer to change this join type with other alternative join types. We can use the OPTION clause to add some hints that can force the optimizer to change the optimal query plan. 
In order to get rid of the table spool operator, we can force the optimizer to use a hash join instead of the nested loop join. 
To do this, we will add the OPTION (HASH JOIN) statement at the end of the query.
*/
/*
DROP INDEX [IX_NC_SalesOrderHeader_AccountNumber] ON [Sales].[SalesOrderHeader] 
CREATE NONCLUSTERED INDEX [IX_NC_SalesOrderHeader_AccountNumber] ON [Sales].[SalesOrderHeader] ([ModifiedDate])
INCLUDE ([AccountNumber])
*/

SELECT  TOP 150 SO.AccountNumber 
FROM Sales.SalesOrderHeader SO
INNER  JOIN Sales.SalesOrderDetailEnlarged SD
ON SO.ModifiedDate = SD.ModifiedDate
OPTION( HASH JOIN)
--- SQL Server Execution Times:     CPU time = 16 ms,  elapsed time = 206 ms

--- Improving with INNER HASH and OPTION(NO_PERFORMANCE_SPOOL)
SELECT  TOP 150 SO.AccountNumber 
FROM Sales.SalesOrderHeader SO
INNER HASH JOIN Sales.SalesOrderDetailEnlarged SD
ON SO.ModifiedDate = SD.ModifiedDate
OPTION(NO_PERFORMANCE_SPOOL)
------ SQL Server Execution Times:     CPU time = 15 ms,  elapsed time = 166 ms.
