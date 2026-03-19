use [sample];
GO

CREATE OR ALTER PROCEDURE dbo.sp_create_table_gender
    -- @DropIfExists BIT = 0 -- Default to False (0)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. If 'Force Drop' is requested, kill it first
    -- IF @DropIfExists = 1 AND OBJECT_ID('dbo.tblPerson', 'U') IS NOT NULL
    -- BEGIN
    --     DROP TABLE dbo.tblGender;
    --     PRINT 'WARN | Table dbo.tblPerson dropped per request.';
    -- END

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
    -- @DropIfExists BIT = 0 -- Default to False (0)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. If 'Force Drop' is requested, kill it first
    -- IF @DropIfExists = 1 AND OBJECT_ID('dbo.tblPerson', 'U') IS NOT NULL
    -- BEGIN
    --     DROP TABLE dbo.tblPerson;
    --     PRINT 'WARN | Table dbo.tblPerson dropped per request.';
    -- END

    -- 2. Your existing creation logic
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

