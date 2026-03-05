SELECT  name
        , database_id
        , create_date
FROM sys.databases;
GO

EXEC sp_databases;
GO

exec sp_help sp_databases;
GO

SELECT name
FROM master.dbo.sysdatabases;
GO
