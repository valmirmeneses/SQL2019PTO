/*============================================================================
	SQL Server PTO Module 04 Hands-on Labs
	AddTables.sql
	
------------------------------------------------------------------------------

This Script prepare tables and scripts for simulating blocking and deadlock issue
============================================================================*/

USE AdventureworksPTO
GO

IF OBJECTPROPERTY(object_id('NewCustomer'), 'IsUserTable') = 1
   DROP TABLE NewCustomer
SELECT * INTO NewCustomer
   FROM Sales.Customer
GO

IF OBJECTPROPERTY(object_id('NewAddress'), 'IsUserTable') = 1
   DROP TABLE NewAddress
SELECT * INTO NewAddress 
   FROM Person.Address
GO

IF OBJECTPROPERTY(object_id('NewSalesOrderHeader'), 'IsUserTable') = 1
   DROP TABLE NewSalesOrderHeader
SELECT * INTO NewSalesOrderHeader
   FROM Sales.SalesOrderHeader
GO

Create clustered index cidx_NewSalesOrderHeader on NewSalesOrderHeader(SalesOrderID)
GO

IF OBJECTPROPERTY(object_id('NewSalesOrderDetail'), 'IsUserTable') = 1
   DROP TABLE NewSalesOrderDetail
SELECT * INTO NewSalesOrderDetail
   FROM Sales.SalesOrderDetail
GO

Create clustered index cidx_NewSalesOrderDetail on NewSalesOrderDetail(SalesOrderID)
GO

IF OBJECTPROPERTY(object_id('NewProduct'), 'IsUserTable') = 1
   DROP TABLE NewProduct
SELECT * INTO NewProduct
   FROM Production.Product
GO

IF OBJECTPROPERTY(object_id('NewContacts'), 'IsUserTable') = 1
   DROP TABLE NewContacts
SELECT * INTO NewContacts
   FROM Person.Person
GO

IF OBJECTPROPERTY(object_id('NewOrderUpdate'), 'IsUserTable') = 1
   DROP TABLE NewOrderUpdate

SELECT SalesOrderID, ModifiedDate AS UpdateDate
INTO dbo.NewOrderUpdate
FROM NewSalesOrderHeader

GO

--Trigger 1
CREATE TRIGGER [dbo].[iduNewSalesOrderDetail] ON [dbo].[NewSalesOrderDetail] 
AFTER INSERT, DELETE, UPDATE AS 
BEGIN
DECLARE @Count int;
SET @Count = @@ROWCOUNT;
IF @Count = 0 
RETURN;
SET NOCOUNT ON;

IF (UPDATE([ProductID]) OR UPDATE([OrderQty]) OR UPDATE([UnitPrice]) OR UPDATE([UnitPriceDiscount]) )
BEGIN
Update A set UpdateDate = GETDATE() 
FROM inserted 
INNER JOIN dbo.NewOrderUpdate A
ON inserted.[SalesOrderID] = A.[SalesOrderID] 

waitfor delay '00:00:10'

UPDATE [dbo].[NewSalesOrderHeader]
SET [dbo].[NewSalesOrderHeader].[SubTotal] = 
(SELECT SUM([dbo].[NewSalesOrderDetail].[LineTotal])
FROM [dbo].[NewSalesOrderDetail]
WHERE [dbo].[NewSalesOrderHeader].[SalesOrderID] = [dbo].[NewSalesOrderDetail].[SalesOrderID])
WHERE [dbo].[NewSalesOrderHeader].[SalesOrderID] IN (SELECT inserted.[SalesOrderID] FROM inserted);
END

END

GO
--Trigger 2
CREATE TRIGGER [dbo].[uNewSalesOrderHeader] ON [dbo].[NewSalesOrderHeader] 
AFTER UPDATE NOT FOR REPLICATION AS 
BEGIN
DECLARE @Count int;
SET @Count = @@ROWCOUNT;
IF @Count = 0 
RETURN;
SET NOCOUNT ON;

waitfor delay '00:00:10'

Update A set UpdateDate = GETDATE() 
FROM inserted 
INNER JOIN dbo.NewOrderUpdate A
ON inserted.[SalesOrderID] = A.[SalesOrderID] 
END


GO