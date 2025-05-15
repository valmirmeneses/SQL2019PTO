/* 1. **sys.dm_os_wait_stats**
**Description**: Returns information about all the waits encountered by threads that executed.
**Use Case**: Useful for identifying performance bottlenecks related to waits.
**How to Use**: Query this DMV to get details about wait types and wait times.
*/
SELECT wait_type, wait_time_ms, waiting_tasks_count 
FROM sys.dm_os_wait_stats;

--**Note**: Analyze the wait types to identify the root cause of performance issues [1](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views?view=sql-server-ver16).

/* 2. **sys.dm_os_sys_memory**
**Description**: Returns memory information for the SQL Server instance.
**Use Case**: Useful for monitoring memory pressure and availability.
**How to Use**: Query this DMV to get details about physical memory and memory state.
*/
SELECT available_physical_memory_kb, total_physical_memory_kb 
FROM sys.dm_os_sys_memory;

--**Note**: Check the available physical memory to determine if there is sufficient memory for SQL Server operations [2](https://www.dbblogger.com/post/sql-server-queries-to-troubleshoot-memory-pressure-on-sql-instance).

/* 3. **sys.dm_os_schedulers**
**Description**: Returns information about the status of schedulers.
**Use Case**: Useful for monitoring CPU usage and identifying CPU-related issues.
**How to Use**: Query this DMV to get details about scheduler status and CPU usage.
*/
SELECT scheduler_id, cpu_id, status, is_online, is_idle 
FROM sys.dm_os_schedulers;

--**Note**: Look for schedulers that are offline or idle to identify potential CPU bottlenecks [1](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views?view=sql-server-ver16).

/* 4. **sys.dm_os_memory_clerks**
**Description**: Returns information about memory clerks that are currently active.
**Use Case**: Useful for monitoring memory usage by different components.
**How to Use**: Query this DMV to get details about memory clerks and their memory usage.
*/
SELECT clerk_type, memory_node_id, pages_kb 
FROM sys.dm_os_memory_clerks;

--**Note**: Identify memory clerks consuming the most memory to optimize memory usage [1](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views?view=sql-server-ver16).

/* 5. **sys.dm_os_performance_counters**
**Description**: Returns information about performance counters maintained by SQL Server.
**Use Case**: Useful for monitoring various performance metrics.
**How to Use**: Query this DMV to get details about performance counters.
*/
SELECT object_name, counter_name, instance_name, cntr_value 
FROM sys.dm_os_performance_counters;

--**Note**: Use performance counters to monitor key metrics such as CPU usage, memory usage, and I/O operations [1](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views?view=sql-server-ver16).

/* 6. **sys.dm_os_process_memory**
**Description**: Returns information about the memory usage of the SQL Server process.
**Use Case**: Useful for monitoring the memory usage of the SQL Server process.
**How to Use**: Query this DMV to get details about process memory usage.
*/
SELECT physical_memory_in_use_kb, large_page_allocations_kb 
FROM sys.dm_os_process_memory;

--**Note**: Monitor the physical memory in use to ensure the SQL Server process has sufficient memory [1](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views?view=sql-server-ver16).

