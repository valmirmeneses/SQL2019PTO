USE AdventureWorks
GO
-- Create New Table drop  TABLE [dbo].[MySalesOrderDetail]
CREATE TABLE [Sales].[BigSalesOrderDetail](
[SalesOrderID] [int] NOT NULL,
[SalesOrderDetailID] [int] NOT NULL,
[CarrierTrackingNumber] [nvarchar](25) NULL,
[OrderQty] [smallint] NOT NULL,
[ProductID] [int] NOT NULL,
[SpecialOfferID] [int] NOT NULL,
[UnitPrice] [money] NOT NULL,
[UnitPriceDiscount] [money] NOT NULL,
[LineTotal] [numeric](38, 6) NOT NULL,
[rowguid] [uniqueidentifier] NOT NULL,
[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
-- Create clustered index
CREATE CLUSTERED INDEX [CL_BigSalesOrderDetail] ON [Sales].[BigSalesOrderDetail]
( [SalesOrderDetailID])
GO
-- Create Sample Data Table
-- WARNING: This Query may run upto 2-10 minutes based on your systems resources
INSERT INTO [Sales].[BigSalesOrderDetail]
SELECT S1.*
FROM Sales.SalesOrderDetail S1
GO 100