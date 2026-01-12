USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

IF NOT EXISTS (SELECT * FROM dbo.tblGender)
    BEGIN
        INSERT INTO dbo.tblGender (ID, Gender) 
        VALUES (1, 'Male'), (2, 'Female'), (3, 'Unknown');
        
        PRINT 'INFO | Data inserted into dbo.tblGender.';
    END
ELSE
    BEGIN
        PRINT 'INFO | Data already inserted into dbo.tblGender.';
    END
GO

-- Using the 3-part name (Database.Schema.Table)
-- 'dbo' is the default schema (Database Owner)
-- Schemas act like namespaces (e.g. Sales.Table vs HR.Table)
SELECT * FROM sample.dbo.tblGender;
GO

-- testing fk
DELETE FROM sample.dbo.tblPerson;
GO

INSERT INTO sample.dbo.tblPerson
(ID, Name, Email)                       -- need to specify columns due to missing gender value
VALUES (1, 'john', 'j@j.com');          -- no gender
GO

INSERT INTO sample.dbo.tblPerson
-- (ID, Name, Email)
VALUES (2, 'mary', 'm@m.com', 99);      -- illegal gender
-- The INSERT statement conflicted with the FOREIGN KEY constraint "FK_tblPerson_tblGender". 
-- The conflict occurred in database "sample", table "dbo.tblGender", column 'ID'.
GO

INSERT INTO sample.dbo.tblPerson
VALUES (2, 'mary', 'm@m.com', 2);      -- correct gender
GO

SELECT * FROM sample.dbo.tblPerson;
GO
