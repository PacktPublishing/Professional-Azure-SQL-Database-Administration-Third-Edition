-- Get utilization in last 6 hours for the SQL Mananged Isntance 
Declare @StartTime DATETIME = DATEADD(HH,-6,GetUTCDate()), @EndTime DATETIME = GetUTCDate() 
SELECT start_time,resource_name, avg_cpu_percent,storage_space_used_mb,reserved_storage_mb,io_requests   
FROM sys.server_resource_stats   
WHERE start_time BETWEEN @StartTime AND @EndTime
ORDER BY start_time desc

-- Get the CPU usage>80%
select start_time,
    [cpu usage %] = avg_cpu_percent
from sys.server_resource_stats where avg_cpu_percent>80
order by start_time desc 

-- Get all sessions for user miadmin 
SELECT session_id,program_name, status, reads, writes, logical_reads from sys.dm_exec_sessions WHERE login_name='miadmin'

--The following query returns all requests for the miadmin login:
select s.session_id, s.status AS session_status, r.status AS request_status, r.cpu_time, r.total_elapsed_time, r.writes,
r.logical_reads, t.Text AS query_batch_text, SUBSTRING(t.text, (r.statement_start_offset/2)+1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(t.text)
ELSE r.statement_end_offset
END - r.statement_start_offset)/2) + 1) AS running_query_text FROM sys.dm_exec_sessions s join	sys.dm_exec_requests r
ON r.session_id=s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t WHERE s.login_name='miadmin'

