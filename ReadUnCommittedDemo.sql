SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
GO
	SELECT EmpID, EmpName, EmpSalary
	FROM dbo.TestIsolationLevels
	WHERE EmpID = 2900
 
	---Note the value for empSalary reflects the current *uncommitted* value. You can view the intent lock on the key (empID) and the intent exclusive locks on the object containers (the page on which the row is located and the object) imposed by the UPDATE statement using the following:
	SELECT      es.login_name, tl.resource_type, 
				tl.resource_associated_entity_id,
				tl.request_mode, 
				tl.request_status
	FROM        sys.dm_tran_locks tl
	INNER JOIN  sys.dm_exec_sessions es ON tl.request_session_id = es.session_id 
	WHERE       es.login_name = SUSER_SNAME() AND tl.resource_associated_entity_id <> 0

	SELECT * FROM Lock_checks WHERE SessionID = @@spid AND ResourceType <> 'METADATA' AND EntityName <> 'Lock_checks'
