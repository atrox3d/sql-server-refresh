USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

--*********************************
-- restore original FK constraint
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
DELETE FROM sample.dbo.tblGender;
PRINT 'INFO | Data deleted from dbo.tblGender.';
GO

INSERT INTO dbo.tblGender (ID, Gender) 
VALUES (1, 'Male'), (2, 'Female'), (3, 'Unknown');
PRINT 'INFO | Data inserted into dbo.tblGender.';
GO


-- 2. Re-create it with the Cascade rule
ALTER TABLE sample.dbo.tblPerson
ADD CONSTRAINT FK_tblPerson_tblGender
FOREIGN KEY (GenderId) REFERENCES sample.dbo.tblGender(ID)
PRINT 'INFO | Foreign Key FK_tblPerson_tblGender recreated without cascading.';
GO

DELETE FROM sample.dbo.tblPerson;
PRINT 'INFO | Data deleted from dbo.tblPerson.';
GO

INSERT INTO sample.dbo.tblPerson
VALUES 
    (1, 'john',   'j@j.com',      1),
    (2, 'simon',  's@s.com',      2),
    (3, 'rich',   'r@r.com',      1),
    (4, 'sara',   's@r.com',      3),
    (5, 'Johnny', 'j@r.com',      3);
PRINT 'INFO | Data inserted into dbo.tblPerson.';
GO

SELECT * FROM sample.dbo.tblPerson
WHERE ID = 2;
SELECT * FROM sample.dbo.tblGender;
GO


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
-- add on delete set null
--*********************************
IF OBJECT_ID('sample.dbo.FK_tblPerson_tblGender', 'F') IS NOT NULL
    BEGIN
        -- 1. Drop the existing strict constraint
        ALTER TABLE sample.dbo.tblPerson DROP CONSTRAINT FK_tblPerson_tblGender;
        PRINT 'INFO | Foreign Key FK_tblPerson_tblGender dropped.';
    END
GO

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

SELECT * FROM sample.dbo.tblPerson
WHERE ID = 2;
SELECT * FROM sample.dbo.tblGender;
GO
