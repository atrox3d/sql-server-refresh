/*
**************************************************************
    video: https://www.youtube.com/watch?v=zPWSq48Id9Y
    data : https://github.com/Gaelim/youtube/blob/master/sales_raw.csv

**************************************************************
*/

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

-- 2. Bulk Insert the data
-- Note: The path must be accessible by the SQL Server Service Account.
BULK INSERT dbo.SalesRaw
FROM '/container_data/sales_raw.csv'
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
SELECT COUNT(*) AS TotalRowsLoaded FROM dbo.SalesRaw;
SELECT TOP 10 * FROM dbo.SalesRaw;
