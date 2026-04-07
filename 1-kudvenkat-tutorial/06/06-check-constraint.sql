-- SQLCMD Mode command: Stop execution on any error in any batch.
-- This must be enabled in the client (e.g., SSMS Query -> SQLCMD Mode).
-- :ON ERROR EXIT
-- GO
-- Ensure we start with execution enabled (in case previous run stopped it)
SET NOEXEC OFF;
GO

USE [sample];
GO

-- Best Practice: Stop "rows affected" noise
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
DECLARE @Msg NVARCHAR(MAX) = 'Initial Database Context: ' + DB_NAME();
EXEC dbo.spInfo @Msg, 1;
GO

--*********************************
--- prepare data
--*********************************
EXEC dbo.spInfo 'Executing sp_ResetDemoData...', 1;
EXEC dbo.sp_ResetDemoData;
GO

IF OBJECT_ID('CK_tblPerson_Age', 'C') IS NOT NULL
    BEGIN
        ALTER TABLE tblPerson
        DROP CONSTRAINT CK_tblPerson_Age ;
        EXEC dbo.spInfo 'dropping Check Constraint CK_tblPerson_Age created.', 1;
    END
GO

IF COL_LENGTH('tblPerson', 'Age') IS NOT NULL
    BEGIN
        ALTER TABLE tblPerson
        DROP COLUMN Age;
        EXEC dbo.spInfo 'Dropped Column Age form tblPerson.', 1;
    END

ALTER TABLE tblPerson
ADD Age INT NULL;
EXEC dbo.spInfo 'Column Age added to tblPerson.', 1;
GO

SELECT * from tblPerson;
GO


EXEC dbo.spInfo 'adding wrong age before setting check constraint...', 1;
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
    EXEC dbo.spInfo 'Check Constraint CK_tblPerson_Age created.', 1;
END
GO

-- Demonstrate TRY...CATCH to handle errors within a batch
BEGIN TRY
    EXEC dbo.spInfo 'Trying to add wrong age after setting check constraint...', 1;
    INSERT INTO tblPerson VALUES (7, 'wrongage', 'wrong@age.com', 1, -1000);
    EXEC dbo.spInfo 'This line will NOT be reached.', 1;
END TRY
BEGIN CATCH
    EXEC dbo.spError 'An error occurred. Execution jumped to the CATCH block.';
    -- To stop the entire script, we must re-throw the error.
    -- Because of ":ON ERROR EXIT" at the top, this will terminate the script.
    -- THROW; 
    -- Stop the script execution for subsequent batches
    EXEC dbo.spInfo 'Stopping script execution via SET NOEXEC ON.', 1;
    SET NOEXEC ON;
END CATCH
GO

EXEC dbo.spInfo 'This batch will NOT execute because the previous batch re-threw an error.';
EXEC dbo.spInfo 'This batch will NOT execute because the previous batch set NOEXEC ON.';
EXEC dbo.spInfo 'Adding null age. This will SUCCEED because CHECK constraints allow NULLs by default.';
EXEC dbo.spFLush;
GO

INSERT INTO tblPerson
VALUES
(8, 'nullage', 'null@age.com', 1, NULL);
EXEC dbo.spInfo 'NULL value inserted successfully.', 1;
GO

SELECT * from tblPerson;
GO
