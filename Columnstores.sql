USE AdventureWorks;
GO
DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO

-- Select Table with regular Index
SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty, Max(OrderQty) as MaxQty, Min(OrderQty) as MinQty
FROM [Sales].[BigSalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID
GO
-- Table 'BigSalesOrderDetail'. Scan count 5, logical reads 425244, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server
-- Create ColumnStore Index
-- DROP INDEX [IX_BigSalesOrderDetail_ColumnStore] ON [Sales].[BigSalesOrderDetail]
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_BigSalesOrderDetail_ColumnStore] ON [Sales].[BigSalesOrderDetail]
(
	 [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal]
      ,[rowguid]
      ,[ModifiedDate]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO
DBCC FREEPROCCACHE
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
-- Select Table with Columnstore Index
SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty, Max(OrderQty) as MaxQty, Min(OrderQty) as MinQty
FROM [Sales].[BigSalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID
GO