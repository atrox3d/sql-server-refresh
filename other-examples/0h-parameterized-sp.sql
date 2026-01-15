USE [sample];
GO

SET NOCOUNT ON;
GO

-- Create a Stored Procedure that accepts parameters.
-- This is the standard way to create reusable, safe, and parameterized logic.
CREATE OR ALTER PROCEDURE dbo.sp_AddPerson
    -- Define input parameters here
    @Name NVARCHAR(50),
    @Email NVARCHAR(50),
    @GenderId INT
AS
BEGIN
    -- It's best practice to validate inputs.
    -- Check if the provided GenderId is valid before inserting.
    IF NOT EXISTS (SELECT 1 FROM dbo.tblGender WHERE ID = @GenderId)
    BEGIN
        -- RAISERROR is the formal way to throw an error and stop execution.
        -- RAISERROR ('Invalid GenderId: %d. This ID does not exist in dbo.tblGender.', 16, 1, @GenderId);
        -- RETURN; -- Stop the procedure
        -- THROW is the modern replacement for RAISERROR (SQL 2012+)
        -- It's simpler and generally preferred.
        DECLARE @ErrorMessage NVARCHAR(2048) = FORMATMESSAGE('Invalid GenderId: %d. This ID does not exist in dbo.tblGender.', @GenderId);
        THROW 50001, @ErrorMessage, 1;
        -- The RETURN statement is no longer needed as THROW always stops execution.
    END

    -- Find the next available ID to avoid primary key conflicts.
    DECLARE @NextId INT = (SELECT ISNULL(MAX(ID), 0) + 1 FROM dbo.tblPerson);

    INSERT INTO dbo.tblPerson (ID, Name, Email, GenderId)
    VALUES (@NextId, @Name, @Email, @GenderId);

    PRINT 'INFO | Successfully added person: ' + @Name + ' with ID ' + CAST(@NextId AS VARCHAR(10));
END
GO

-- Now, you can execute the procedure like a function, passing arguments.
EXEC dbo.sp_AddPerson @Name = 'Laura', @Email = 'laura@test.com', @GenderId = 2;
EXEC dbo.sp_AddPerson @Name = 'Peter', @Email = 'peter@test.com', @GenderId = 1;

-- You CAN use positional arguments (Order matters: Name, Email, GenderId)
EXEC dbo.sp_AddPerson 'Positional Guy', 'pos@test.com', 2;

EXEC dbo.sp_AddPerson @Name = 'Test User', @Email = 'test@test.com', @GenderId = 99; -- This call will fail due to our validation.
GO

-- Verify the successful inserts
SELECT * FROM dbo.tblPerson WHERE Name IN ('Laura', 'Peter');
GO