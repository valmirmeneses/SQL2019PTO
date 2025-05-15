WITH Managers AS 
( 
--initialization 
SELECT EmployeeID, LastName, ReportsTo  
FROM [HumanResources].[EmployeeTree] 
WHERE ReportsTo IS NULL 
UNION ALL 
--recursive execution 
SELECT e.employeeID,e.LastName, e.ReportsTo 
FROM [HumanResources].[EmployeeTree] e INNER JOIN Managers m  
ON e.ReportsTo = m.employeeID 
) 
--SELECT * FROM Managers  
SELECT * FROM Managers OPTION (MAXRECURSION 2) 