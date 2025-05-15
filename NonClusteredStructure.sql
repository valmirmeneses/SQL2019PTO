USE AdventureWorks;
GO

-- Step 1: Create a nonclustered index with included columns
CREATE NONCLUSTERED INDEX IX_Person_LastName
ON Person.Person (LastName)
INCLUDE (FirstName, MiddleName);
GO

-- Step 2: Enable trace flag to allow DBCC PAGE output
DBCC TRACEON (3604,-1);
GO

SELECT  
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
	i.index_id as Index_ID,
    STUFF((
        SELECT ', ' + c.name
        FROM sys.index_columns ic
        JOIN sys.columns c 
            ON ic.object_id = c.object_id 
            AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id 
            AND ic.index_id = i.index_id
        ORDER BY ic.key_ordinal
        FOR XML PATH('')
    ), 1, 2, '') AS IndexColumns
FROM sys.indexes i
WHERE OBJECT_NAME(i.object_id) = 'Person' and  OBJECT_SCHEMA_NAME(i.object_id)='Person'
ORDER BY SchemaName, TableName, IndexName;


-- ============================================
-- Script: Inspect Pages in a File Using sys.dm_db_page_info
-- Description: Returns metadata for a range of pages in a specific file
-- ============================================

-- Step 1: Declare parameters

DECLARE @start_page_id INT = 0;     -- Starting page_id
DECLARE @end_page_id INT = 9999999;    -- Ending page_id

-- Step 2: Generate page numbers using a CTE
WITH PageNumbers AS (
    SELECT TOP (@end_page_id - @start_page_id + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 + @start_page_id AS page_id
    FROM sys.all_objects
)
-- Step 3: Apply sys.dm_db_page_info to each page
SELECT 
    pn.page_id,
    pi.page_type_desc,
    pi.page_level,
    pi.page_flag_bits_desc,
    pi.has_ghost_records
FROM PageNumbers pn
CROSS APPLY sys.dm_db_page_info (
    DB_ID(),       -- Current database
    1,      -- File ID
    pn.page_id,    -- Page ID
    'DETAILED'     -- Use 'LIMITED' for faster performance
) AS pi;


-- Step 4: Get the page IDs used by the index

SELECT 
    allocated_page_file_id,
    allocated_page_page_id,
    page_type_desc
	--,*
FROM sys.dm_db_database_page_allocations (
    DB_ID('AdventureWorks'), 
    OBJECT_ID('Person.Person'), 
    4, 
    NULL, 
    'DETAILED')
--where page_type_desc='INDEX_PAGE'
--order by allocated_page_page_id

GO
DBCC PAGE ('AdventureWorks', 1, 194575, 3); ---IAM Page

-- Step 5: Inspect one of the leaf-level pages
-- Replace <file_id> and <page_id> with values from the previous query
DBCC PAGE ('AdventureWorks', 1, 206744, 3); --- Intermediate Values from A-Z
DBCC PAGE ('AdventureWorks', 1, 206696, 3);

GO
/*
In the output of DBCC PAGE, look for entries like:
Slot 0 Column 1 Offset 0x60 Length 25 - Abbas
This confirms that FirstName and MiddleName (the included columns) are stored only in the leaf-level data pages, not in the intermediate or root levels of the index.
*/



SELECT 
    allocated_page_file_id,
    allocated_page_page_id
INTO #PageList
FROM sys.dm_db_database_page_allocations (
    DB_ID(),         -- Current database
    NULL,            -- All objects
    NULL,            -- All indexes
    NULL,            -- All partitions
    'LIMITED'        -- Faster, basic info
)
drop table #PageList
SELECT 
    allocated_page_file_id,
    allocated_page_page_id
INTO #PageList
FROM sys.dm_db_database_page_allocations (
    DB_ID('AdventureWorks'), 
    OBJECT_ID('Person.Person'), 
    4, -- Replace with your file_id
    NULL, 
    'LIMITED')






SELECT 
    p.allocated_page_file_id,
    p.allocated_page_page_id,
    pi.page_type_desc,
    pi.page_level,
    pi.page_flag_bits_desc,
    pi.has_ghost_records
FROM #PageList p
CROSS APPLY sys.dm_db_page_info (
    DB_ID(),
    p.allocated_page_file_id,
    p.allocated_page_page_id,
    'DETAILED'
) AS pi;





SELECT 
  page_id = allocated_page_page_id,
  index_id,
  page_type_desc 
FROM sys.dm_db_database_page_allocations
(
  DB_ID(),
  OBJECT_ID(N'Person.Person'),
  NULL,
  NULL,
  N'DETAILED'
)
WHERE is_allocated = 1
and page_type_desc='INDEX_PAGE'
order  by page_ID;

SELECT 
  page_id = allocated_page_page_id,
  index_id,
  page_type_desc 
FROM sys.dm_db_database_page_allocations
(
  DB_ID(),
  OBJECT_ID(N'Person.Person'),
  NULL,
  NULL,
  N'DETAILED'
)
WHERE is_allocated = 1
and page_type_desc='DATA_PAGE'
order  by page_ID;

