
--DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)
USE AdventureWorks
GO
SELECT
	p.[Name],
	p.ProductNumber,
	th.*,
	tha.*
FROM Production.TransactionHistory th
	INNER JOIN Production.Product p ON p.ProductID = th.ProductID
	INNER JOIN Production.TransactionHistoryArchive tha ON th.Quantity = tha.Quantity
--OPTION(MAXDOP 1)