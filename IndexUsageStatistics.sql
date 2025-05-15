/*
1. Index Usage Statistics
This script shows how often indexes on the Person.Address table are used (seeks, scans, lookups, updates):
*/
SELECT 
    OBJECT_NAME(IUS.[object_id]) AS [ObjectName],
    I.[name] AS [IndexName],
    IUS.[user_seeks],
    IUS.[user_scans],
    IUS.[user_lookups],
    IUS.[user_updates],
    IUS.[last_user_seek],
    IUS.[last_user_scan],
    IUS.[last_user_lookup],
    IUS.[last_user_update]
FROM 
    sys.dm_db_index_usage_stats AS IUS
    INNER JOIN sys.indexes AS I 
        ON I.[object_id] = IUS.[object_id] 
        AND I.[index_id] = IUS.[index_id]
WHERE 
    OBJECT_NAME(IUS.[object_id]) = 'Address'
    AND IUS.database_id = DB_ID('AdventureWorks')
ORDER BY 
    [ObjectName], [IndexName];
/*
2. Index Physical Statistics
This script provides fragmentation and page count details for indexes on the same table:
*/
SELECT 
    OBJECT_NAME(IPS.[object_id]) AS [ObjectName],
    I.[name] AS [IndexName],
    IPS.[index_type_desc],
    IPS.[avg_fragmentation_in_percent],
    IPS.[page_count]
FROM 
    sys.dm_db_index_physical_stats(
        DB_ID('AdventureWorks'), 
        OBJECT_ID('Person.Address'), 
        NULL, NULL, 'DETAILED'
    ) AS IPS
    INNER JOIN sys.indexes AS I 
        ON I.[object_id] = IPS.[object_id] 
        AND I.[index_id] = IPS.[index_id]
ORDER BY 
    [ObjectName], [IndexName];



