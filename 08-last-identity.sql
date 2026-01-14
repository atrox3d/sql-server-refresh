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
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO

IF OBJECT_ID('dbo.Test1', 'U') IS NOT NULL
    DROP TABLE dbo.Test1;
CREATE TABLE dbo.Test1 (
    ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Value NVARCHAR(50) NOT NULL
)
GO

IF OBJECT_ID('dbo.Test2', 'U') IS NOT NULL
    DROP TABLE dbo.Test2;
CREATE TABLE dbo.Test2 (
    ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Value NVARCHAR(50) NOT NULL
)
GO


INSERT INTO dbo.Test1
VALUES ('x');

SELECT * FROM dbo.Test1;

SELECT 
    SCOPE_IDENTITY() as [SCOPE_IDENTITY],                   -- same session, same scope
    @@IDENTITY as [@@IDENTITY],                             -- same session, any scope
    IDENT_CURRENT('dbo.Test1') as [IDENT_CURRENT(Test1)]    -- specific table in same session, any scope
;
GO


CREATE TRIGGER trForInsert ON dbo.Test1
FOR INSERT -- 'FOR' is the legacy syntax for 'AFTER'. They are identical.
AS
BEGIN
    INSERT INTO dbo.Test2 VALUES ('INSERTED')
END
GO


INSERT INTO dbo.Test1
VALUES ('x');

    SELECT
        'INSERT on dbo.Test1' as [event],
        'INSERT on dbo.Test2' as [trigger],
        SCOPE_IDENTITY() as [SCOPE_IDENTITY],                   -- same session, same scope
        @@IDENTITY as [@@IDENTITY],                             -- same session, any scope
        IDENT_CURRENT('dbo.Test1') as [IDENT_CURRENT(Test1)],    -- specific table in same session, any scope
        IDENT_CURRENT('dbo.Test2') as [IDENT_CURRENT(Test2)]    -- specific table in same session, any scope
    ;
GO
SELECT * FROM dbo.Test1;
GO
