USE [AdventureWorks]
GO

/****** Object:  Index [IX_BigSalesOrderDetail_ColumnStore]    Script Date: 4/23/2025 3:33:30 PM ******/
DROP INDEX [IX_BigSalesOrderDetail_ColumnStore] ON [Sales].[BigSalesOrderDetail]
GO

/****** Object:  Index [IX_BigSalesOrderDetail_ColumnStore]    Script Date: 4/23/2025 3:33:31 PM ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_BigSalesOrderDetail_ColumnStore] ON [Sales].[BigSalesOrderDetail]
(
	[SalesOrderID],
	[SalesOrderDetailID],
	[CarrierTrackingNumber],
	[OrderQty],
	[ProductID],
	[SpecialOfferID],
	[UnitPrice],
	[UnitPriceDiscount],
	[LineTotal],
	[rowguid],
	[ModifiedDate]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO


