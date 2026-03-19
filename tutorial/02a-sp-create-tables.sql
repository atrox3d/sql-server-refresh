use [sample];
GO

CREATE OR ALTER PROCEDURE dbo.sp_create_table_gender
AS
BEGIN
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
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_create_table_person
AS
BEGIN
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
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_create_tutorial_tables
AS
BEGIN
    EXEC dbo.sp_create_table_gender;
    EXEC dbo.sp_create_table_person;
END;
GO

