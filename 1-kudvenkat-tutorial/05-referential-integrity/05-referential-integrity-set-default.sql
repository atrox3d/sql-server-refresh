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

    STORED PROCEDURES

************************************************************************************
*/

CREATE OR ALTER PROCEDURE dbo.sp_delete_tblPerson_FK
AS
BEGIN
    -- delete original FK constraint before restoring data
    IF OBJECT_ID('sample.dbo.FK_tblPerson_tblGender', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE sample.dbo.tblPerson DROP CONSTRAINT FK_tblPerson_tblGender;
        EXEC dbo.spInfo 'sp_delete_tblPerson_FK: Foreign Key FK_tblPerson_tblGender dropped.', 1;
    END
    ELSE
        EXEC dbo.spInfo 'sp_delete_tblPerson_FK: Foreign Key FK_tblPerson_tblGender not found.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ResetDemoData
AS
BEGIN
    EXEC dbo.spInfo 'sp_ResetDemoData: Resetting data...', 1;

    -- 1. Clean up (Order matters due to Foreign Keys!)
    -- We must delete Child (Person) before Parent (Gender)
    EXEC dbo.spInfo 'sp_ResetDemoData: deleting tblPerson...', 1;
    DELETE FROM sample.dbo.tblPerson;
    EXEC dbo.spInfo 'sp_ResetDemoData: deleting tblGender...', 1;
    DELETE FROM sample.dbo.tblGender;

    -- 2. Reseed Parent Table
    EXEC dbo.spInfo 'sp_ResetDemoData: inserting into tblGender...', 1;
    INSERT INTO sample.dbo.tblGender (ID, Gender)
    VALUES (1, 'Male'), (2, 'Female'), (3, 'Unknown');

    -- 3. Reseed Child Table
    EXEC dbo.spInfo 'sp_ResetDemoData: inserting into tblPerson...', 1;
    INSERT INTO sample.dbo.tblPerson (ID, Name, Email, GenderId)
    VALUES 
        (1, 'john',   'j@j.com',      1),
        (2, 'simon',  's@s.com',      2),
        (3, 'rich',   'r@r.com',      1),
        (4, 'sara',   's@r.com',      1),
        (5, 'Johnny', 'j@r.com',      2);

    EXEC dbo.spInfo 'sp_ResetDemoData: Data reset complete.', 1;
END
GO
/*
************************************************************************************

    1. prepare data

************************************************************************************
*/
EXEC dbo.spInfo 'Executing sp_delete_tblPerson_FK...', 1;
EXEC dbo.sp_delete_tblPerson_FK;
EXEC dbo.spInfo 'Executing sp_ResetDemoData...', 1;
EXEC dbo.sp_ResetDemoData;
GO
/*
************************************************************************************

    2. Re-create FK without the Cascade rule

************************************************************************************
*/
ALTER TABLE sample.dbo.tblPerson
ADD CONSTRAINT FK_tblPerson_tblGender
FOREIGN KEY (GenderId) REFERENCES sample.dbo.tblGender(ID)
EXEC dbo.spInfo 'Foreign Key FK_tblPerson_tblGender recreated without cascading.', 1;
GO

SELECT 
    * 
FROM sample.dbo.tblPerson as p
LEFT JOIN sample.dbo.tblGender as g
ON p.GenderId = g.ID;
GO
/*
************************************************************************************


    start lesson


************************************************************************************
*/
-- try to delete gender id 2 violating FK, because we would obtain orphan rows with genderid 2
BEGIN TRY
    EXEC dbo.spInfo 'Trying to delete gender id 2 violating FK...';
    DELETE FROM tblGender WHERE ID = 2;
END TRY
BEGIN CATCH
    EXEC dbo.spError 'An error occurred. Execution jumped to the CATCH block.', 1;
END CATCH
GO
/*
The DELETE statement conflicted with the REFERENCE constraint "FK_tblPerson_tblGender". 
The conflict occurred in database "sample", table "dbo.tblPerson", column 'GenderId'.

cascading referential integrity:
    - no action (default): 
        raises error and rolls back and DELETE or UPDATE is rolled back
    - cascade:
        all the rows containing that foreign key will be deleted or updated
    - set null:
        all the rows containing that foreign key will be set to NULL
    - set default:
        all the rows containing that foreign key will be set to a default value (constraint)
*/

/*
************************************************************************************
    recreate FK with on delete set default
************************************************************************************
*/
IF OBJECT_ID('sample.dbo.FK_tblPerson_tblGender', 'F') IS NOT NULL
    BEGIN
        -- 1. Drop the existing strict constraint
        ALTER TABLE sample.dbo.tblPerson DROP CONSTRAINT FK_tblPerson_tblGender;
        EXEC dbo.spInfo 'Foreign Key FK_tblPerson_tblGender dropped.', 1;
    END
-- 2. Re-create it with the set default rule
ALTER TABLE sample.dbo.tblPerson            -- target table
ADD CONSTRAINT FK_tblPerson_tblGender       -- constraint name
FOREIGN KEY (GenderId)                      -- foreign key column
REFERENCES sample.dbo.tblGender(ID)         -- external referenced column
ON DELETE SET DEFAULT;                      -- on delete action: set default: 
                                            -- default constraint: DF_tblPerson_GenderId -> 3
EXEC dbo.spInfo 'Foreign Key FK_tblPerson_tblGender recreated with cascading.', 1;
GO

/*
    retry to delete gender id 2 violating FK, 
    because we would obtain orphan rows with genderid 2
    this time the on delete clause will set genderid to DEFAULT
    default constraint: DF_tblPerson_GenderId -> 3
*/
DELETE FROM tblGender WHERE ID = 2;
EXEC dbo.spInfo 'Data deleted from dbo.tblGender, corresponding records in dbo.tblPerson set to default', 1;
GO


SELECT 
    *,
    CASE
        WHEN Gender = 'Unknown' THEN 'reset to default'
        ELSE ''
    END AS NOTE
FROM sample.dbo.tblPerson as p
LEFT JOIN sample.dbo.tblGender as g
ON p.GenderId = g.ID;
GO
