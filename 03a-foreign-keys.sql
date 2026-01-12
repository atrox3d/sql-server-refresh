USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

DECLARE @FK_NAME VARCHAR(128) = 'dbo.FK_tblPerson_tblGender';

-- print 
PRINT COALESCE(OBJECT_ID(@FK_NAME, 'F'), 0);
PRINT COALESCE(
        CAST(
            OBJECT_ID(@FK_NAME, 'F') AS VARCHAR(20)
        ),
        -- OR
        -- CONVERT(VARCHAR(10), OBJECT_ID(@FK_NAME, 'F'))
        'not found'
    );

-- Check for Foreign Key (Type 'F')
IF OBJECT_ID(@FK_NAME, 'F') IS NULL
    BEGIN
        ALTER TABLE [dbo].[tblPerson]               -- object do modify
        ADD CONSTRAINT [FK_tblPerson_tblGender]     -- name of constraint
        FOREIGN KEY ([GenderId])                    -- foreign key column
        REFERENCES [dbo].[tblGender] ([ID]);        -- external referenced column
        
        PRINT 'INFO | Foreign Key ' + @FK_NAME + ' created.';
    END
ELSE
    BEGIN
        PRINT 'INFO | Foreign Key ' + @FK_NAME + ' already exists.';
    END
GO
