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
    re-create tblEmployee
************************************************************************************
*/
DROP TABLE IF EXISTS dbo.tblEmployee;
GO

SELECT *
INTO dbo.tblEmployee
FROM (VALUES 
    ( 1, 'Sam'  , 'Male'  , 1),
    ( 2, 'Ram'  , 'Male'  , 1),
    ( 3, 'Sara' , 'Female', 3),
    ( 4, 'Todd' , 'Male'  , 2),
    ( 5, 'John' , 'Male'  , 3),
    ( 6, 'Sara' , 'Female', 2),
    ( 7, 'James', 'Male'  , 1),
    ( 8, 'Rob'  , 'Male'  , 2),
    ( 9, 'Steve', 'Male'  , 1),
    (10, 'Pam'  , 'Female', 2)
) AS Source(id, Name, Gender, DepartmentId);

select * from dbo.tblEmployee;
GO

/*
************************************************************************************
    start lesson
************************************************************************************
*/
CREATE OR ALTER PROCEDURE spGetEmployeeCountByGender
    @Gender NVARCHAR(10),
    @EmployeeCount INT OUTPUT           -- output parameter
AS
BEGIN
    SELECT @EmployeeCount = COUNT(id)   -- assign out value
    FROM dbo.tblEmployee
    WHERE Gender = @Gender;
END
GO

/* positional parameters form */
DECLARE @EmployeeTotal INT;
EXEC dbo.spGetEmployeeCountByGender 
    'Male', 
    @EmployeeTotal OUTPUT;                  -- this assigns @EmployeeCount to @EmployeeTotal
SELECT @EmployeeTotal AS EmployeeTotal;
GO

/* named parameters form */
DECLARE @EmployeeTotal INT;
EXEC dbo.spGetEmployeeCountByGender 
    @Gender = 'Male', 
    @EmployeeCount = @EmployeeTotal OUTPUT; -- this assigns @EmployeeCount to @EmployeeTotal
SELECT @EmployeeTotal AS EmployeeTotal;
GO






