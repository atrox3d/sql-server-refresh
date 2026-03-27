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

--****************************************************************
-- create constraint
--****************************************************************
IF OBJECT_ID('UQ_tblPerson_Email') IS NOT NULL
    BEGIN
        ALTER TABLE dbo.TblPerson
        DROP CONSTRAINT UQ_tblPerson_Email;
        PRINT 'INFO | dropping Unique Constraint UQ_tblPerson_Email created.';
    END
GO

ALTER TABLE dbo.TblPerson
ADD CONSTRAINT UQ_tblPerson_Email 
UNIQUE (Email);
GO

--****************************************************************
-- prepare data
--****************************************************************
DELETE FROM dbo.tblPerson;
GO

INSERT INTO dbo.tblPerson
(ID, name, email, genderid, age)
VALUES (1, 'first', 'f@f.com', 1, 30)
GO

--****************************************************************
-- try to add duplicate
--****************************************************************
INSERT INTO dbo.tblPerson
(ID, name, email, genderid, age)
VALUES (2, 'second', 'f@f.com', 1, 30)
-- Violation of UNIQUE KEY constraint 'UQ_tblPerson_Email'. 
-- Cannot insert duplicate key in object 'dbo.tblPerson'. The duplicate key value is (f@f.com).
GO

--****************************************************************
-- remove unique
--****************************************************************
ALTER TABLE dbo.TblPerson
DROP CONSTRAINT UQ_tblPerson_Email;
GO

--****************************************************************
-- add duplicate
--****************************************************************
INSERT INTO dbo.tblPerson
(ID, name, email, genderid, age)
VALUES (2, 'second', 'f@f.com', 1, 30)
GO

SELECT * from dbo.tblPerson;
GO

--****************************************************************
-- try to add unique constraint
--****************************************************************
ALTER TABLE dbo.TblPerson
ADD CONSTRAINT UQ_tblPerson_Email 
UNIQUE (Email);
-- The CREATE UNIQUE INDEX statement terminated because a duplicate key was found 
-- for the object name 'dbo.tblPerson' and the index name 'UQ_tblPerson_Email'. 
-- The duplicate key value is (f@f.com).
GO

SELECT OBJECT_ID('UQ_tblPerson_Email'); -- NULL
GO