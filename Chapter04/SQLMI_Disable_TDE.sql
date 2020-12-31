Use [toystore]
go
--1. Check if the database is encrypted with TDE:
Select * from sys.dm_database_encryption_keys
go
--2. If the db is encrypted, alter the db to turn off encryption. Make sure there is no active transaction when performing this operation:
Alter database toystore set encryption Off
go
--3. Run checkpoint on the db:
Checkpoint
go
--4. Drop the database encryption key (DEK):
DROP DATABASE ENCRYPTION KEY
go
--5. Truncate the Log: run sp_helpdb 'toystore' to get log filename.
DBCC SHRINKFILE (log, 1)
go
--6. Run select * from sys.dm_db_log_info. This should not show any active VLF that is encrypted by thumbprint.
select * from sys.dm_db_log_info(db_id());
go
--7. Take the backup.
