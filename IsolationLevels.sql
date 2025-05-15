/*
Demonstrations of Transaction Isolation Levels in SQL Server
Setting up the Test Environment
*/
-- init
USE Master
IF DATABASEPROPERTYEX('IsolationLevelDemo', 'Version') IS NOT NULL
BEGIN
    ALTER DATABASE IsolationLevelDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IsolationLevelDemo;
END;
CREATE DATABASE IsolationLevelDemo;
GO
USE IsolationLevelDemo
GO
ALTER DATABASE IsolationLevelDemo SET READ_COMMITTED_SNAPSHOT ON
GO
CREATE TABLE dbo.TestIsolationLevels (
	EmpID INT NOT NULL,
	EmpName VARCHAR(100),
	EmpSalary MONEY,
	CONSTRAINT pk_EmpID PRIMARY KEY(EmpID) 
)
GO
INSERT INTO dbo.TestIsolationLevels 
VALUES 
	(2322, 'Dave Smith', 35000),
	(2900, 'John West', 22000),
	(2219, 'Melinda Carlisle', 40000),
	(2950, 'Adam Johns', 18000) 
GO
truncate table  dbo.TestIsolationLevels 
/*
Experiment 1: Read using READ UNCOMMITTED
---READ UNCOMMITTED is the most optimistic concurrency isolation option available in SQL Server. 
---It allows a transaction to get the value in a row even when locks are present on the row/object or it hasn’t yet been committed to disk. 
---Reads like this are also known as ‘dirty reads’ since they effectively read from the transaction log rather than disk or cache – the data is unpersisted. 
---(Note if no concurrent transactions are occurring, the read will occur from cache). 
---To show the effects of READ UNCOMMITTED, we can open a transaction as follows:
*/
BEGIN TRAN
	UPDATE  dbo.TestIsolationLevels 
	SET     EmpSalary = 25000
	WHERE   EmpID = 2900
---Now select the value that’s being updated using the following (in a separate query window): ReadUnCommittedDemo.sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
GO
	SELECT EmpID, EmpName, EmpSalary
	FROM dbo.TestIsolationLevels
	WHERE EmpID = 2900
 
	---Note the value for empSalary reflects the current *uncommitted* value. 
	---You can view the intent lock on the key (empID) and the intent exclusive locks on the object containers (the page on which the row is located and the object) imposed by the UPDATE statement using the following:
	SELECT      es.login_name, tl.resource_type, 
				tl.resource_associated_entity_id,
				tl.request_mode, 
				tl.request_status
	FROM        sys.dm_tran_locks tl
	INNER JOIN  sys.dm_exec_sessions es ON tl.request_session_id = es.session_id 
	WHERE       es.login_name = SUSER_SNAME() AND tl.resource_associated_entity_id <> 0

	SELECT * FROM Lock_checks WHERE SessionID = @@spid AND ResourceType <> 'METADATA' AND EntityName <> 'Lock_checks'

---Now rollback the transaction to reset the EmpSalary for this employee to 22000.00:
ROLLBACK;
/*Experiment 2: Read using READ COMMITTED (snapshot)
There are two levels of READ COMMITTED isolation, which are locking and snapshot. 
Locking is the most straightforward, and simply means that once an UPDATE transaction is open, exclusive and intent-exclusive locks are taken out on the page, key range (if appropriate) and object. 
When reading the row using READ COMMITTED while using locking, the SELECT query used will hang until the value of LOCK_TIMEOUT (session-level parameter, if set) has expired,
at which point an error will be returned.
If the value of the database-level option READ_COMMITTED_SNAPSHOT is False, locking mode for READ COMMITTED transactions is the default option. 
If it is True, then snapshot is the default option unless overridden by the READCOMMITTEDLOCK table hint.
Here’s a demonstration of READ COMMITTED isolation with locking, by using the table hint in a database with READ_COMMITTED_SNAPSHOT ON. 
You don’t need the table hint if this value is OFF

Microsoft released READ_COMMITTED_SNAPSHOT (RCSI) with SQL Server 2005. It’s a type of optimistic concurrency control that uses row-versioning. 
A major benefit of RCSI is that it doesn’t require readers to obtain shared locks. 
This differs from NOLOCK in that NOLOCK reads dirty pages that have not been committed. 
On the other hand, RCSI reads the original committed value when multiple sessions are involved.
https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-ver16#Row_versioning
Do I need to enable SNAPSHOT isolation as well? The answer is no. RCSI and SNAPSHOT isolation are different. 
One core difference is that SNAPSHOT isolation provides transaction-level read consistency, while RCSI gives it at the statement level. 
Additionally, once you enable RCSI, you don’t need to change your code to see it in action. This might be good or bad, depending on your environment.
*/


ALTER DATABASE IsolationLevelDemo SET READ_COMMITTED_SNAPSHOT ON
GO
BEGIN TRAN
	UPDATE  dbo.TestIsolationLevels 
	SET     EmpSalary = 25000
	WHERE   EmpID = 2900
