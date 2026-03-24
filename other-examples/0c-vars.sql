-- get sql server version:
-- Microsoft SQL server 2022 ...
-- double @ is for system functions or global variables
select @@version as version;

-- global variables examples
select @@ROWCOUNT as rows_affected;

select @@SERVERNAME as server_name;

select @@SERVICENAME as service_name;

select @@ERROR;
GO

/*
    Context Functions
    NOTE: SQL Server does NOT know the name of the script file executing,
    because the client reads the file and sends only the text to the server.
*/
SELECT 
    APP_NAME() AS [Application],   -- e.g. 'Microsoft SQL Server Management Studio - Query'
    HOST_NAME() AS [Host],         -- Your computer name
    CURRENT_USER AS [User],        -- Database user
    SYSTEM_USER AS [Login];        -- Server login
GO