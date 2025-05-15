/*
Here is the corrected and enhanced version of the `ExecuteLoggedRebuilds` stored procedure. It now includes **detailed error diagnostics** in both the log and the summary output:

---

### ✅ Updated Stored Procedure with Detailed Error Logging

```sql
*/
ALTER PROCEDURE ExecuteLoggedRebuilds
    @SchemaFilter NVARCHAR(128) = NULL,
    @TableFilter NVARCHAR(128) = NULL,
    @IndexFilter NVARCHAR(128) = NULL
AS
BEGIN
    DECLARE @LogID INT,
            @SchemaName NVARCHAR(128),
            @TableName NVARCHAR(128),
            @IndexName NVARCHAR(128),
            @SQL NVARCHAR(MAX),
            @ErrorMessage NVARCHAR(MAX),
            @ErrorNumber INT,
            @ErrorSeverity INT,
            @ErrorState INT,
            @ErrorLine INT,
            @ErrorProcedure NVARCHAR(128);

    CREATE TABLE #Summary (
        LogID INT,
        SchemaName NVARCHAR(128),
        TableName NVARCHAR(128),
        IndexName NVARCHAR(128),
        Status NVARCHAR(50),
        ErrorMessage NVARCHAR(MAX),
        ErrorNumber INT,
        ErrorSeverity INT,
        ErrorState INT,
        ErrorLine INT,
        ErrorProcedure NVARCHAR(128)
    );

    DECLARE LogCursor CURSOR FOR
    SELECT 
        LogID,
        SchemaName,
        TableName,
        IndexName
    FROM 
        IndexRebuildLog
    WHERE 
        Status = 'Statement Logged'
        AND (@SchemaFilter IS NULL OR SchemaName = @SchemaFilter)
        AND (@TableFilter IS NULL OR TableName = @TableFilter)
        AND (@IndexFilter IS NULL OR IndexName = @IndexFilter);

    OPEN LogCursor;
    FETCH NEXT FROM LogCursor INTO @LogID, @SchemaName, @TableName, @IndexName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @SQL = 
                'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + ']' + 
                ' REBUILD WITH (ONLINE = ON, WAIT_AT_LOW_PRIORITY (MAX_DURATION = 5 MINUTES, ABORT_AFTER_WAIT = SELF));';

            EXEC sp_executesql @SQL;

            UPDATE IndexRebuildLog
            SET Status = 'Success', ErrorMessage = NULL
            WHERE LogID = @LogID;

            INSERT INTO #Summary
            VALUES (@LogID, @SchemaName, @TableName, @IndexName, 'Success', NULL, NULL, NULL, NULL, NULL, NULL);
        END TRY
        BEGIN CATCH
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorNumber = ERROR_NUMBER();
            SET @ErrorSeverity = ERROR_SEVERITY();
            SET @ErrorState = ERROR_STATE();
            SET @ErrorLine = ERROR_LINE();
            SET @ErrorProcedure = ERROR_PROCEDURE();

            UPDATE IndexRebuildLog
            SET Status = 'Failure', 
                ErrorMessage = @ErrorMessage
            WHERE LogID = @LogID;

            INSERT INTO #Summary
            VALUES (@LogID, @SchemaName, @TableName, @IndexName, 'Failure', @ErrorMessage, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorProcedure);
        END CATCH

        FETCH NEXT FROM LogCursor INTO @LogID, @SchemaName, @TableName, @IndexName;
    END

    CLOSE LogCursor;
    DEALLOCATE LogCursor;

    -- Return summary
    SELECT * FROM #Summary;

    DROP TABLE #Summary;
END;
/*

---

This version logs and returns:
- The full error message
- Error number, severity, state, line, and procedure
*/