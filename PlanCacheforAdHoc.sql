DBCC TRACEON(174, -1);
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
