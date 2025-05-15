--Need to Add More CPUs
--To determine if you need more CPUs, you can use the sys.dm_os_schedulers DMV to check the CPU usage and scheduler status.
SELECT scheduler_id, cpu_id, status, is_online, is_idle, current_tasks_count, runnable_tasks_count, active_workers_count, load_factor
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE';
--This query helps you understand the load on each scheduler and whether there are many tasks waiting to be processed, indicating a potential need for more CPUs.
--Need to Add More Memory
--To check if you need more memory, you can use the sys.dm_os_sys_memory DMV to get an overview of the memory status.
SELECT total_physical_memory_kb, available_physical_memory_kb, total_page_file_kb, available_page_file_kb, system_memory_state_desc
FROM sys.dm_os_sys_memory;
--This query provides information about the total and available physical memory, as well as the page file usage, helping you determine if additional memory is required.
--Running Under Memory Pressure
--To identify if SQL Server is running under memory pressure, you can use the sys.dm_os_memory_clerks DMV to see memory usage by different components.
SELECT type, SUM(pages_kb) AS total_memory_kb
FROM sys.dm_os_memory_clerks
GROUP BY type
ORDER BY total_memory_kb DESC;
--This query shows the memory usage by different memory clerks, helping you identify if certain components are consuming excessive memory.
--Have Problems with Disks
--To diagnose disk-related issues, you can use the sys.dm_io_virtual_file_stats DMV to get I/O statistics for database files.
SELECT DB_NAME(database_id) AS database_name, file_id, io_stall_read_ms, io_stall_write_ms, num_of_reads, num_of_writes, size_on_disk_bytes
FROM sys.dm_io_virtual_file_stats(NULL, NULL);
--This query provides information about I/O stalls and the number of reads and writes for each database file, helping you identify potential disk performance issues.
--Move to a 64-bit Based Solution
--To check if your SQL Server instance is running on a 64-bit platform, you can use the sys.dm_os_sys_info DMV.
SELECT sqlserver_start_time, cpu_count, hyperthread_ratio, physical_memory_kb, virtual_memory_kb, committed_target_kb, visible_target_kb
FROM sys.dm_os_sys_info;
--This query provides information about the system's CPU count, memory, and other details, helping you determine if you are running on a 64-bit platform.
--Need to Change Your Application for Query Correctness Reasons
--To identify queries that may need to be corrected, you can use the sys.dm_exec_query_stats DMV to find queries with high execution counts or long durations.
SELECT TOP 10
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_logical_writes,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, (qs.statement_start_offset/2) + 1, 
    ((CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(qt.text)
        ELSE qs.statement_end_offset
    END - qs.statement_start_offset)/2) + 1) AS query_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY qs.total_elapsed_time DESC;
--This query helps you identify long-running or frequently executed queries that may need optimization or correction.
--What Applications are Loaded into the SQL Server Address Space
--To see what modules are loaded into the SQL Server address space, you can use the sys.dm_os_loaded_modules DMV.
SELECT name, description, company, file_version, product_version, base_address
FROM sys.dm_os_loaded_modules;
--This query provides information about the modules loaded into SQL Server's address space, helping you identify any third-party applications or components.
--If SQL Server is Paged Out and If It Affects Performance of Your Application
--To check if SQL Server is being paged out, you can use the sys.dm_os_ring_buffers DMV to look for memory-related ring buffer records.


select top 10
    id, SQLServerCPUUtilization, 100 - SystemIdle - SQLServerCPUUtilization as NonSQLCPUUtilization,SQLServerMemoryUtilization,
	SystemIdle -- SystemIdle on Linux will be 0
	,UserModeTime,KernelModeTime
	,originalrecord
from (
select
        record.value('(./Record/@id)[1]', 'int') as id,
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') as SystemIdle,
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as SQLServerCPUUtilization,
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/MemoryUtilization)[1]', 'int') as SQLServerMemoryUtilization,
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/UserModeTime)[1]', 'int') as UserModeTime,
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime)[1]', 'int') as KernelModeTime,
        timestamp,originalrecord
    from (
			select timestamp, convert(xml, record) as record, record as originalrecord
					from sys.dm_os_ring_buffers
					where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
						and record like '%<SystemHealth>%') as RingBufferInfo
			) AS TabularInfo
order by id desc

--This query helps you identify if SQL Server is experiencing memory pressure and being paged out, which can affect performance.
--If Your Hardware is NUMA
--To check if your hardware is NUMA, you can use the sys.dm_os_nodes DMV.
SELECT node_id, node_state_desc, memory_node_id, online_scheduler_count, active_worker_count, avg_load_balance
FROM sys.dm_os_nodes
WHERE node_state_desc <> 'ONLINE DAC';
/*This query provides information about the NUMA nodes in your system, helping you determine if your hardware is NUMA.*/

