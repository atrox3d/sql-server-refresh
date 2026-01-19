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

IF OBJECT_ID('dbo.tblEmployeeCoalesce', 'U') IS NOT NULL
    DROP TABLE dbo.tblEmployeeCoalesce;
GO

CREATE TABLE dbo.tblEmployeeCoalesce (
    Id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NULL,
    MiddleName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL
)
GO

INSERT INTO dbo.tblEmployeeCoalesce
VALUES 
('Mike', NULL, NULL),
(NULL, 'Todd', 'Tanzan'),
(NULL, NULL, 'Sara'),
('Ben', 'Parker', NULL),
('James', 'Nick', 'Nancy')
GO


-- self join
SELECT      Id, COALESCE(FirstName, MiddleName, LastName) AS Name
FROM        dbo.tblEmployeeCoalesce
GO
