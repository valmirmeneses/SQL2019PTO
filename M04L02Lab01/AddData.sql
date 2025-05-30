/*============================================================================
	SQL Server PTO Module 04 Hands-on Labs
	AddData.sql
	
------------------------------------------------------------------------------

This Script prepare a table with 100k rows
============================================================================*/

USE AdventureworksPTO
GO

IF OBJECTPROPERTY(object_id('NewAddress'), 'IsUserTable') = 1
   DROP TABLE NewAddress
SELECT * INTO NewAddress
     FROM Person.Address
GO

-- Insert 100,000 rows in NewAddress table (should increase database size)
SET NOCOUNT ON
GO

DECLARE @iNewRows int
DECLARE @CustID int
DECLARE @TerrID int

SELECT @iNewRows = 1

WHILE (@iNewRows < 100001)
	BEGIN

		INSERT INTO NewAddress
		(AddressLine1, City, StateProvinceID, PostalCode, rowguid, ModifiedDate)
		VALUES (
			'13747 Street of the Dreams',
			'Redmond',
			15,
			98052,
			newid(),
			getdate())

		SELECT @iNewRows = @iNewRows + 1
		SELECT getdate() AS 'Row Inserted'
		PRINT ' '
	END
GO

CREATE CLUSTERED INDEX [NewAddressCL] ON [dbo].[NewAddress] 
(
	[AddressID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO