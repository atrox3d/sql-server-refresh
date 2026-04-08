/*
************************************************************************************
    SQLCMD Mode command: Stop execution on any error in any batch.
    This must be enabled in the client (e.g., SSMS Query -> SQLCMD Mode).
    :ON ERROR EXIT
    GO
    Ensure we start with execution enabled (in case previous run stopped it)
************************************************************************************
*/
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

/*
************************************************************************************
    create tables Test1 and Test2 empty with identity reset to 0
    we can also truncate the tables
    another more surgical way could be:
        DBCC CHECKIDENT ('dbo.Table1', RESEED, 0);
    but it is dangerous

    IMPORTANT:
    PRIMARY KEY does not mean IDENTITY!!!
    - IDENTITY(1, 1) delegates the autoincrement management of the identity column to the database.
    - PRIMARY KEY alone creates a unique clustered key but the id value is dev responsibility
************************************************************************************
*/
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


/*
************************************************************************************
    insert value in Test1 and observe the three identities
    all identities functions return the same value: 1
    because:
        - SCOPE_IDENTITY() returns OUR last id
            this is relative to OUR SESSION and SCOPE
            another user can add another id at the same time
            so SCOPE_IDENTITY() return OUR LAST ID.
        
        - @@IDENTITY is a global variable that returns the LAST IDENTITY FOR THE SESSION, ANY SCOPE
            so if our insert TRIGGERS an INSERT elsewhere we get the SIDE EFFECT id:
            the id of the last table updated in the session

        - IDENT_CURRENT(table) returns the last id for a TABLE, SAME SESSION, ANY SCOPE
            this means that, again, the value could not match our last insert
    
    so in this case:
        - every table has zero rows
        - when we insert a row into Test1, there are no triggers
        - so we get:
            - Table1 last id: 1
            - Table2 last id: 1
        and:
            - SCOPE_IDENTITY(): 1
            - @@IDENTITY: 1
            - IDENT_CURRENT(Test1): 1
            - IDENT_CURRENT(Test2): 1
************************************************************************************
*/
INSERT INTO dbo.Test1
VALUES ('x');           -- id is 1

SELECT * FROM dbo.Test1;

SELECT 
    SCOPE_IDENTITY()                as [SCOPE_IDENTITY -- same session, same scope],                        -- same session, same scope
    @@IDENTITY                      as [@@IDENTITY -- same session, any scope] ,                            -- same session, any scope
    IDENT_CURRENT('dbo.Test1')      as [IDENT_CURRENT(Test1) -- specific table in same session, any scope]  -- specific table in same session, any scope
;
GO

/*
************************************************************************************
    create a trigger:
    when an insert occurs on Test1 we insert a record in Test2
    with value INSERTED
************************************************************************************
*/
CREATE TRIGGER trForInsert ON dbo.Test1
FOR INSERT -- 'FOR' is the legacy syntax for 'AFTER'. They are identical.
AS
BEGIN
    INSERT INTO dbo.Test2 VALUES ('INSERTED')   -- id is 1
END
GO


INSERT INTO dbo.Test1
VALUES ('x');           -- id is 2


SELECT * FROM dbo.Test1
UNION ALL
SELECT * FROM dbo.Test2;
GO

SELECT
    'INSERT on dbo.Test1'           as [event],
    'INSERT on dbo.Test2'           as [trigger],
    SCOPE_IDENTITY()                as [SCOPE_IDENTITY -- same session, same scope],                        -- same session, same scope
    @@IDENTITY                      as [@@IDENTITY -- same session, any scope],                            -- same session, same scope
    IDENT_CURRENT('dbo.Test1')      as [IDENT_CURRENT(Test1) -- specific table in same session, any scope], -- specific table in same session, any scope
    IDENT_CURRENT('dbo.Test2')      as [IDENT_CURRENT(Test2) -- specific table in same session, any scope]  -- specific table in same session, any scope
;
GO
SELECT * FROM dbo.Test1;
GO
