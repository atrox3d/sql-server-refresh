-- create db if it not exists already
IF DB_ID('sample') IS NULL
	CREATE DATABASE sample;
GO

-- check if there is a db 'sample'
SELECT  name
        , database_id
        , create_date
FROM sys.databases
WHERE name = 'sample';
GO

-- rename sample to sample2 with commands
ALTER DATABASE sample MODIFY NAME = sample2;
GO

-- rename back sample using stored procedure
EXECUTE sp_renamedb 'sample2', 'sample';
-- rename back sample using ALTER DATABASE (sp_renamedb is deprecated)
ALTER DATABASE sample2 MODIFY NAME = sample;
GO

IF DB_ID('sample') IS NOT NULL
BEGIN
    -- Forcefully disconnect any other users
    ALTER DATABASE sample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE sample;
END;
GO

/*
    --- REFERENCE: RESTORE DATABASE FROM .BAK ---
    1. Check logical names inside the backup:
       RESTORE FILELISTONLY FROM DISK = '/path/to/backup.bak';

    2. Restore using those logical names (handling path differences):
       RESTORE DATABASE [sample] 
       FROM DISK = '/path/to/backup.bak'
       WITH MOVE 'sample_Data' TO '/var/opt/mssql/data/sample.mdf',
            MOVE 'sample_Log'  TO '/var/opt/mssql/data/sample.ldf',
            REPLACE; -- Overwrites if DB already exists
*/
