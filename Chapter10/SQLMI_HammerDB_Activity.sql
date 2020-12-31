-- Run the query to check the workload.
select * from qpi.queries; 

--Monitor backup restore option.
select * from qpi.bre

--Monitor blocked queries
select * from qpi.blocked_queries;

--Set the baseline for file stats.
exec qpi.snapshot_file_stats;

-- Get the file stats
select * from qpi.file_stats where db_name='tpcc1';

 --  Take the wait statistics baseline
exec qpi.snapshot_wait_stats;

   --  Get the wait stats
select * from qpi.wait_stats order by wait_time_s desc;

--Alter statement to increase data file size.

ALTER DATABASE [tpcc1] MODIFY FILE ( NAME = N'data_0', SIZE =  250GB)
