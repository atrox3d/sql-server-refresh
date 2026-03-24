USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
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
        PRINT 'INFO | sp_delete_tblPerson_FK: Foreign Key FK_tblPerson_tblGender dropped.';
    END
    ELSE
        PRINT 'INFO | sp_delete_tblPerson_FK: Foreign Key FK_tblPerson_tblGender not found.';
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ResetDemoData
AS
BEGIN
    PRINT 'INFO | sp_ResetDemoData: Resetting data...';

    -- 1. Clean up (Order matters due to Foreign Keys!)
    -- We must delete Child (Person) before Parent (Gender)
    PRINT 'INFO | sp_ResetDemoData: deleting tblPerson...';
    DELETE FROM sample.dbo.tblPerson;
    PRINT 'INFO | sp_ResetDemoData: deleting tblGender...';
    DELETE FROM sample.dbo.tblGender;

    -- 2. Reseed Parent Table
    PRINT 'INFO | sp_ResetDemoData: inserting into tblGender...';
    INSERT INTO sample.dbo.tblGender (ID, Gender)
    VALUES (1, 'Male'), (2, 'Female'), (3, 'Unknown');

    -- 3. Reseed Child Table
    PRINT 'INFO | sp_ResetDemoData: inserting into tblPerson...';
    INSERT INTO sample.dbo.tblPerson (ID, Name, Email, GenderId)
    VALUES 
        (1, 'john',   'j@j.com',      1),
        (2, 'simon',  's@s.com',      2),
        (3, 'rich',   'r@r.com',      1),
        (4, 'sara',   's@r.com',      1),
        (5, 'Johnny', 'j@r.com',      2);

    PRINT 'INFO | sp_ResetDemoData: Data reset complete.';
END
GO
/*
************************************************************************************

    1. prepare data

************************************************************************************
*/
PRINT 'INFO | Executing sp_delete_tblPerson_FK...'
EXEC dbo.sp_delete_tblPerson_FK;
PRINT 'INFO | Executing sp_ResetDemoData...'
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
PRINT 'INFO | Foreign Key FK_tblPerson_tblGender recreated without cascading.';
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
PRINT 'INFO | Trying to delete gender id 2 violating FK...'
DELETE FROM tblGender WHERE ID = 2;
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
        PRINT 'INFO | Foreign Key FK_tblPerson_tblGender dropped.';
    END
-- 2. Re-create it with the set default rule
ALTER TABLE sample.dbo.tblPerson            -- target table
ADD CONSTRAINT FK_tblPerson_tblGender       -- constraint name
FOREIGN KEY (GenderId)                      -- foreign key column
REFERENCES sample.dbo.tblGender(ID)         -- external referenced column
ON DELETE SET DEFAULT;                      -- on delete action: set default: 
                                            -- default constraint: DF_tblPerson_GenderId -> 3
PRINT 'INFO | Foreign Key FK_tblPerson_tblGender recreated with cascading.';
GO

/*
    retry to delete gender id 2 violating FK, 
    because we would obtain orphan rows with genderid 2
    this time the on delete clause will set genderid to DEFAULT
    default constraint: DF_tblPerson_GenderId -> 3
*/
DELETE FROM tblGender WHERE ID = 2;
PRINT 'INFO | Data deleted from dbo.tblGender, corresponding records in dbo.tblPerson set to default';
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
