USE [sample];
GO

SET NOCOUNT ON;
GO
-- Q: In real life, would I create a function?
-- A: No. Functions in SQL Server are read-only (mostly).
--    For actions that modify data (INSERT/DELETE), we use STORED PROCEDURES.

-- Check if procedure exists to drop it (Standard pattern before CREATE OR ALTER existed)
-- IF OBJECT_ID('dbo.sp_ResetDemoData', 'P') IS NOT NULL
--     DROP PROCEDURE dbo.sp_ResetDemoData;
-- GO

-- CREATE OR ALTER is available in newer SQL Server versions (2016+)
-- It handles "Create if new, Alter if exists" automatically.
CREATE OR ALTER PROCEDURE dbo.sp_ResetDemoData
AS
BEGIN
    -- Stop "rows affected" noise inside the procedure
    SET NOCOUNT ON;

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
        (4, 'sara',   's@r.com',      3),
        (5, 'Johnny', 'j@r.com',      3);

    PRINT 'INFO | sp_ResetDemoData: Data reset complete.';
END
GO

-- Now, in your other scripts, you can replace those 20 lines with just this:
-- EXEC dbo.sp_ResetDemoData;
-- GO