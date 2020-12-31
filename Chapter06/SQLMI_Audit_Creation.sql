--Get the container URL and SAS key before running this command.
--Run following command to create credential.
CREATE CREDENTIAL [https://packtsqlmistorage.blob.core.windows.net/sqlmiaudit]
WITH IDENTITY='SHARED ACCESS SIGNATURE',
SECRET = '<SAS TOEKN>'
GO

--Create server audit
CREATE SERVER AUDIT [auditlog]
TO URL ( PATH ='https://packtsqlmistorage.blob.core.windows.net/sqlmiaudit' , RETENTION_DAYS =  30 )
GO

--Enable server audit
ALTER SERVER AUDIT [auditlog]
WITH (STATE=ON);
GO

--Verify server audit status
select name,status,status_desc from sys.dm_server_audit_status where name='Audit-SQLMI';

