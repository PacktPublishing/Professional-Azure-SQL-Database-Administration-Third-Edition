/*Perform Manual COPY_ONLY backup on Azure SQL Managed Instance.
--Before running create credentials command, generate SAS token using Azure Portal.
--Steps for generating SAS token is explained in chapter.
--Create credential to access blob storage*/
ALTER CREDENTIAL [https://packtsqlmistorage.blob.core.windows.net/backup] 
WITH IDENTITY='SHARED ACCESS SIGNATURE'
, SECRET = 'sv=2019-12-12&ss=bfqt&srt=o&sp=rwdlacupx&se=2020-10-30T03:25:05Z&st=2020-10-01T19:25:05Z&spr=https&sig=nJlosYn3PJxIqwo%2BSp9Yk7ug%2FyyngFYQP0PZaeUwU90%3D';

--Bckup database option 1 to URL
BACKUP DATABASE toystore
TO URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore.bak'
WITH COPY_ONLY

--Bckup database option 2 to URL
--Stripping backups if backup size is >200GB
BACKUP DATABASE toystore
TO URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-1.bak',
URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-2.bak',
URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-3.bak',
URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-4.bak'
WITH COPY_ONLY,COMPRESSION,FORMAT

--Bckup database option 3 to URL
--Backup database with MAXTRANSFERSIZE
BACKUP DATABASE toystore
TO URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-1.bak',
URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-2.bak',
URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-3.bak',
URL = 'https://packtsqlmistorage.blob.core.windows.net/backup/toystore-4-4.bak'
WITH COPY_ONLY, MAXTRANSFERSIZE = 4194304, COMPRESSION,FORMAT