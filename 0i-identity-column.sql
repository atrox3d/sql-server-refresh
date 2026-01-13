-- Ensure we start with execution enabled (in case a previous script failed)
SET NOEXEC OFF;
GO

USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;
GO

PRINT 'INFO | Preparing a sample table for the demo...';

IF OBJECT_ID('dbo.LegacyTable', 'U') IS NOT NULL
    DROP TABLE dbo.LegacyTable;
GO

CREATE TABLE dbo.LegacyTable (
    LegacyID INT NOT NULL,
    ProductData VARCHAR(50)
);

INSERT INTO dbo.LegacyTable (LegacyID, ProductData) VALUES (101, 'Widget');
INSERT INTO dbo.LegacyTable (LegacyID, ProductData) VALUES (102, 'Gadget');
INSERT INTO dbo.LegacyTable (LegacyID, ProductData) VALUES (103, 'Doohickey');

PRINT 'INFO | Initial table state (LegacyID is just a regular INT):';
SELECT * FROM dbo.LegacyTable;
GO

PRINT 'INFO | Attempting to add IDENTITY to the existing column (this will fail)...';
BEGIN TRY
    -- This syntax is incorrect and will cause a syntax error.
    -- There is no direct way to add IDENTITY to an existing column.
    ALTER TABLE dbo.LegacyTable ALTER COLUMN LegacyID INT IDENTITY(1,1);
END TRY
BEGIN CATCH
    PRINT 'ERROR | As expected, the ALTER COLUMN statement failed.';
    PRINT 'ERROR | Message: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT 'INFO | --- The Correct Workaround (Preserving IDs) ---';
PRINT 'INFO | To preserve existing IDs, we must use the "Create, Copy, Swap" method.';

-- Step 1: Create a new temporary table with the desired structure (including IDENTITY)
PRINT 'INFO | Step 1: Creating a new table with the IDENTITY column...';
CREATE TABLE dbo.LegacyTable_New (
    LegacyID INT IDENTITY(1,1) NOT NULL,
    ProductData VARCHAR(50)
);
GO

-- Step 2: Enable IDENTITY_INSERT to allow copying existing ID values
PRINT 'INFO | Step 2: Enabling IDENTITY_INSERT on the new table...';
SET IDENTITY_INSERT dbo.LegacyTable_New ON;

-- Step 3: Copy data from the old table to the new table
PRINT 'INFO | Step 3: Copying data...';
INSERT INTO dbo.LegacyTable_New (LegacyID, ProductData)
SELECT LegacyID, ProductData FROM dbo.LegacyTable;

-- Step 4: Disable IDENTITY_INSERT
PRINT 'INFO | Step 4: Disabling IDENTITY_INSERT...';
SET IDENTITY_INSERT dbo.LegacyTable_New OFF;
GO

-- Step 5: Swap the tables
PRINT 'INFO | Step 5: Dropping old table and renaming new one...';
DROP TABLE dbo.LegacyTable;
EXEC sp_rename 'dbo.LegacyTable_New', 'LegacyTable';
-- Add back the Primary Key
ALTER TABLE dbo.LegacyTable ADD CONSTRAINT PK_LegacyTable PRIMARY KEY (LegacyID);
GO

PRINT 'INFO | Final table structure and data:';
SELECT * FROM dbo.LegacyTable;
GO