---Now in a separate query window: ReadCommittedLockDemo
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels WITH (READCOMMITTEDLOCK)
WHERE   EmpID = 2900
/*
Even with RCSI enabled, you can enforce shared locks at the table level using the hint READCOMMITTEDLOCK.
*/
SELECT * FROM Lock_checks WHERE SessionID = @@spid AND ResourceType <> 'METADATA' AND EntityName <> 'Lock_checks'
---The query will hang as it is waiting for the key lock on EmpID to be released. Allow the query to execute by issuing in your first window:
ROLLBACK;
 /*
READ COMMITTED with snapshot is different from locking. 
The UPDATE statement above will take the same locks on the objects, but with the SELECT transaction session specifying snapshot isolation, 
the row returned will be the last row version before the UPDATE statement began. This row version is stored internally and represents the last consistent state of the row. Logically it follows that if you are using row versioning, this capability must be DB-wide, since otherwise the transaction with the UPDATE statement would not know to maintain a version of the row before issuing the UPDATE. Therefore, to use snapshot isolation the option must be set using the ALTER DATABASE statement (note that all database user connections will be killed when doing this).
Note About Row Versioning
Row versioning is an internal feature used by SQL Server to maintain recent copies of rows that have been changed, for the purposes of maintaining table consistency 
and ensuring better isolation from reads or writes of transactions that concurrently access the same rows. Row versioning, also called ‘Row-Level Versioning (RLV)’ 
was first introduced in SQL Server 2005. Historical rows are kept in the ‘version store’, inside TEMPDB, and each row that has been ‘versioned’ has a 
row pointer added to it which allows the query engine to locate the versioned row. 
Interestingly, the ‘inserted’ and ‘deleted’ tables used with triggers and the OUTPUT clause (to name two uses) use a similar method of versioning. 
There are performance sacrifices made when using this level of transaction isolation – please see the note under ‘Next Steps’ for more information.
Below is an example of using the READ COMMITTED with snapshot isolation:
*/
ALTER DATABASE IsolationLevelDemo SET READ_COMMITTED_SNAPSHOT ON
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT ON
GO
BEGIN TRAN
	UPDATE  dbo.TestIsolationLevels 
	SET     EmpSalary = 25000
	WHERE   EmpID = 2900
---Now in a separate query window: TRANSACTIONISOLATIONLEVELREADCOMMITTED
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900

--- Rollback the update 
Rollback;
---The query will return the last consistent row of data. 
---Note the empSalary column is 22000.00 despite the transaction being open and the update written (but uncommitted). 
---This is correct, and the SELECT is reading from the previous row version, not the present state of the row. 
---This is compliant with the C in ACID – consistency.
/* 
Experiment 3: Read using SNAPSHOT isolation
For all intents and purposes, reads using READ COMMITTED – snapshot and SNAPSHOT are almost identical – but not identical. 
There are some differences when it comes to details and behavior. 
READ COMMITTED – snapshot will read the most recent consistent row version since the start of the statement being issued, 
where snapshot isolation will read the most consistent row version since the transaction started. 
This can cause problems with concurrent transactions since SELECTs inside the transaction that occur later than the COMMIT time of the UPDATE transaction 
will return an incorrect value. 
Likewise, update conflicts can occur for the same reason when concurrent updates are attempted. 
Do I need to enable SNAPSHOT isolation as well? The answer is no. RCSI and SNAPSHOT isolation are different. 
One core difference is that SNAPSHOT isolation provides transaction-level read consistency, while RCSI gives it at the statement level. 
Additionally, once you enable RCSI, you don’t need to change your code to see it in action. 

To use snapshot isolation, you must first enable the feature as follows:
*/
ALTER DATABASE IsolationLevelDemo SET ALLOW_SNAPSHOT_ISOLATION ON
---Now start the UPDATE again, and issue the SELECT in a separate query window like so:

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT ON
GO
BEGIN TRAN
	UPDATE  dbo.TestIsolationLevels 
	SET     EmpSalary = 25000
	WHERE   EmpID = 2900
--Now in a separate query window:  TRANSACTIONISOLATIONLEVELREADCOMMITTED
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900
---You will note that, like READ COMMITTED, the correct snapshot of the data row is returned, yielding empSalary = 22000, 
--which is consistent and correct. Rollback the transaction.
--- Rollback the update 
Rollback;
/* 
Experiment 4: Read using REPEATABLE READ
The REPEATABLE READ isolation level is similar to the READ COMMITTED isolation level, 
in that it guarantees the output of uncommitted transactions won’t be read by other concurrent transactions. 
However, if a separate concurrent transaction commits before the first one, it is possible to read the same row twice 
within the transaction and obtain different values. 
Likewise it is possible that additional ‘phantom’ rows could be present depending on the behavior of the concurrent transaction.
Execute the following:
*/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
SET NOCOUNT ON
GO
BEGIN TRAN
	SELECT  EmpID, EmpName, EmpSalary
	FROM    dbo.TestIsolationLevels 
	WHERE   EmpID = 2900
	WAITFOR DELAY '00:00:15'
	SELECT  EmpID, EmpName, EmpSalary
	FROM    dbo.TestIsolationLevels 
	WHERE   EmpID = 2900
