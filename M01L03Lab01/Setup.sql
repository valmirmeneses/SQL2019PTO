USE AdventureWorksPTO
GO
--IF OBJECT_ID ('usp_DoSomeWork', 'P') IS NOT NULL DROP PROC usp_DoSomeWork
--GO
DROP PROC IF EXISTS usp_DoSomeWork
GO
CREATE OR ALTER PROC usp_DoSomeWork AS 
BEGIN
  SET NOCOUNT ON;
  SELECT 1 AS c1 INTO #t1;
END
GO
