SET NOCOUNT ON
-- Drop the tables if they already exist
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Sales].[BigSalesOrderDetail]') AND type in (N'U'))
DROP TABLE [Sales].[BigSalesOrderDetail]
GO
--- Create the new tables
SELECT * INTO [Sales].[BigSalesOrderDetail] FROM [Sales].[SalesOrderDetail]
UNION ALL
SELECT TOP 1 * FROM [Sales].[SalesOrderDetail] WHERE 1 = 0
--- Remove NOT Null restraints
DECLARE @tableName NVARCHAR(128) = 'Sales.BigSalesOrderDetail';
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + COLUMN_NAME + ' ' + DATA_TYPE + 
              CASE 
                  WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN '(' + CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ')'
                  ELSE ''
              END + ' NULL;' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName AND IS_NULLABLE = 'NO';
EXEC sp_executesql @sql;
-- Drop the tables if they already exist
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Sales].[BigSalesOrderHeader]') AND type in (N'U'))
DROP TABLE [Sales].[BigSalesOrderHeader]
GO
--- Create the new tables
SELECT * INTO [Sales].[BigSalesOrderHeader] FROM [Sales].[SalesOrderHeader]
UNION ALL
SELECT TOP 1 * FROM [Sales].[SalesOrderHeader] WHERE 1 = 0
--- Remove NOT Null restraints
DECLARE @tableName NVARCHAR(128) = 'Sales.BigSalesOrderHeader';
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + COLUMN_NAME + ' ' + DATA_TYPE + 
              CASE 
                  WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN '(' + CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ')'
                  ELSE ''
              END + ' NULL;' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = @tableName   AND IS_NULLABLE = 'NO';
EXEC sp_executesql @sql;
--- Populate the table with a 1000000 new records for Customer/Sales pattern detection
DECLARE @i INT = 0;
WHILE @i < 1000000
BEGIN
    DECLARE @CustomerID INT = (SELECT TOP 1 CustomerID FROM Sales.Customer ORDER BY NEWID());
    DECLARE @SalesOrderID INT = (SELECT ISNULL(MAX(SalesOrderID), 0) + 1 FROM Sales.BigSalesOrderHeader);
    DECLARE @ModifiedDate DATETIME = GETDATE();
    DECLARE @RowGuid UNIQUEIDENTIFIER = NEWID();
    DECLARE @OrderQty SMALLINT;
    DECLARE @ProductID INT;
	 DECLARE @ShipMethodID INT;
	
    DECLARE @UnitPriceDiscount MONEY;
    DECLARE @UnitPrice MONEY;
    DECLARE @TotalDue MONEY;
    DECLARE @LineTotal NUMERIC;
    DECLARE @Status INT = (SELECT TOP 1 Status FROM Sales.BigSalesOrderHeader ORDER BY NEWID());
    -- Insert a random number of records into BigSalesOrderDetail
    DECLARE @j INT = 0;
    DECLARE @numDetails INT = CAST(RAND() * 10 + 1 AS INT); -- Random number of details between 1 and 10

    WHILE @j < @numDetails
    BEGIN
        SET @OrderQty = CAST(RAND() * 10 + 1 AS SMALLINT); -- Random quantity between 1 and 10
        SET @ProductID = (SELECT TOP 1 ProductID FROM Sales.ProductDescripted ORDER BY NEWID());
        SET @UnitPriceDiscount = CAST(RAND() * 10 AS MONEY); -- Random discount between 0 and 10
        SET @UnitPrice = CAST(RAND() * 100 + 1 AS MONEY) + @UnitPriceDiscount; -- Random price between 1 and 100
        SET @LineTotal = @OrderQty * (@UnitPrice - @UnitPriceDiscount);
        INSERT INTO Sales.BigSalesOrderDetail (SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate)
        VALUES (@SalesOrderID, @i * 10 + @j + 1, @OrderQty, @ProductID, @UnitPrice, @UnitPriceDiscount, @LineTotal, @RowGuid, @ModifiedDate);

        SET @j = @j + 1;
    END;
    SET @TotalDue = (Select sum(LineTotal) from Sales.BigSalesOrderDetail Where SalesOrderID=@SalesOrderID)
	SET @ShipMethodID = (SELECT TOP 1 ShipMethodID FROM Sales.SalesOrderHeader ORDER BY NEWID());
        -- Insert into BigSalesOrderHeader
    INSERT INTO Sales.BigSalesOrderHeader (SalesOrderID, RevisionNumber, OrderDate, DueDate, Status, OnlineOrderFlag, SalesOrderNumber, CustomerID, SubTotal, TaxAmt, Freight, TotalDue, rowguid, ModifiedDate, ShipMethodID)
    VALUES (@SalesOrderID, 1, GETDATE(), DATEADD(DAY, 7, GETDATE()), 1, 1, CONCAT('SO', @SalesOrderID), @CustomerID, @TotalDue, 0, 0, @TotalDue, @RowGuid, @ModifiedDate, @ShipMethodID);

    SET @i = @i + 1;
END;