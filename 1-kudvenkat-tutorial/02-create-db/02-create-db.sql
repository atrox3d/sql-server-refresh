/*
    SQLCMD Mode: Stop script execution on error
    :ON ERROR EXIT
*/

/*
************************************************************************************
    if sample db does exist we try to kick out other users
    and delete it
************************************************************************************
*/
IF DB_ID('sample') IS NOT NULL      -- check for db existence
BEGIN
    BEGIN TRY
        -- Forcefully disconnect any other users
        ALTER DATABASE sample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE sample;
        PRINT 'INFO | Database sample dropped.';
    END TRY
    BEGIN CATCH
        -- show error if db cannot be deleted
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
        -- Re-throw the error to trigger the exit
        THROW;
    END CATCH
END

/*
************************************************************************************
    create the db
************************************************************************************
*/
CREATE DATABASE sample;
PRINT 'INFO | Database sample created.';
GO

-- make sure its set to multi user
ALTER DATABASE sample SET MULTI_USER;
GO

-- check if there is a db 'sample'
SELECT name, database_id, create_date
FROM sys.databases
WHERE name = 'sample';
GO
