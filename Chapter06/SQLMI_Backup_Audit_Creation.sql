-- Create credential for audit logs . Skip this steps if it's already configured.
CREATE CREDENTIAL [https://packtsqlmistorage.blob.core.windows.net/sqlmiaudit]
WITH IDENTITY='SHARED ACCESS SIGNATURE',
SECRET = '<SAS TOEKN>'

-- Create server audit
CREATE SERVER AUDIT [BackupRestoreAudit]
TO URL (PATH = 'https://packtsqlmistorage.blob.core.windows.net/sqlmiaudit',RETENTION_DAYS = 30);
GO

-- Define events to audit
CREATE SERVER AUDIT SPECIFICATION BackupRestoreAuditSpec
FOR SERVER AUDIT [BackupRestoreAudit]
ADD (BACKUP_RESTORE_GROUP),
ADD (AUDIT_CHANGE_GROUP)
WITH (STATE=ON);
 
--Enable audit 
ALTER SERVER AUDIT [BackupRestoreAudit]
WITH (STATE=ON);

--Get audit file path
select name, audit_file_path
from sys.dm_server_audit_status
where name = 'BackupRestoreAudit' and audit_file_path is not null

--Check backup logs from audit file
SELECT event_time, succeeded, statement, server_instance_name,
server_principal_name, client_ip, application_name, duration_milliseconds
FROM sys.fn_get_audit_file
('https://packtsqlmistorage.blob.core.windows.net/sqlmiaudit/packtsqlmi/master/BackupRestoreAudit/2020-10-26/10_56_51_753_0.xel', default, default);

--Clean up
-- Drop server audit specification
ALTER SERVER AUDIT SPECIFICATION BackupRestoreAuditSpec
WITH (STATE=OFF);
DROP SERVER AUDIT SPECIFICATION BackupRestoreAuditSpec

-- Drop server audit
ALTER SERVER AUDIT [BackupRestoreAudit]
WITH (STATE=OFF);
DROP SERVER AUDIT [BackupRestoreAudit]

--Verify cleanup, empty results means server audit is stopped.

select name,status,status_desc from sys.dm_server_audit_status where name='BackupRestoreAudit';

