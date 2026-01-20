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

IF OBJECT_ID('dbo.tblIndiacustomers', 'U') IS NOT NULL
    DROP TABLE dbo.tblIndiaCustomers;

CREATE TABLE dbo.tblIndiaCustomers (
    Id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NULL,
    Email NVARCHAR(50) NULL
)

INSERT INTO dbo.tblIndiaCustomers
VALUES 
('Raj', 'R@R.com'),
('Sam', 'S@S.com')
GO

IF OBJECT_ID('dbo.tblUKCustomers', 'U') IS NOT NULL
    DROP TABLE dbo.tblUKCustomers;

CREATE TABLE dbo.tblUKCustomers (
    Id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NULL,
    Email NVARCHAR(50) NULL
)

INSERT INTO dbo.tblUKCustomers
VALUES 
('Ben', 'B@B.com'),
('Sam', 'S@S.com')
GO


SELECT *
FROM dbo.tblIndiaCustomers
UNION ALL                       -- with duplicates
SELECT *
FROM dbo.tblUKCustomers
GO

SELECT *
FROM dbo.tblIndiaCustomers
UNION                           -- no duplicates
SELECT *
FROM dbo.tblUKCustomers
GO

SELECT id, name, email          -- order is different
FROM dbo.tblIndiaCustomers
UNION                           -- no duplicates
SELECT id, email, name          -- order is different
FROM dbo.tblUKCustomers
GO

SELECT *
FROM dbo.tblIndiaCustomers
UNION ALL
SELECT *
FROM dbo.tblUKCustomers
ORDER BY Name                   -- order by refers to union
GO

