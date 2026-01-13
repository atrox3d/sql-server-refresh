-- SQLCMD Mode command: Stop execution on any error in any batch.
-- This must be enabled in the client (e.g., SSMS Query -> SQLCMD Mode).
-- :ON ERROR EXIT
-- GO

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

-- Demonstrate TRY...CATCH to handle errors within a batch
BEGIN TRY
    PRINT 'INFO | Trying to add wrong age after setting check constraint...';
    INSERT INTO tblPerson VALUES (7, 'wrongage', 'wrong@age.com', 1, -1000);
    PRINT 'INFO | This line will NOT be reached.';
END TRY
BEGIN CATCH
    PRINT 'ERROR | An error occurred. Execution jumped to the CATCH block.';
    PRINT 'ERROR | Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'ERROR | Error Message: ' + ERROR_MESSAGE();
    -- To stop the entire script, we must re-throw the error.
    -- Because of ":ON ERROR EXIT" at the top, this will terminate the script.
    THROW; 
END CATCH
GO

PRINT 'INFO | This batch will NOT execute because the previous batch re-threw an error.';
PRINT 'INFO | Adding null age. This will SUCCEED because CHECK constraints allow NULLs by default.';
INSERT INTO tblPerson
VALUES
(8, 'nullage', 'null@age.com', 1, NULL);
PRINT 'INFO | NULL value inserted successfully.';
GO

SELECT * from tblPerson;
GO
