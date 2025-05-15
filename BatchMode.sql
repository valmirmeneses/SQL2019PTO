USE ADVENTUREWORKS

SELECT name, value
FROM sys.database_scoped_configurations
WHERE name = 'BATCH_MODE_ON_ROWSTORE';

SET STATISTICS TIME,IO ON
GO
DBCC DROPCLEANBUFFERS
GO
---- Enable Actual Execution Plan or CTRL+M
SELECT ModifiedDate
	,CarrierTrackingNumber
	,SUM(OrderQty*UnitPrice) 
FROM Sales.SalesOrderDetail
GROUP BY ModifiedDate,CarrierTrackingNumber
/*  Check (Hover over) or right+click the Clustered Index Scan node and you will see the Actual Execution Mode as Row */

/*  Let's use the HINT('ALLOW_BATCH_MODE') */
GO
DBCC DROPCLEANBUFFERS
GO
SELECT ModifiedDate
	,CarrierTrackingNumber
	,SUM(OrderQty*UnitPrice) 
FROM Sales.SalesOrderDetail
GROUP BY ModifiedDate,CarrierTrackingNumber
OPTION(USE HINT('ALLOW_BATCH_MODE'))
/*  Check (Hover over) or right+click the Clustered Index Scan node and you will see the Actual Execution Mode continue as Row */
GO
DBCC DROPCLEANBUFFERS
GO
/*  Let's use the HINT('DISALLOW_BATCH_MODE') */
SELECT ModifiedDate
	,CarrierTrackingNumber
	,SUM(OrderQty*UnitPrice) 
FROM Sales.SalesOrderDetail
GROUP BY ModifiedDate,CarrierTrackingNumber
OPTION(USE HINT('DISALLOW_BATCH_MODE'))
GO
DBCC DROPCLEANBUFFERS
GO
/* But if we create a columnstore index... */
--DROP INDEX  [IX_SalesOrderDetail_ColumnStore] ON [Sales].[SalesOrderDetail]
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_SalesOrderDetail_ColumnStore] ON [Sales].[SalesOrderDetail]
(	 [ModifiedDate]	,[CarrierTrackingNumber],[UnitPrice],[OrderQty]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO
DBCC DROPCLEANBUFFERS
GO
SELECT ModifiedDate
	,CarrierTrackingNumber
	,SUM(OrderQty*UnitPrice) 
FROM Sales.SalesOrderDetail
GROUP BY ModifiedDate,CarrierTrackingNumber
/*  Check (Hover over) or right+click the Columstore Index Scan node and you will see the Actual Execution Mode as Batch */


