IF DB_ID('mavenanalytics') IS NULL      -- check for db existence
BEGIN
    BEGIN TRY
        CREATE DATABASE mavenanalytics;
        PRINT 'INFO | Database mavenanalytics created.';
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
GO

use mavenanalytics;
PRINT 'INFO | Database mavenanalytics selected.';
