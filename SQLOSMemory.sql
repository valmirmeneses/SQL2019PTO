
/*
SQL Server memory pressure can cause a lot of problems. This is a list of queries you can run to troubleshoot memory pressure problems. Read more here.

Performance troubleshooting requires looking at various layers – System, hardware, OS, Disk, CPU, and Memory. 
If you see SQL Server consumes a lot of memory, does it sign SQL Server needs more memory? 
Not exactly. SQL Server default mechanism consumes maximum allocated memory for its internal storage, such as buffer pool. 
Therefore, you need to understand the current memory configuration and different DMVs output to find that you have memory pressure and SQL Server needs more memory. 

If there is a memory problem, your system needs to be adequately investigated. 
We may have to start using other DMVs and memory dump to identify precisely where to analyze the memory bottleneck and its fix. 
The first step is to identify the minimum and maximum size of allocated memory. 
The SQL Server max memory is default set to 2,147,483,647 megabytes (MB). 
In this case, SQL Server might consume most of the server memory, and that might cause a bottleneck for OS processes.
*/
--- Server Min and Max Memory
SELECT [name] AS [Name]
   ,[configuration_id] AS [Number]
   ,[minimum] AS [Minimum]
   ,[maximum] AS [Maximum]
   ,[is_dynamic] AS [Dynamic]
   ,[is_advanced] AS [Advanced]
   ,[value] AS [ConfigValue]
   ,[value_in_use] AS [RunValue]
   ,[description] AS [Description]
FROM [master].[sys].[configurations]
WHERE NAME IN ('Min server memory (MB)', 'Max server memory (MB)')

/*
The following queries will help you to investigate SQL Server memory bottlenecks. 

DMV sys. dm_os_sys_memory

The sys.dm_os_sys_memory returns the memory information of the SQL Server instance. 
If you have sufficient physical memory, it returns the output as – Available Physical Memory is high. 
Else, it returns the output as Available physical memory is low.

The following queries will help you to investigate SQL Server memory bottlenecks. 

DMV sys. dm_os_sys_memory

The sys.dm_os_sys_memory returns the memory information of the SQL Server instance.
If you have sufficient physical memory, it returns the output as – Available Physical Memory is high. 
Else, it returns the output as Available physical memory is low.

*/
SELECT [total_physical_memory_kb] / 1024 AS[Total_Physical_Memory_In_MB]
    ,[available_page_file_kb] / 1024 AS[Available_Physical_Memory_In_MB]
    ,[total_page_file_kb] / 1024 AS[Total_Page_File_In_MB]
    ,[available_page_file_kb] / 1024 AS[Available_Page_File_MB]
    ,[kernel_paged_pool_kb] / 1024 AS[Kernel_Paged_Pool_MB]
    ,[kernel_nonpaged_pool_kb] / 1024 AS[Kernel_Nonpaged_Pool_MB]
    ,[system_memory_state_desc] AS[System_Memory_State_Desc]
FROM[master].[sys].[dm_os_sys_memory]

/*
Sys.dm_os_process_memory

The sys.dm_os_process_memory returns the SQL Server process running on the Operating System. 
*/


SELECT physical_memory_in_use_kb AS Actual_Usage,
       large_page_allocations_kb AS large_Pages,
       locked_page_allocations_kb AS locked_Pages,
       virtual_address_space_committed_kb AS VAS_Committed,
       large_page_allocations_kb + locked_page_allocations_kb + 427000,
       process_physical_memory_low [Physical Memory Low],
process_virtual_memory_low [Virtual Memory Low]
FROM sys.dm_os_process_memory

/*
Target Server Memory 

The Target Server Memory defines how much memory the SQL Server engine is willing to use. 
We can use DMV sys.dm_os_performance_counters or perform counters to get this value.
*/

SELECT *
FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%Target Server%';


/*
Total Server Memory

The Total Server Memory currently shows the memory used by the SQL Server process. 
Once you start SQL Service, the total memory is low ( minimum memory configuration) and dynamically increases the memory per query workload. 
*/
SELECT *
FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%Total Server%';

Declare @SQLServerMemory as decimal (12,3)
SELECT @SQLServerMemory=cast(cntr_value as decimal (12,3)) FROM sys.dm_os_performance_counters WHERE counter_name LIKE '%Target Server%';

Declare @TotalServerMemory as decimal (12,3)
SELECT @TotalServerMemory=cast(cntr_value as decimal (12,3)) FROM sys.dm_os_performance_counters WHERE counter_name LIKE '%Total Server%';

SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%Total Server%' or counter_name LIKE '%Target Server%';

Select @SQLServerMemory as SQLMemory,@TotalServerMemory  as TotalServerMemory ,Cast(@SQLServerMemory/@TotalServerMemory as decimal (12,3)) as Ratio
/*
Usually, the Total and Target server memory ratio should be close to 1. 
If the total server memory does not increase, it could indicate the followings.

SQL Server has more memory than required. 
   In this case, total server memory(KB) might not reach Target Server Memory(KB), and SQL might cache the entire database into memory.

SQL Server is facing external memory pressure, which could not increase the memory. 
   In this case, you need to check the max server memory and plan to add more memory to SQL Server. 

*/

/*
However, you must also check a few more parameters before considering a memory upgrade.

Page Life Expectancy: Look at the value of page life expectancy. 
*/
SELECT [cntr_value]
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Buffer Manager%'
AND [counter_name] = 'Page life expectancy'
/*
Generally, most people value a PLE threshold of 300 seconds. If PLE is less than 300 seconds, it is considered memory pressure.
However, you should calculate the PLE as per the below formula. 
PLE (Page Life Expectancy) threshold = ((Buffer Memory Allocation (GB)) / 4 ) * 300
For example, if the machine is configured with 64 GB and 50GB is allocated to the SQL Server instance, then the PLE threshold will be as below:
PLE (Page Life Expectancy) threshold = (50 / 4) * 300
PLE (Page Life Expectancy) threshold = 3750 Seconds
*/

/*
Buffer cache hit ratio

SQL Server buffer cache ratio defines how often SQL Server hits the buffer cache to get data instead of going to disk. Usually, its value should be 90-95%. The higher the buffer cache hit ratio, the better SQL Server performance. 
*/
SELECT [cntr_value]
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Buffer Manager%'
AND [counter_name] = 'Buffer cache hit ratio'
/*
You can also track it using SQL Server: Buffer Manager: Buffer Cache Hit Ratio perform counter. 
*/
/*
Memory Grants Pending

 The Memory Grants Pending shows the total number of SQL processes waiting for a workspace memory grant. Low max server memory, bad queries, or indexing issues can cause memory grants to be outstanding. You can query sys.dm_exec_query_memory_grants to check queries requiring memory grans for execution.
*/

SELECT [cntr_value]
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Memory Manager%'
AND [counter_name] = 'Memory Grants Pending'
/*
Alternatively, set up the perform counter SQL Server: Memory Manager – Memory Grant Pending for tracking this.
*/


/*
Memory Consumption Report

SSMS Memory consumption report is also an excellent way to check memory breakdown to individual components in SQL Server instance. 
To get the report, right-click on the instance in SSMS and navigate to Reports-> Standard Reports -> Memory Consumption. 

https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/performance/troubleshoot-memory-issues
*/