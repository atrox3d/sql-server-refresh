-- Ensure we start with execution enabled
SET NOEXEC OFF;
GO

USE [sample];
GO

SET NOCOUNT ON;
GO

PRINT 'INFO | --- Demonstrating Scope for Identity Functions ---';
PRINT 'INFO | Session = Your current connection.';
PRINT 'INFO | Scope = A "Module of Execution".';
PRINT 'INFO |';
PRINT 'INFO | WHAT CREATES A NEW SCOPE?';
PRINT 'INFO | 1. A Stored Procedure (when you EXEC it).';
PRINT 'INFO | 2. A Trigger (when it fires).';
PRINT 'INFO | 3. Dynamic SQL (EXEC sp_executesql ...).';
PRINT 'INFO | 4. A Batch (The code between two GO commands).';
PRINT 'INFO | NOTE: Simple commands (INSERT, UPDATE) do NOT create a new scope.';
GO

-- 1. Setup: Create two tables. An insert into the OUTER table will
--    fire a trigger that inserts into the INNER table.

IF OBJECT_ID('dbo.ScopeTest_Outer', 'U') IS NOT NULL DROP TABLE dbo.ScopeTest_Outer;
IF OBJECT_ID('dbo.ScopeTest_InnerLog', 'U') IS NOT NULL DROP TABLE dbo.ScopeTest_InnerLog;
GO

CREATE TABLE dbo.ScopeTest_Outer (
    ID INT IDENTITY(100,1) PRIMARY KEY, -- Starts at 100
    Data NVARCHAR(50)
);

CREATE TABLE dbo.ScopeTest_InnerLog (
    ID INT IDENTITY(5000,1) PRIMARY KEY, -- Starts at 5000
    LogMessage NVARCHAR(200)
);
GO

-- This trigger creates a NEW SCOPE.
CREATE OR ALTER TRIGGER trg_LogOuterInsert ON dbo.ScopeTest_Outer
AFTER INSERT
AS
BEGIN
    -- Best Practice: Prevent the trigger's own INSERT from returning a row count.
    SET NOCOUNT ON;

    PRINT 'INFO | --- Trigger Fired (Inner Scope) ---';
    INSERT INTO dbo.ScopeTest_InnerLog (LogMessage) VALUES ('An item was inserted into ScopeTest_Outer.');
    PRINT 'INFO | --- Trigger Finished ---';
END
GO


-- 2. The Test: Insert a row and check the identity functions.

PRINT 'INFO | Inserting a row into the OUTER table (Outer Scope)...';

INSERT INTO dbo.ScopeTest_Outer (Data) VALUES ('My Test Data');

PRINT 'INFO | Insert complete. Now checking the identity values...';
GO

SELECT
    SCOPE_IDENTITY() AS [SCOPE_IDENTITY()],
    -- Returns the last identity created in the CURRENT SESSION and CURRENT SCOPE.
    -- Our scope was the INSERT statement into ScopeTest_Outer.

    @@IDENTITY AS [@@IDENTITY],
    -- Returns the last identity created in the CURRENT SESSION, across ANY SCOPE.
    -- The last one created was by the trigger in the inner scope.

    IDENT_CURRENT('dbo.ScopeTest_Outer') AS [IDENT_CURRENT(Outer)],
    IDENT_CURRENT('dbo.ScopeTest_InnerLog') AS [IDENT_CURRENT(InnerLog)]
    -- Returns the last identity created for a SPECIFIC TABLE, across ANY SESSION and ANY SCOPE.
    -- This is dangerous as another user could be inserting at the same time.
GO

PRINT 'INFO |';
PRINT 'INFO | --- Answering: Why are 5 INSERTs in the same scope? ---';
PRINT 'INFO | Think of Scope as a "Room". You are currently in the "Batch Room".';
PRINT 'INFO | You can do 5 different things (Inserts) in this room, but you never left the room.';

INSERT INTO dbo.ScopeTest_Outer (Data) VALUES ('Action 1');
PRINT 'INFO | Action 1 ID: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR(10));

INSERT INTO dbo.ScopeTest_Outer (Data) VALUES ('Action 2');
PRINT 'INFO | Action 2 ID: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR(10));

PRINT 'INFO | Both actions happened in the SAME scope (the Batch). SCOPE_IDENTITY just updates to the latest one.';
GO

PRINT 'INFO |';
PRINT 'INFO | --- What terminates a scope? ---';
PRINT 'INFO | The scope of the previous batch was terminated by the GO command.';
PRINT 'INFO | Now we are in a NEW batch (a new scope).';
PRINT 'INFO | Since no identity values have been created in THIS new scope, SCOPE_IDENTITY() is NULL.';

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY() in a new batch];
GO

PRINT 'INFO |';
PRINT 'INFO | --- Devil''s Advocate Corner ---';
PRINT 'INFO | A single batch (between GOs) is ONE scope, no matter what happens inside.';

-- Start of a new Batch/Scope
PRINT 'INFO | 1. Inserting ''Devil''s Advocate 1''. The last ID in this scope should be set.';
INSERT INTO dbo.ScopeTest_Outer (Data) VALUES ('Devil''s Advocate 1');
SELECT SCOPE_IDENTITY() AS [ID after first INSERT];

PRINT 'INFO | 2. Running a SELECT. This is an action in the same scope, but it does not generate an ID.';
SELECT * FROM dbo.ScopeTest_Outer WHERE 1 = 0; -- A SELECT that does nothing
SELECT SCOPE_IDENTITY() AS [ID after SELECT (unchanged)];

PRINT 'INFO | 3. Inserting ''Devil''s Advocate 2''. The last ID in this scope should now update.';
INSERT INTO dbo.ScopeTest_Outer (Data) VALUES ('Devil''s Advocate 2');
SELECT SCOPE_IDENTITY() AS [ID after second INSERT (updated)];

PRINT 'INFO | The scope is the entire block. SCOPE_IDENTITY() just reports the last ID generated within it.';
GO