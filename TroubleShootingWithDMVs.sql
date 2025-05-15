--Identify CPU-Intensive Queries

SELECT TOP 10 
    qs.sql_handle,
    qs.execution_count,
    qs.total_worker_time AS TotalCPU,
    qs.total_worker_time / qs.execution_count AS AvgCPU,
    SUBSTRING(qt.text, qs.statement_start_offset / 2, 
              (CASE 
                  WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
                  ELSE qs.statement_end_offset 
               END - qs.statement_start_offset) / 2) AS query_text
FROM 
    sys.dm_exec_query_stats AS qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY 
    TotalCPU DESC;




--Identify Queries with High Logical Reads


SELECT TOP 10 
    qs.sql_handle,
    qs.execution_count,
    qs.total_logical_reads AS TotalReads,
    qs.total_logical_reads / qs.execution_count AS AvgReads,
    SUBSTRING(qt.text, qs.statement_start_offset / 2, 
              (CASE 
                  WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
                  ELSE qs.statement_end_offset 
               END - qs.statement_start_offset) / 2) AS query_text
FROM 
    sys.dm_exec_query_stats AS qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY 
    TotalReads DESC;

--Find Missing Indexes


SELECT 
    migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM 
    sys.dm_db_missing_index_group_stats AS migs
INNER JOIN 
    sys.dm_db_missing_index_groups AS mig ON migs.group_handle = mig.index_group_handle
INNER JOIN 
    sys.dm_db_missing_index_details AS mid ON mig.index_handle = mid.index_handle
ORDER BY 
    improvement_measure DESC;

---Monitor Wait Statistics


SELECT 
    wait_type,
    waiting_tasks_count,
    wait_time_ms / 1000.0 AS wait_time_seconds,
    (wait_time_ms - signal_wait_time_ms) / 1000.0 AS resource_wait_time_seconds,
    signal_wait_time_ms / 1000.0 AS signal_wait_time_seconds
FROM 
    sys.dm_os_wait_stats
ORDER BY 
    wait_time_ms DESC;

--Check Index Usage Statistics

SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM 
    sys.dm_db_index_usage_stats AS s
INNER JOIN 
    sys.indexes AS i ON s.object_id = i.object_id AND i.index_id = s.index_id
WHERE 
    s.database_id = DB_ID('AdventureWorks')
ORDER BY 
    s.user_seeks DESC;




--Analyze Query Performance


SELECT 
    TOP 10 
    qs.sql_handle,
    qs.plan_handle,
    qs.execution_count,
    qs.total_elapsed_time / 1000 AS total_elapsed_time_ms,
    qs.total_worker_time / 1000 AS total_worker_time_ms,
    qs.total_logical_reads,
    qs.total_logical_writes,
    qs.total_physical_reads,
    qs.creation_time,
    qs.last_execution_time,
    SUBSTRING(st.text, (qs.statement_start_offset / 2) + 1, 
              ((CASE qs.statement_end_offset 
                  WHEN -1 THEN DATALENGTH(st.text)
                  ELSE qs.statement_end_offset 
               END - qs.statement_start_offset) / 2) + 1) AS statement_text,
    DB_NAME(st.dbid) AS database_name
FROM 
    sys.dm_exec_query_stats AS qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY 
    qs.total_elapsed_time DESC;

--Identify Blocking Sessions


SELECT 
    blocking_session_id AS BlockingSessionID,
    s.session_id AS BlockedSessionID,
    wait_type,
    wait_time / 1000 AS wait_time_seconds,
    wait_resource,
    SUBSTRING(st.text, (r.statement_start_offset / 2) + 1, 
              ((CASE r.statement_end_offset 
                  WHEN -1 THEN DATALENGTH(st.text)
                  ELSE r.statement_end_offset 
               END - r.statement_start_offset) / 2) + 1) AS query_text,
    DB_NAME(r.database_id) AS database_name
FROM 
    sys.dm_exec_requests AS r
INNER JOIN 
    sys.dm_exec_sessions AS s ON r.session_id = s.session_id
CROSS APPLY 
    sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE 
    blocking_session_id <> 0
ORDER BY 
    wait_time_seconds DESC;

--Inspect TempDB Usage

SELECT 
    SUM(user_object_reserved_page_count) AS UserObjectsPagesUsed,
    SUM(internal_object_reserved_page_count) AS InternalObjectsPagesUsed,
    SUM(version_store_reserved_page_count) AS VersionStorePagesUsed,
    SUM(unallocated_extent_page_count) AS UnallocatedPages,
    SUM(mixed_extent_page_count) AS MixedPages
FROM 
    sys.dm_db_file_space_usage;



--Analyze Active Expensive Queries

SELECT 
    r.session_id,
    r.cpu_time,
    r.total_elapsed_time,
    r.reads,
    r.writes,
    r.logical_reads,
    SUBSTRING(qt.text, (r.statement_start_offset / 2) + 1, 
              ((CASE r.statement_end_offset 
                  WHEN -1 THEN DATALENGTH(qt.text)
                  ELSE r.statement_end_offset 
               END - r.statement_start_offset) / 2) + 1) AS query_text,
    DB_NAME(r.database_id) AS database_name,
    r.status,
    r.start_time,
    r.command
FROM 
    sys.dm_exec_requests AS r
CROSS APPLY 
    sys.dm_exec_sql_text(r.sql_handle) AS qt
ORDER BY 
    r.cpu_time DESC;

--Identify Fragmented Indexes


SELECT 
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_id,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') AS ips
INNER JOIN 
    sys.indexes AS i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE 
    ips.avg_fragmentation_in_percent > 10 -- Adjust the threshold as needed
    AND ips.page_count > 1000 -- Adjust the threshold as needed
ORDER BY 
    ips.avg_fragmentation_in_percent DESC;





