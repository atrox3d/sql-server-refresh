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
    prepare data
************************************************************************************
*/
TRUNCATE TABLE dbo.tblPerson;
GO

/*
************************************************************************************
    create constraint UQ_tblPerson_Email, requires the column email to be unique
************************************************************************************
*/
IF OBJECT_ID('UQ_tblPerson_Email') IS NOT NULL
    BEGIN
        ALTER TABLE dbo.TblPerson
        DROP CONSTRAINT UQ_tblPerson_Email;
        EXEC dbo.spInfo 'dropping Unique Constraint UQ_tblPerson_Email created.', 1;
    END
GO
EXEC dbo.spInfo 're-creating Unique Constraint UQ_tblPerson_Email created.', 1;
ALTER TABLE dbo.TblPerson           -- target table
ADD CONSTRAINT UQ_tblPerson_Email   -- constraint name
UNIQUE (Email);                     -- constraint type and column name
GO


INSERT INTO dbo.tblPerson
(ID, name, email, genderid, age)
VALUES (1, 'first', 'f@f.com', 1, 30)
GO

/*
************************************************************************************
    try to add duplicate
************************************************************************************
*/
BEGIN TRY
    INSERT INTO dbo.tblPerson
    (ID, name, email, genderid, age)
    VALUES (2, 'second', 'f@f.com', 1, 30)
END TRY
BEGIN CATCH
    EXEC dbo.spError 'An error occurred. Execution jumped to the CATCH block.', 1;
    -- Violation of UNIQUE KEY constraint 'UQ_tblPerson_Email'. 
    -- Cannot insert duplicate key in object 'dbo.tblPerson'. The duplicate key value is (f@f.com).
END CATCH
GO

/*
************************************************************************************
    remove unique
************************************************************************************
*/
ALTER TABLE dbo.TblPerson
DROP CONSTRAINT UQ_tblPerson_Email;
GO

/*
************************************************************************************
    add duplicate
************************************************************************************
*/
INSERT INTO dbo.tblPerson
(ID, name, email, genderid, age)
VALUES (2, 'second', 'f@f.com', 1, 30)
GO

SELECT * from dbo.tblPerson;
GO

/*
************************************************************************************
    try to add unique constraint
************************************************************************************
*/
BEGIN TRY
    ALTER TABLE dbo.TblPerson
    ADD CONSTRAINT UQ_tblPerson_Email 
    UNIQUE (Email);
END TRY
BEGIN CATCH
    EXEC dbo.spError 'An error occurred. Execution jumped to the CATCH block.', 1;
    -- The CREATE UNIQUE INDEX statement terminated because a duplicate key was found 
    -- for the object name 'dbo.tblPerson' and the index name 'UQ_tblPerson_Email'. 
    -- The duplicate key value is (f@f.com).
END CATCH
GO

/* constraint is not created because it failed in the previous batch */
SELECT OBJECT_ID('UQ_tblPerson_Email') AS [OBJECT_ID('UQ_tblPerson_Email')]; -- NULL
GO