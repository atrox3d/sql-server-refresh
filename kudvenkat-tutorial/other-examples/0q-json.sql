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

IF OBJECT_ID('dbo.tblEmployee', 'U') IS NOT NULL
    DROP TABLE dbo.tblEmployee;
GO

CREATE TABLE dbo.tblEmployee (
    EmployeeId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    ManagerId INT
)
GO

PRINT 'INFO | Inserting data from a JSON string (the modern "lazy" way)...';
-- We use IDENTITY_INSERT to manually specify EmployeeId so we can reliably set ManagerId
SET IDENTITY_INSERT dbo.tblEmployee ON;

-- For inserting structured data (like a list of Python tuples/objects), OPENJSON is the best practice.
-- It's far more robust and readable than trying to parse multiple delimited strings.
-- The 'N' prefix before the string stands for "National Language Support" (Unicode).
-- It ensures special characters (like emojis or foreign accents) are preserved correctly as NVARCHAR.
DECLARE @json_data NVARCHAR(MAX) = N'[
    {"id": 1, "name": "Mike", "manager": null},
    {"id": 2, "name": "Rob", "manager": 1},
    {"id": 3, "name": "Todd", "manager": 1},
    {"id": 4, "name": "Ben", "manager": 1},
    {"id": 5, "name": "Sam", "manager": 1}
]';

INSERT INTO dbo.tblEmployee (EmployeeId, Name, ManagerId)
SELECT id, name, manager
FROM OPENJSON(@json_data)
WITH (
    id      INT           '$.id',
    name    NVARCHAR(50)  '$.name',
    manager INT           '$.manager'
);

SET IDENTITY_INSERT dbo.tblEmployee OFF;
GO

SELECT * FROM dbo.tblEmployee;
GO
