-- Switch back to master to "unuse" the current database
-- use master;
-- select DB_NAME() as db_name;
-- go

USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

-- EXAMPLE: create table to demonstrate char types
-- CREATE TABLE tblEmployee (
--     ID INT NOT NULL PRIMARY KEY,
--     -- CHAR: Fixed length, non-Unicode. Good for fixed codes.
--     Code CHAR(5), 
--     -- VARCHAR: Variable length, non-Unicode. Good for standard ASCII text.
--     Email VARCHAR(100),
--     -- NVARCHAR: Variable length, Unicode (UTF-16). Good for names/international text.
--     Name NVARCHAR(100)
-- );
-- GO

-- EXAMPLE: Using @@ERROR to check if a command failed
-- Try to switch to a database that does not exist
-- USE [GhostDatabase];

-- -- Check the error variable immediately
-- IF @@ERROR <> 0
-- BEGIN
--     PRINT 'Error: The database could not be found.';
--     -- You could put logic here to handle the failure
-- END;

-- Best Practice: Create reference tables (Gender) BEFORE dependent tables (Person)

-- create table gender
IF OBJECT_ID('dbo.tblGender', 'U') IS NULL
    BEGIN
        CREATE TABLE [dbo].[tblGender] (
            [ID] INT NOT NULL PRIMARY KEY,
            [Gender] NVARCHAR(50) NOT NULL
        );
        PRINT 'INFO | Table dbo.tblGender created.';
    END
ELSE
    BEGIN
        PRINT 'INFO | Table dbo.tblGender already exists.';
    END
GO

-- EXAMPLE: Insert data into tblGender (Only if the table is empty)
-- IF NOT EXISTS (SELECT * FROM dbo.tblGender)
-- BEGIN
--     INSERT INTO dbo.tblGender (ID, Gender) 
--     VALUES (1, 'Male'), (2, 'Female'), (3, 'Unknown');
    
--     PRINT 'INFO | Data inserted into dbo.tblGender.';
-- END
-- GO


-- create table person
IF OBJECT_ID('dbo.tblPerson', 'U') IS NULL
    BEGIN
        CREATE TABLE [dbo].[tblPerson] (
            [ID] INT NOT NULL PRIMARY KEY,
            [Name] NVARCHAR(50) NOT NULL,
            [Email] NVARCHAR(50) NOT NULL,
            [GenderId] INT
        );
        PRINT 'INFO | Table dbo.tblPerson created.';
    END
ELSE
    BEGIN
        PRINT 'INFO | Table dbo.tblPerson already exists.';
    END
GO

-- EXAMPLE: Insert data into tblPerson (Only if the table is empty)
-- IF NOT EXISTS (SELECT * FROM dbo.tblPerson)
-- BEGIN
--     INSERT INTO dbo.tblPerson (ID, Name, Email, GenderId) 
--     VALUES (1, 'Tom', 'tom@test.com', 1),
--            (2, 'Sara', 'sara@test.com', 2),
--            (3, 'Bob', 'bob@test.com', 1);
           
--     PRINT 'INFO | Data inserted into dbo.tblPerson.';
-- END
-- GO
