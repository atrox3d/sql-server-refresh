USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

--*********************************
--- prepare data
--*********************************
PRINT 'INFO | Executing sp_ResetDemoData...'
EXEC dbo.sp_ResetDemoData;
GO

IF OBJECT_ID('CK_tblPerson_Age', 'C') IS NOT NULL
    BEGIN
        ALTER TABLE tblPerson
        DROP CONSTRAINT CK_tblPerson_Age ;
        PRINT 'INFO | dropping Check Constraint CK_tblPerson_Age created.';
    END
GO

IF COL_LENGTH('tblPerson', 'Age') IS NOT NULL
    BEGIN
        ALTER TABLE tblPerson
        DROP COLUMN Age;
        PRINT 'INFO | Dropped Column Age form tblPerson.';
    END

ALTER TABLE tblPerson
ADD Age INT NULL;
PRINT 'INFO | Column Age added to tblPerson.';
GO

SELECT * from tblPerson;
GO


PRINT 'INFO | adding wrong age before setting check constraint...';
INSERT INTO tblPerson
VALUES
(6, 'wrongage', 'wrong@age.com', 1, -1000);
GO

IF OBJECT_ID('CK_tblPerson_Age', 'C') IS NULL
BEGIN
    ALTER TABLE tblPerson
    WITH NOCHECK                        -- this does not fail checking the current records
    ADD CONSTRAINT CK_tblPerson_Age 
    CHECK (Age >= 0 AND Age < 150);
    PRINT 'INFO | Check Constraint CK_tblPerson_Age created.';
END
GO

PRINT 'INFO | trying to add wrong age after setting check constraint...';
INSERT INTO tblPerson
VALUES
(7, 'wrongage', 'wrong@age.com', 1, -1000);
-- The ALTER TABLE statement conflicted with the CHECK constraint "CK_tblPerson_Age". 
-- The conflict occurred in database "sample", table "dbo.tblPerson", column 'Age'.
GO

PRINT 'INFO | adding null age after setting check constraint...';
INSERT INTO tblPerson
VALUES
(8, 'nullage', 'null@age.com', 1, NULL);
-- The ALTER TABLE statement conflicted with the CHECK constraint "CK_tblPerson_Age". 
-- The conflict occurred in database "sample", table "dbo.tblPerson", column 'Age'.
GO

SELECT * from tblPerson;
GO
