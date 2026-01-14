-- SQLCMD Mode command: Stop execution on any error in any batch.
-- This must be enabled in the client (e.g., SSMS Query -> SQLCMD Mode).
-- :ON ERROR EXIT
-- GO
-- Ensure we start with execution enabled (in case previous run stopped it)
SET NOEXEC OFF;
GO

USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

IF OBJECT_ID('dbo.tblPerson1', 'U') IS NOT NULL
    DROP TABLE dbo.tblPerson1;
GO

IF OBJECT_ID('dbo.tblPerson1') IS NOT NULL
    DROP TABLE dbo.tblPerson1;
GO

CREATE TABLE dbo.tblPerson1 (
    ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL
)
GO


PRINT 'INFO | Lazy Mode: Inserting names by splitting a single string...';
INSERT INTO dbo.tblPerson1 (Name)
SELECT value FROM STRING_SPLIT('mark susan john', ' ');

PRINT 'INFO | Using a CTE (Common Table Expression) - another type of "Virtual Table"...';
-- CTE: Common table expression
WITH MyVirtualTable AS (
    -- This defines a temporary named result set (Virtual Table)
    SELECT value, LEN(value) as NameLength      -- returns (value, NameLength)
    FROM STRING_SPLIT('alice bob charlie', ' ') -- returns a virtual table with the column 'value'
)
-- We can query it just like a real table immediately after defining it
INSERT INTO dbo.tblPerson1 (Name)
SELECT value 
FROM MyVirtualTable 
WHERE NameLength > 3;


SELECT * FROM dbo.tblPerson1;
GO

-- delete first id
DELETE FROM dbo.tblPerson1 WHERE ID = 1;
SELECT * FROM dbo.tblPerson1;
GO

-- add new record, cannot specify id 1
INSERT INTO dbo.tblPerson1
VALUES (1, 'bob');
-- An explicit value for the identity column in table 'dbo.tblPerson1' can 
-- only be specified when a column list is used and IDENTITY_INSERT is ON.
GO

-- add new record, id is not 1
INSERT INTO dbo.tblPerson1
VALUES ('bob')
SELECT * FROM dbo.tblPerson1;
GO

-- force id to 1
SET IDENTITY_INSERT dbo.tblPerson1 ON;      -- temporarily set identity_insert on
INSERT INTO dbo.tblPerson1
(ID, Name)                                  -- need to specify columns or we get error
VALUES (1, 'id1');
SET IDENTITY_INSERT dbo.tblPerson1 OFF;     -- reset identity_insert
SELECT * FROM dbo.tblPerson1;
GO

-- delete all rows
DELETE FROM dbo.tblPerson1;
GO
-- add a new record, id is not 1
INSERT INTO dbo.tblPerson1
VALUES ('bob')
SELECT * FROM dbo.tblPerson1;
GO

--reset the seed
DELETE FROM dbo.tblPerson1;
DBCC CHECKIDENT ('dbo.tblPerson1', RESEED, 0);
GO

-- add a new record, id is 1
INSERT INTO dbo.tblPerson1
VALUES ('bob')
SELECT * FROM dbo.tblPerson1;
GO
