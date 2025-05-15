SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels WITH (READCOMMITTEDLOCK)
WHERE   EmpID = 2900

/*
Even with RCSI enabled, you can enforce shared locks at the table level using the hint READCOMMITTEDLOCK.
*/
---The query will hang as it is waiting for the key lock on EmpID to be released. Allow the query to execute by issuing in your first window: ROLLBACK;