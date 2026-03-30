USE [sample];
GO

SET NOCOUNT ON;

-- 1. Create a new Schema (e.g., 'HR')
-- Note: We use EXEC because CREATE SCHEMA must be the first statement in a batch
IF SCHEMA_ID('HR') IS NULL
BEGIN
    EXEC('CREATE SCHEMA [HR]');
    PRINT 'INFO | Schema [HR] created.';
END
GO

-- 2. Create a table directly inside the new Schema
IF OBJECT_ID('HR.tblEmployee', 'U') IS NULL
BEGIN
    CREATE TABLE [HR].[tblEmployee] (
        ID INT PRIMARY KEY,
        Name NVARCHAR(50)
    );
    PRINT 'INFO | Table [HR].[tblEmployee] created.';
END
GO

-- 3. Move an existing table to the new Schema
-- Let's move 'dbo.tblPerson' (from previous scripts) into the 'HR' schema
IF OBJECT_ID('dbo.tblPerson', 'U') IS NOT NULL
BEGIN
    -- Syntax: ALTER SCHEMA [Target] TRANSFER [Source].[Object]
    ALTER SCHEMA [HR] TRANSFER [dbo].[tblPerson];
    PRINT 'INFO | Moved [dbo].[tblPerson] to [HR].[tblPerson].';
END
GO

-- Verify the move
SELECT SchemaName = s.name, TableName = t.name
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name = 'tblPerson';
GO

-- 4. Clean up (How to Delete)
-- You CANNOT drop a schema if it contains objects.

-- A. Move tblPerson back to dbo
IF OBJECT_ID('HR.tblPerson', 'U') IS NOT NULL
BEGIN
    ALTER SCHEMA [dbo] TRANSFER [HR].[tblPerson];
    PRINT 'INFO | Moved [HR].[tblPerson] back to [dbo].';
END

-- B. Drop the table we created inside HR
IF OBJECT_ID('HR.tblEmployee', 'U') IS NOT NULL
    DROP TABLE [HR].[tblEmployee];

-- C. Now that HR is empty, we can drop the schema
IF SCHEMA_ID('HR') IS NOT NULL
BEGIN
    DROP SCHEMA [HR];
    PRINT 'INFO | Schema [HR] dropped.';
END
GO