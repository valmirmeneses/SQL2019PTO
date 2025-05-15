CREATE VIEW Lock_checks AS
SELECT 
    request_session_id AS SessionID, 
    DB_NAME(resource_database_id) AS DatabaseName, 
    CASE 
        WHEN resource_type = 'OBJECT' THEN OBJECT_NAME(resource_associated_entity_id) 
        WHEN resource_associated_entity_id = 0 THEN 'Not Applicable' 
        ELSE OBJECT_NAME(p.object_id) 
    END AS EntityName, 
    index_id AS IndexID, 
    resource_type AS ResourceType, 
    resource_description AS ResourceDescription, 
    request_mode AS RequestMode, 
    request_status AS RequestStatus 
FROM 
    sys.dm_tran_locks t 
LEFT JOIN 
    sys.partitions p ON p.partition_id = t.resource_associated_entity_id 
WHERE 
    resource_database_id = DB_ID() AND resource_type <> 'DATABASE'; 
