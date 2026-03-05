USE [sample];
GO

/*
    Best Practice: Stop "rows affected" noise
*/
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

/*
    name of the foreign key
    cannot use GO while @FK_NAME is defined
    after the GO the scope dies and with it the variable
*/
DECLARE @FK_NAME VARCHAR(128) = 'dbo.FK_tblPerson_tblGender';

/*
************************************************************************************
    check existence of the FK
************************************************************************************
*/
PRINT COALESCE(
            /* object_id return an integer, so coalesce must use an integer too */
            OBJECT_ID(@FK_NAME, 'F'),   -- if the foreign key does not exist returns null
            0                           -- if object_id returns null, returns 0
    );

/*
    oneliner
*/
SELECT OBJECT_ID(@FK_NAME, 'F');
/*
    composite statement
*/
DECLARE @FK_ID INT = OBJECT_ID(@FK_NAME, 'F');
SELECT @FK_ID as FK_ID;

PRINT COALESCE(
        CAST(
            OBJECT_ID(@FK_NAME, 'F') AS VARCHAR(20)
        ),
        /*
            or use convert, only mssql
            CONVERT(VARCHAR(10), OBJECT_ID(@FK_NAME, 'F'))
        */
        'not found'
    );

/*
************************************************************************************
    create FK if it doesnt exist
************************************************************************************
*/
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

/* 
************************************************************************************
    test fk
    cannot add a missing reference to FK
************************************************************************************
*/
BEGIN TRY
    insert into [dbo].[tblPerson]
    VALUES (1, 'name', 'email', 1);
END TRY
BEGIN CATCH
    PRINT 'ERROR | An error occurred. Execution jumped to the CATCH block.';
    SELECT ERROR_NUMBER(), ERROR_MESSAGE();
END CATCH
GO
