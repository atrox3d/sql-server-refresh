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

PRINT 'INFO | Inserting data with Manager relationships...';
-- We use IDENTITY_INSERT to manually specify EmployeeId so we can reliably set ManagerId
SET IDENTITY_INSERT dbo.tblEmployee ON;

--                          Todd (3)
--                           |
--                          Mike (1)
--                           |
--               +-----------+---------+
--               |           |         |
--              Rob (2)     Ben (4)   Sam (5)
INSERT INTO dbo.tblEmployee (EmployeeId, Name, ManagerId)
VALUES 
(1, 'Mike', 3),     -- Reports to Todd
(2, 'Rob',  1),     -- Reports to Mike
(3, 'Todd', NULL),  -- Boss
(4, 'Ben',  1),     -- Reports to Mike
(5, 'Sam',  1);     -- Reports to Mike

SET IDENTITY_INSERT dbo.tblEmployee OFF;
GO

-- self join
SELECT      E.Name as Employee, M.Name as Manager
FROM        dbo.tblEmployee E
LEFT JOIN   dbo.tblEmployee M
ON          E.ManagerId = M.EmployeeId
GO

-------------------------------------------------------------------------
--      ISNULL
-------------------------------------------------------------------------
select 
    ISNULL(NULL,         'No Manager') as [isnull-null],
    ISNULL('NOT NULL',   'No Manager') as [isnull-notnull]
;
GO

-------------------------------------------------------------------------
--      COALESCE
-------------------------------------------------------------------------
select 
    COALESCE(NULL,         'No Manager') as [coalesce-null],
    COALESCE('NOT NULL',   'No Manager') as [coalesce-notnull]
;
GO

-------------------------------------------------------------------------
--      CASE WHEN
-------------------------------------------------------------------------
select
    CASE
        WHEN 
            NULL IS NULL THEN 'No Manager'
        ELSE 
            'NOT NULL'
    END AS [case-null],
        
    CASE 
        WHEN
            'NOT NULL' IS NULL THEN 'No Manager'
        ELSE 
            'NOT NULL'
    END AS [case-notnull]
;
GO


-------------------------------------------------------------------------
-- self join
-- test all
-------------------------------------------------------------------------
SELECT      
            E.Name as Employee, 
            ISNULL(M.Name, 'No Manager') as [isnull-Manager],
            COALESCE(M.Name, 'No Manager') as [coalesce-Manager],
            CASE
                WHEN M.Name IS NULL THEN 'No Manager'
                ELSE M.Name
            END AS [case-Manager]
FROM        dbo.tblEmployee E
LEFT JOIN   dbo.tblEmployee M
ON          E.ManagerId = M.EmployeeId
GO
