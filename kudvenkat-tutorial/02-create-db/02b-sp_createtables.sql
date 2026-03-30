use [sample];
GO

CREATE OR ALTER PROCEDURE dbo.spCreate_table_gender
    @DropIfExists BIT = 0 -- Default to False (0)
AS
BEGIN
    DECLARE @FK_NAME VARCHAR(128) = 'dbo.FK_tblPerson_tblGender';
    SET NOCOUNT ON;

    -- 1. If 'Force Drop' is requested, kill it first
    IF @DropIfExists = 1 AND OBJECT_ID('dbo.tblGender', 'U') IS NOT NULL
    BEGIN
        IF OBJECT_ID(@FK_NAME, 'F') IS NOT NULL
        BEGIN
            ALTER TABLE [dbo].[tblPerson] 
            DROP CONSTRAINT [FK_tblPerson_tblGender];
            -- PRINT 'INFO | Foreign Key ' + @FK_NAME + ' dropped.';
            DECLARE @MSg NVARCHAR(MAX) = CONCAT('INFO | Foreign Key ', @FK_NAME, ' dropped.')
            EXEC dbo.spInfo @Msg;
        END


        DROP TABLE dbo.tblGender;
        PRINT 'WARN | Table dbo.tblPerson dropped per request.';
    END

    IF OBJECT_ID('dbo.tblGender', 'U') IS NULL
        BEGIN
            CREATE TABLE [dbo].[tblGender] (
                [ID] INT NOT NULL PRIMARY KEY,
                [Gender] NVARCHAR(50) NOT NULL
            );
            EXEC dbo.spInfo 'INFO | Table dbo.tblGender created.';
        END
    ELSE
        BEGIN
            EXEC dbo.spInfo  'INFO | Table dbo.tblGender already exists.';
        END
END;
GO

CREATE OR ALTER PROCEDURE dbo.spCreate_table_person
    @DropIfExists BIT = 0 -- Default to False (0)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. If 'Force Drop' is requested, kill it first
    IF @DropIfExists = 1 AND OBJECT_ID('dbo.tblPerson', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.tblPerson;
        EXEC dbo.spInfo 'WARN | Table dbo.tblPerson dropped per request.';
    END

    -- 2. Your existing creation logic
    IF OBJECT_ID('dbo.tblPerson', 'U') IS NULL
    BEGIN
        CREATE TABLE [dbo].[tblPerson] (
            [ID] INT NOT NULL PRIMARY KEY,
            [Name] NVARCHAR(50) NOT NULL,
            [Email] NVARCHAR(50) NOT NULL,
            [GenderId] INT
        );
        EXEC dbo.spInfo  'INFO | Table dbo.tblPerson created.';
    END
    ELSE
    BEGIN
        EXEC dbo.spInfo 'INFO | Table dbo.tblPerson already exists.';
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.spCreate_tutorial_tables
AS
BEGIN
    EXEC dbo.spCreate_table_gender;
    EXEC dbo.spCreate_table_person;
END;
GO

