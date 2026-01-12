IF DB_ID('sample') IS NOT NULL
BEGIN
    -- Forcefully disconnect any other users
    ALTER DATABASE sample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE sample;
END;


-- create db if it not exists already
IF DB_ID('sample') IS NULL
	CREATE DATABASE sample;
GO

-- check if there is a db 'sample'
SELECT name, database_id, create_date
FROM sys.databases
WHERE name = 'sample';
GO
