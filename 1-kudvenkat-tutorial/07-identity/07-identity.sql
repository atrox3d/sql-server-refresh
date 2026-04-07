/*
************************************************************************************
    SQLCMD Mode command: Stop execution on any error in any batch.
    This must be enabled in the client (e.g., SSMS Query -> SQLCMD Mode).
    :ON ERROR EXIT
    GO
    Ensure we start with execution enabled (in case previous run stopped it)
************************************************************************************
*/
SET NOEXEC OFF;
GO

USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
DECLARE @Msg NVARCHAR(MAX) = 'Initial Database Context: ' + DB_NAME();
EXEC dbo.spInfo @Msg, 1;
GO

/*
************************************************************************************
    CREATE EXAMPLE TABLE tblPerson1
************************************************************************************
*/
IF OBJECT_ID('dbo.tblPerson1', 'U') IS NOT NULL
    DROP TABLE dbo.tblPerson1;
CREATE TABLE dbo.tblPerson1 (
    ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL
)
GO

/*
************************************************************************************
    INSERT mark, susan, john
************************************************************************************
*/
EXEC dbo.spInfo 'Lazy Mode: Inserting names by splitting a single string...', 1;
INSERT INTO dbo.tblPerson1 (Name)                           -- insert names into tblPerson1
SELECT value FROM STRING_SPLIT('mark susan john', ' ');     -- STRING_SPLIT returns a table, with the column value and a substring in each row
GO
SELECT * FROM dbo.tblPerson1;
GO

/*
************************************************************************************
    INSERT alice, charlie
************************************************************************************
*/
EXEC dbo.spInfo 'Using a CTE (Common Table Expression) - another type of "Virtual Table"...', 1;
-- CTE: Common table expression
;WITH MyVirtualTable AS (
    -- This defines a temporary named result set (Virtual Table)
    SELECT value, LEN(value) as NameLength                  -- returns (value, NameLength) where nameLEngth is the length of the name
    FROM STRING_SPLIT('alice bob charlie', ' ')             -- returns a virtual table with the column 'value'
)
-- We can query it just like a real table immediately after defining it
INSERT INTO dbo.tblPerson1 (Name)                           -- insert names into tblPerson1
SELECT value                                                -- get names from CTE
FROM MyVirtualTable 
WHERE NameLength > 3;                                       -- filters out bob                           
GO

SELECT * FROM dbo.tblPerson1;
GO

/*
************************************************************************************
    try to insert a new record specifying the id
    this is not possible normally, unless two conditions are met:
    - column name is specified
    - IDENTITY_INSERT is ON
************************************************************************************
*/
DELETE FROM dbo.tblPerson1 WHERE ID = 1;
SELECT * FROM dbo.tblPerson1;
GO

/*
    to make this wotk it has to be outside the batch and the try block
    or it will fail at compile time
*/
EXEC dbo.spInfo 'Trying to insert a new record specifying the id...', 1;
GO

BEGIN TRY
    -- add new record, cannot specify id 1
    INSERT INTO dbo.tblPerson1
    VALUES (1, 'bob');
END TRY
BEGIN CATCH
    /*
    ************************************************************************************
    *
    * this is never executed, it fails at compile time
    *
    ************************************************************************************
    */
    EXEC dbo.spError 'An error occurred. Execution jumped to the CATCH block.', 1;
    -- An explicit value for the identity column in table 'dbo.tblPerson1' can 
    -- only be specified when a column list is used and IDENTITY_INSERT is ON.
END CATCH
GO

/*
************************************************************************************
    add new record, id is not 1
    we dont get an error but the id is automatic
************************************************************************************
*/
INSERT INTO dbo.tblPerson1
VALUES ('bob')
SELECT * FROM dbo.tblPerson1;
GO

/*
************************************************************************************
    force id to 1:
    - column names are used
    - IDENTITY_INSERT is ON
************************************************************************************
*/
SET IDENTITY_INSERT dbo.tblPerson1 ON;      -- temporarily set identity_insert on
INSERT INTO dbo.tblPerson1
(ID, Name)                                  -- need to specify columns or we get error
VALUES (1, 'id1');
SET IDENTITY_INSERT dbo.tblPerson1 OFF;     -- reset identity_insert
SELECT * FROM dbo.tblPerson1;
GO


/*
************************************************************************************
    demonstrate id seed reset to 1
    - delete all records
    - when inserting new record id value continue from the last
    - reset the seed
    - when inserting new record id value start from 1
************************************************************************************
*/
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
