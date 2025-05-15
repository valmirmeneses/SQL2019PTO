SELECT
	p.[Name],
	p.ProductNumber,
	th.*,
	tha.*
FROM  Production.Product p 
	INNER JOIN Production.TransactionHistory th ON p.ProductID = th.ProductID
	INNER JOIN Production.TransactionHistoryArchive tha ON th.Quantity = tha.Quantity
