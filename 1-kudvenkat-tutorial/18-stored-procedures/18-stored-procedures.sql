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

/* simple query example */
CREATE OR ALTER PROCEDURE spGetEmployees
AS
BEGIN
    SELECT Name, Gender FROM dbo.tblEmployee;
END

EXEC dbo.spGetEmployees;
GO

CREATE OR ALTER PROCEDURE spGetEmployeesByGenderAndDepartment
    @Gender NVARCHAR(10),
    @DepartmentId INT
AS
BEGIN
    SELECT Name, Gender, DepartmentId 
    FROM dbo.tblEmployee
    WHERE Gender = @Gender AND DepartmentId = @DepartmentId;
END
GO

/*
************************************************************************************
    demostrating using positional parameters risks
************************************************************************************
*/
EXEC dbo.spGetEmployeesByGenderAndDepartment 'Male', 1;
GO
EXEC dbo.spGetEmployeesByGenderAndDepartment 'Male', 2;
GO

BEGIN TRY
    EXEC dbo.spGetEmployeesByGenderAndDepartment 1, 'Male';
END TRY
BEGIN CATCH
    select
        'Wrong order of parameters' AS [Message],
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH
GO

/*
************************************************************************************
    using named parameters fixes the problem
************************************************************************************
*/
EXEC dbo.spGetEmployeesByGenderAndDepartment @DepartmentId = 1, @Gender = 'Male';
GO

/*
************************************************************************************
    get sp text with system sp
    EXEC is not mandatory for system sps but its recommended
    because the call should be the first of the batch
************************************************************************************
*/
sp_helptext spGetEmployeesByGenderAndDepartment;
GO

/*
************************************************************************************
    get sp metadata with system sp
    EXEC is not mandatory for system sps but its recommended
    because the call should be the first of the batch
************************************************************************************
*/
sp_help spGetEmployeesByGenderAndDepartment;
GO





