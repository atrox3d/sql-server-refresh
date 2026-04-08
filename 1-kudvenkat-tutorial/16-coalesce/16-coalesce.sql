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
    re-create tblEmployeeCoalesce
************************************************************************************
*/
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

/*
************************************************************************************
    create records with various null values
************************************************************************************
*/
INSERT INTO dbo.tblEmployeeCoalesce
VALUES 
('Mike' , NULL      , NULL),
(NULL   , 'Todd'    , 'Tanzan'),
(NULL   , NULL      , 'Sara'),
('Ben'  , 'Parker'  , NULL),
('James', 'Nick'    , 'Nancy')
GO


/*
************************************************************************************
    select the first non null column available
************************************************************************************
*/
SELECT      Id, COALESCE(FirstName, MiddleName, LastName) AS Name
FROM        dbo.tblEmployeeCoalesce
GO
