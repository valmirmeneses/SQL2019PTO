USE master
GO
If exists ( SELECT 1 FROM sys.databases 
				WHERE name= 'AdventureWorksPTO'  
				and is_read_committed_snapshot_on=0)
Begin 
	ALTER DATABASE AdventureWorksPTO
	SET READ_COMMITTED_SNAPSHOT ON;
END
----is_read_committed_snapshot_on 
SELECT is_read_committed_snapshot_on,name FROM sys.databases
WHERE name= 'AdventureWorksPTO'