-- This query involves complex joins, large data sets, and CPU-intensive operations
-- It is designed to cause a lot of SOS_SCHEDULER_YIELD waits

SELECT 
    p.ProductID,
    p.Name,
    p.ProductNumber,
    p.Color,
    p.ListPrice,
    s.Name AS SubCategoryName,
    c.Name AS CategoryName,
    SUM(sod.OrderQty) AS TotalOrderQty,
    SUM(sod.LineTotal) AS TotalLineTotal,
    AVG(sod.UnitPrice) AS AvgUnitPrice,
    COUNT(*) AS OrderCount
FROM 
    Production.Product p
INNER JOIN 
    Production.ProductSubcategory s ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN 
    Production.ProductCategory c ON s.ProductCategoryID = c.ProductCategoryID
INNER JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
INNER JOIN 
    Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN 
    Sales.Customer cu ON soh.CustomerID = cu.CustomerID
INNER JOIN 
    Person.Person pe ON cu.PersonID = pe.BusinessEntityID
INNER JOIN 
    Sales.SalesTerritory st ON cu.TerritoryID = st.TerritoryID
INNER JOIN 
    HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
INNER JOIN 
    HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
INNER JOIN 
    HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
INNER JOIN 
    HumanResources.Shift sh ON edh.ShiftID = sh.ShiftID
WHERE 
    soh.OrderDate BETWEEN '2010-01-01' AND '2010-12-31'
GROUP BY 
    p.ProductID, p.Name, p.ProductNumber, p.Color, p.ListPrice, s.Name, c.Name
ORDER BY 
    TotalOrderQty DESC, TotalLineTotal DESC;
