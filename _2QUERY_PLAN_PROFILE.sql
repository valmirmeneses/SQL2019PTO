---https://techcommunity.microsoft.com/blog/sqlserver/using-xevents-to-capture-an-actual-execution-plan/392136

ALTER DATABASE SCOPED CONFIGURATION SET LIGHTWEIGHT_QUERY_PROFILING = ON;
ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;
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
OPTION(USE HINT ('QUERY_PLAN_PROFILE'));
Select * from sys.dm_exec_query_profiles
---OPTION (RECOMPILE, USE HINT ('ASSUME_MIN_SELECTIVITY_FOR_FILTER_ESTIMATES', 'DISABLE_PARAMETER_SNIFFING'));

EXEC sp_create_plan_guide  
@name = N'Guide1',
@stmt = 'SELECT COUNT(*)
FROM Sales.SalesOrderDetailEnlarged AS sod
INNER JOIN Sales.SalesOrderHeaderEnlarged AS soh
       ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.STATUS;',
@type = N'OBJECT',
@module_or_batch = N'Sales.CountSalesOrderByStatus',
@params = NULL,
@hints = N'OPTION (USE HINT (''QUERY_PLAN_PROFILE''))';

 

select * from sys.dm_exec_valid_use_hints