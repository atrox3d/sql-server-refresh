SET NOEXEC OFF; -- re-enable code execution for safety
GO

USE [sample];
GO

/*
    Best Practice: Stop "rows affected" noise
*/
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
DECLARE @Msg NVARCHAR(MAX) = 'INFO | Initial Database Context: ' + DB_NAME();
EXEC dbo.spInfo @Msg;
GO

/*
************************************************************************************
    name of the foreign key to use with OBJEC_ID()
    cannot use GO while @FK_NAME is defined
    after the GO the scope dies and with it the variable
************************************************************************************
*/
DECLARE @FK_NAME VARCHAR(128) = 'dbo.FK_tblPerson_tblGender';
-- check existence of the FK
;WITH fkid
AS
(
    SELECT COALESCE(
                /* 
                    object_id return an integer, 
                    so coalesce must use an integer too !!!
                */
                OBJECT_ID(@FK_NAME, 'F'),               -- if the foreign key does not exist returns null
                0                                       -- if object_id returns null, returns 0
            ) AS FK_ID
)
SELECT 
    FK_ID,
    CASE 
        WHEN FK_ID = 0 THEN 'NOT_FOUND ' + @FK_NAME     -- no || concat operator
        ELSE 'FOUND ' + @FK_NAME                        -- then and else must be of the same type
    END AS 'FOUND FK_ID?'                               -- no dynamic strings for aliases
FROM fkid
;
/*
************************************************************************************
    oneliner
************************************************************************************
*/
SELECT OBJECT_ID(@FK_NAME, 'F') AS 'oneliner';

/*
************************************************************************************
    composite statement
************************************************************************************
*/
DECLARE @FK_ID INT = OBJECT_ID(@FK_NAME, 'F');
SELECT @FK_ID as FK_ID;

SELECT COALESCE(
        CAST(
            OBJECT_ID(@FK_NAME, 'F') AS VARCHAR(20)
        ),
        /*
            or use convert, only mssql
            CONVERT(VARCHAR(10), OBJECT_ID(@FK_NAME, 'F'))
        */
        'not found ' + @FK_NAME
    ) AS 'composite statement'
;

/*
************************************************************************************
    create FK if it doesnt exist
************************************************************************************
*/
IF OBJECT_ID(@FK_NAME, 'F') IS NOT NULL
BEGIN
    SELECT 'INFO | Foreign Key ' + @FK_NAME + ' already exists.' AS MESSAGE
    UNION ALL
    SELECT 'INFO | DROPPING Foreign Key ' + @FK_NAME AS MESSAGE;
    ALTER TABLE [dbo].[tblPerson]
    DROP CONSTRAINT [FK_tblPerson_tblGender];
    SELECT 'INFO | Foreign Key ' + @FK_NAME + ' dropped.' AS MESSAGE;
END
SELECT 'INFO | CREATING Foreign Key ' + @FK_NAME AS MESSAGE;
ALTER TABLE [dbo].[tblPerson]               -- object do modify
ADD CONSTRAINT [FK_tblPerson_tblGender]     -- name of constraint
FOREIGN KEY ([GenderId])                    -- foreign key column
REFERENCES [dbo].[tblGender] ([ID]);        -- external referenced column

DECLARE @Msg NVARCHAR(MAX) = CONCAT('INFO | Foreign Key ', @FK_NAME, ' created.')
EXEC dbo.spInfo @Msg;
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
    EXEC dbo.spError 'ERROR | An error occurred. Execution jumped to the CATCH block.'
    -- UNION ALL
    -- SELECT CAST(ERROR_NUMBER() AS NVARCHAR) + ' - ' + ERROR_MESSAGE() AS MESSAGE
END CATCH
GO
SET NOEXEC ON;  -- stop execution like exit() in python
