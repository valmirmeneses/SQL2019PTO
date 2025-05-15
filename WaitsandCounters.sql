select distinct wait_type FROM  sys.dm_os_waiting_tasks
select distinct wait_type FROM  sys.dm_os_wait_stats
select object_name,counter_name FROM  sys.dm_os_performance_counters