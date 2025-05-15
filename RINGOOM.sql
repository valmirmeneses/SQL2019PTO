SELECT record
FROM   sys.dm_os_ring_buffers
WHERE  ring_buffer_type = 'RING_BUFFER_OOM';
