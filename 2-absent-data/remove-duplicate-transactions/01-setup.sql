/*
**************************************************************
    video: https://www.youtube.com/watch?v=zPWSq48Id9Y
    data : https://github.com/Gaelim/youtube/blob/master/sales_raw.csv

**************************************************************
*/
IF DB_ID('absentdata') IS NOT NULL      -- check for db existence
BEGIN
    BEGIN TRY
        USE master;
        -- Forcefully disconnect any other users
        ALTER DATABASE absentdata SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE absentdata;
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
GO

CREATE DATABASE absentdata;
PRINT 'INFO | Database absentdata created.';
GO

USE absentdata;
GO

-- make sure its set to multi user
ALTER DATABASE absentdata SET MULTI_USER;
GO

-- check if there is a db 'absentdata'
SELECT 
    name, 
    database_id, 
    create_date,
    'created' as status
FROM sys.databases
WHERE name = 'absentdata';
GO

use absentdata;
go

-- 1. Create the destination table
-- Adjust the columns and data types based on the specific CSV structure
IF OBJECT_ID('dbo.SalesRaw', 'U') IS NOT NULL
    DROP TABLE dbo.SalesRaw;

CREATE TABLE dbo.SalesRaw (
    customer_id    NVARCHAR(50),
    customer_name  NVARCHAR(255),
    product_id     NVARCHAR(50),
    product_name   NVARCHAR(255),
    quantity       INT,
    unit_price     DECIMAL(18, 2),
    total_amount   DECIMAL(18, 2),
    transaction_dt DATETIME,
    source         NVARCHAR(50),
    store_id       NVARCHAR(50),
    session_id     NVARCHAR(50),
    pos_terminal   NVARCHAR(50)
);
GO

exec sp_help 'SalesRaw';
GO
-- 2. Bulk Insert the data
-- Note: The path must be accessible by the SQL Server Service Account.
BULK INSERT dbo.SalesRaw
FROM '/container_data/absent-data/sales_raw.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,        -- Skip the header row
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    TABLOCK,
    KEEPNULLS            -- Ensures empty CSV fields are imported as NULL
);
GO

-- 3. Verify the import
SELECT
    '/container_data/absent-data/sales_raw.csv' as SOURCE,
    COUNT(*) AS TotalRowsLoaded 
FROM dbo.SalesRaw;
SELECT TOP 10 * FROM dbo.SalesRaw;
