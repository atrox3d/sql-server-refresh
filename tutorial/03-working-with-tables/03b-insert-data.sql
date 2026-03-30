SET NOEXEC OFF;
USE [sample];
GO

/*
    Best Practice: Stop "rows affected" noise
*/
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
DECLARE @msg VARCHAR(MAX) = 'Initial Database Context: ' + DB_NAME();
EXEC dbo.spInfo @msg, 1;
GO
-- SET NOEXEC ON;

/*
************************************************************************************
    create genders if tables is empty
************************************************************************************
*/
IF NOT EXISTS (SELECT * FROM dbo.tblGender)         -- check fo emptiness
    BEGIN
        INSERT INTO dbo.tblGender (ID, Gender) 
        VALUES 
            (1, 'Male'), 
            (2, 'Female'), 
            (3, 'Unknown');
        EXEC dbo.spInfo 'INFO | Data inserted into dbo.tblGender.';
    END
ELSE
    BEGIN
        EXEC dbo.spInfo 'Data already inserted into dbo.tblGender.';
    END
GO

/*
************************************************************************************
    Using the 3-part name (Database.Schema.Table)
    'dbo' is the default schema (Database Owner)
    Schemas act like namespaces (e.g. Sales.Table vs HR.Table)
************************************************************************************
*/
SELECT * FROM sample.dbo.tblGender;
GO

/*
************************************************************************************
    testing fk
************************************************************************************
*/
DELETE FROM sample.dbo.tblPerson;
GO

/*
************************************************************************************
    missing values (nulls) are allowed, no fk violation
************************************************************************************
*/
INSERT INTO sample.dbo.tblPerson
(ID, Name, Email)                       -- need to specify columns due to missing gender value
VALUES (1, 'john', 'j@j.com');          -- no gender
SELECT *  FROM sample.dbo.tblPerson;
GO

/*
************************************************************************************
    illegal gender values are not allowed, fk violation
************************************************************************************
*/
BEGIN TRY
    INSERT INTO sample.dbo.tblPerson
    -- (ID, Name, Email)
    VALUES (2, 'mary', 'm@m.com', 99);      -- illegal gender
END TRY
BEGIN CATCH
    /*
        The INSERT statement conflicted with the FOREIGN KEY constraint "FK_tblPerson_tblGender". 
        The conflict occurred in database "sample", table "dbo.tblGender", column 'ID'.
    */
    EXEC dbo.spError 'An error occurred. Execution jumped to the CATCH block.'
END CATCH
GO
-- SET NOEXEC ON;

INSERT INTO sample.dbo.tblPerson
VALUES (2, 'mary', 'm@m.com', 2);      -- correct gender
GO


/*
************************************************************************************
    test each genderid value against tblgender.ID
************************************************************************************
*/
SELECT
    *,
    CASE 
        WHEN GenderID IN (SELECT ID FROM sample.dbo.tblGender) THEN 'Valid'
        ELSE 'Invalid'
    END AS GenderStatus
FROM 
    sample.dbo.tblPerson;
EXEC dbo.spFLush;
GO