COMMIT
---Now while this is executing, execute the following in a separate query window: RepeatableReadDemo
BEGIN TRAN
	UPDATE  dbo.TestIsolationLevels 
	SET     EmpSalary = 25000
	WHERE   EmpID = 2900
COMMIT
---Despite the two SELECTs being in one explicit transaction, the empSalary value differs between the individual statements in that transaction. 
---The next isolation level helps to solve this problem.
/* 
REPEATABLE READ is the isolation level to use if read requests (note: not updates) are returning inconsistent data *within one transaction*, 
and consists of a superset of the READ COMMITTED isolation type features (i.e. it encapsulates READ COMMITTED characteristics). 
Here is an example of using REPEATABLE READ when a concurrent UPDATE is occurring:
*/
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
SET NOCOUNT ON
GO
BEGIN TRAN
	SELECT  EmpID, EmpName, EmpSalary
	FROM    dbo.TestIsolationLevels 
	WHERE   EmpID = 2900
	WAITFOR DELAY '00:00:15'
	SELECT  EmpID, EmpName, EmpSalary
	FROM    dbo.TestIsolationLevels 
	WHERE   EmpID = 2900
COMMIT
---Run the below while the above is executing: RepeatableReadDemo
BEGIN TRAN
	UPDATE  dbo.TestIsolationLevels
	SET     EmpSalary = 25000
	WHERE   EmpID = 2900
COMMIT
 
---You’ll notice that the UPDATE transaction is waiting on the SELECT transaction, 
---and that the SELECT transaction yields the correct data if the transaction consistency as a whole is considered. 
---Interestingly though, this still doesn’t hold true for phantom rows 
--– it’s possible to insert rows into a table and have the rows returned by a calling SELECT transaction even under the REPEATABLE READ isolation level.
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
SET NOCOUNT ON
GO
BEGIN TRAN
	SELECT  EmpName
	FROM    dbo.TestIsolationLevels 
	WAITFOR DELAY '00:00:15'
	SELECT  EmpName
	FROM    dbo.TestIsolationLevels 
COMMIT
---Run the below while the above is executing: PhantomDemo
BEGIN TRAN
	INSERT INTO dbo.TestIsolationLevels VALUES (3427, 'Phantom Employee 1', 30000)
COMMIT
/* 
To counter this problem, we need to use the SERIALIZABLE isolation level – the toughest of the bunch.
Experiment 5: Serializable Isolation
SERIALIZABLE has all the features of READ COMMITTED, REPEATABLE READ but also ensures concurrent transactions are treated as if they had been run in serial. 
This means guaranteed repeatable reads, and no phantom rows. 
Be warned, however, that this (and to some extent, the previous two isolation levels) can cause large performance losses 
as concurrent transactions are effectively queued. 
Here’s the phantom rows example used in the previous section again but this time using the SERIALIZABLE isolation level:
*/
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET NOCOUNT ON
GO
BEGIN TRAN
	SELECT  EmpName
	FROM    dbo.TestIsolationLevels 
	WAITFOR DELAY '00:00:15'
	SELECT  EmpName
	FROM    dbo.TestIsolationLevels 
COMMIT
---Run the below while the above is executing:
BEGIN TRAN
	INSERT INTO dbo.TestIsolationLevels VALUES (3427, 'Phantom Employee 1', 30000)
COMMIT
 
/*
The reason there are five variable levels of transaction isolation in SQL Server is so the DBA or developer can tailor 
the isolation level to the type of query (and frequency of query) being performed. 
Generally, the more pessimistic the isolation level (SERIALIZABLE, READ COMMITTED – locking), the worse the performance of the query operating under that scope. 
This is plain to see when you consider one example, READ COMMITTED – locking, which forces other queries to wait for the resources being 
held for the first query. 
This can cause significant performance delays along the application stack, potentially leading to timeouts or other errors.
However, reducing transaction isolation levels to the most optimistic (READ UNCOMMITTED) is not necessarily a good idea 
under all circumstances either.
Some systems, such as finance / banking systems, require absolute data integrity and for this to be maintained, 
the isolation principle is paramount. 
You should choose carefully the level of transaction isolation depending on what is required from the query or queries you are writing. 
Your queries, and associated isolation levels, should always be tested in a suitable test/development environment before deployment to production.

SQL Server SERIALIZABLE Isolation Level and Duplicate Key Insertion Attempts (mssqltips): https://www.mssqltips.com/sqlservertip/2250/sql-server-serializable-isolation-level-and-duplicate-key-insertion-attempts/
Isolation Levels in the Database Engine (Books Online): http://msdn.microsoft.com/en-us/library/ms189122(v=sql.105).aspx
*/
