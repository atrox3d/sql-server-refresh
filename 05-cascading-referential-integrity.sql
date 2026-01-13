USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

--*********************************
-- delete original FK constraint before restoring data
--*********************************
IF OBJECT_ID('sample.dbo.FK_tblPerson_tblGender', 'F') IS NOT NULL
    BEGIN
        -- 1. Drop the existing strict constraint
        ALTER TABLE sample.dbo.tblPerson DROP CONSTRAINT FK_tblPerson_tblGender;
        PRINT 'INFO | Foreign Key FK_tblPerson_tblGender dropped.';
    END
GO

--*********************************
--- prepare data
--*********************************
PRINT 'INFO | Executing sp_ResetDemoData...'
EXEC dbo.sp_ResetDemoData;
GO

--*********************************
-- 2. Re-create FK without the Cascade rule
--*********************************
ALTER TABLE sample.dbo.tblPerson
ADD CONSTRAINT FK_tblPerson_tblGender
FOREIGN KEY (GenderId) REFERENCES sample.dbo.tblGender(ID)
PRINT 'INFO | Foreign Key FK_tblPerson_tblGender recreated without cascading.';
GO

SELECT * FROM sample.dbo.tblGender;
GO
SELECT * FROM sample.dbo.tblPerson
WHERE ID = 2;

--*********************************
--- start lesson
--*********************************
-- try to delete gender id 2 violating FK, because we would obtain orphan rows with genderid 2
PRINT 'INFO | Trying to delete gender id 2 violating FK...'
DELETE FROM tblGender WHERE ID = 2;
-- The DELETE statement conflicted with the REFERENCE constraint "FK_tblPerson_tblGender". 
-- The conflict occurred in database "sample", table "dbo.tblPerson", column 'GenderId'.

-- cascading referential integrity:
--  - no action (default): 
--      raises error and rolls back and DELETE or UPDATE is rolled back
--  - cascade:
--      all the rows containing that foreign key will be deleted or updated
--  - set null:
--      all the rows containing that foreign key will be set to NULL
--  - set default:
--      all the rows containing that foreign key will be set to a default value (constraint)

--*********************************
-- recreate FK with on delete set null
--*********************************
IF OBJECT_ID('sample.dbo.FK_tblPerson_tblGender', 'F') IS NOT NULL
    BEGIN
        -- 1. Drop the existing strict constraint
        ALTER TABLE sample.dbo.tblPerson DROP CONSTRAINT FK_tblPerson_tblGender;
        PRINT 'INFO | Foreign Key FK_tblPerson_tblGender dropped.';
    END
-- 2. Re-create it with the Cascade rule
ALTER TABLE sample.dbo.tblPerson
ADD CONSTRAINT FK_tblPerson_tblGender
FOREIGN KEY (GenderId) REFERENCES sample.dbo.tblGender(ID)
ON DELETE SET DEFAULT;
PRINT 'INFO | Foreign Key FK_tblPerson_tblGender recreated with cascading.';
GO

-- retry to delete gender id 2 violating FK, because we would obtain orphan rows with genderid 2
-- this time the on delete clause will set genderid to DEFAULT
DELETE FROM tblGender WHERE ID = 2;
PRINT 'INFO | Data deleted from dbo.tblGender, corresponding records in dbo.tblPerson set to default';
GO

SELECT * FROM sample.dbo.tblGender;
GO
SELECT * FROM sample.dbo.tblPerson
WHERE ID = 2;
