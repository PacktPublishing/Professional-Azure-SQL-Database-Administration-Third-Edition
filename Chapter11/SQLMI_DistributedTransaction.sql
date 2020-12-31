	
	-- Configure the Linked Server
    -- Add one Azure SQL Managed Instance as Linked Server
    EXEC sp_addlinkedserver
        @server='RemoteSQLMI', -- Linked server name
        @srvproduct='',
        @provider='sqlncli', -- SQL Server Native Client
        @datasrc='packtsqlmi2.231383d50c2f.database.windows.net' -- Managed Instance endpoint

    -- Add credentials and options to this Linked Server
    EXEC sp_addlinkedsrvlogin
        @rmtsrvname = 'RemoteSQLMI', -- Linked server name
        @useself = 'false',
        @rmtuser = 'miadmin',         -- login
        @rmtpassword = '<Enter your password here>' -- password

    USE toystore;
    GO
	--Stopping executon and rolling it back for any error
    SET XACT_ABORT ON;
    GO
	--Start of distributed transaciton
    BEGIN DISTRIBUTED TRANSACTION;

	--Select order before deletion on local instance
	Select OrderID FROM [toystore].[Sales].[Orders] WHERE OrderID = 73499;
    -- Delete Order from local instance.
    DELETE FROM [toystore].[Sales].[Orders] WHERE OrderID = 73499;
	--Select Order After deletion on local instance
	Select OrderID FROM [toystore].[Sales].[Orders] WHERE OrderID = 73499;

	--Select order before deletion on remote instance
	Select OrderID FROM [RemoteSQLMI].[toystore].[Sales].[Orders] WHERE OrderID = 73499;
    -- Delete candidate from remote instance.
    DELETE FROM [RemoteSQLMI].[toystore].[Sales].[Orders] WHERE OrderID = 73499;
	--Select order after deletion on remote instance
	Select OrderID FROM [RemoteSQLMI].[toystore].[Sales].[Orders] WHERE OrderID = 73499;
	
	--Commit
    COMMIT TRANSACTION;
    GO