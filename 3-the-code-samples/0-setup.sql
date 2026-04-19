IF DB_ID('thecodesamples') IS NULL      -- check for db existence
BEGIN
    BEGIN TRY
        CREATE DATABASE thecodesamples;
        PRINT 'INFO | Database thecodesamples created.';
        use thecodesamples;
        PRINT 'INFO | Database thecodesamples selected.';
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

