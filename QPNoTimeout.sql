SET STATISTICS TIME ON;
SET STATISTICS IO ON
GO
DBCC FREEPROCCACHE
GO
dbcc freesystemcache ('SQL Plans');
go
SELECT soh.[SalesPersonID],
p.[FirstName] + ' ' + COALESCE(p.[MiddleName], '') + ' ' + p.[LastName] AS [FullName],
e.[JobTitle], st.[Name] AS [SalesTerritory],
soh.[SubTotal], YEAR(DATEADD(m, 6, soh.[OrderDate])) AS [FiscalYear]
FROM [Sales].[SalesPerson] AS sp
        INNER JOIN
        [Sales].[SalesOrderHeader] AS soh
        ON sp.[BusinessEntityID] = soh.[SalesPersonID]
        INNER JOIN
        [Sales].[SalesTerritory] AS st
        ON sp.[TerritoryID] = st.[TerritoryID]
        INNER JOIN
        [HumanResources].[Employee] AS e
        ON soh.[SalesPersonID] = e.[BusinessEntityID]
        INNER JOIN
        [Person].[Person] AS p
        ON p.[BusinessEntityID] = sp.[BusinessEntityID]
        OPTION ( QUERYTRACEON 8780)