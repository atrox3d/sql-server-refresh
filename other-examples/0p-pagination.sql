-- Ensure we start with execution enabled
SET NOEXEC OFF;
GO

USE [sample];
GO

SET NOCOUNT ON;
GO

PRINT 'INFO | --- Pagination in SQL Server (TOP vs OFFSET) ---';

-- 1. Setup: Create a table with data to paginate
IF OBJECT_ID('dbo.PaginationTest', 'U') IS NOT NULL DROP TABLE dbo.PaginationTest;
CREATE TABLE dbo.PaginationTest (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Val NVARCHAR(20)
);
GO

-- Insert 25 rows
DECLARE @i INT = 1;
WHILE @i <= 25
BEGIN
    INSERT INTO dbo.PaginationTest (Val) VALUES ('Item ' + CAST(@i AS VARCHAR));
    SET @i = @i + 1;
END
PRINT 'INFO | Created dbo.PaginationTest with 25 rows.';
GO

-- 2. The "TOP" Keyword (No Offset)
PRINT 'INFO |';
PRINT 'INFO | --- 1. TOP (No Offset) ---';
PRINT 'INFO | TOP is used to limit results from the start. It cannot skip rows.';

SELECT TOP 5 * 
FROM dbo.PaginationTest
ORDER BY ID;
GO

-- 3. The "OFFSET / FETCH" Syntax (SQL 2012+)
PRINT 'INFO |';
PRINT 'INFO | --- 2. OFFSET / FETCH NEXT (The Standard Way) ---';
PRINT 'INFO | This requires an ORDER BY clause.';
PRINT 'INFO | Syntax: ORDER BY ... OFFSET [Skip] ROWS FETCH NEXT [Take] ROWS ONLY';

-- Example: Get "Page 2" (Skip 5, Take 5)
SELECT * 
FROM dbo.PaginationTest
ORDER BY ID
OFFSET 5 ROWS
FETCH NEXT 5 ROWS ONLY;
GO

-- 4. Dynamic Pagination with Variables
PRINT 'INFO |';
PRINT 'INFO | --- 3. Using Variables for Pagination ---';

DECLARE @PageNumber INT = 3;
DECLARE @PageSize INT = 5;

-- Calculate rows to skip
DECLARE @RowsToSkip INT = (@PageNumber - 1) * @PageSize;

PRINT 'INFO | Fetching Page ' + CAST(@PageNumber AS VARCHAR) + 
      ' (Skip ' + CAST(@RowsToSkip AS VARCHAR) + ', Take ' + CAST(@PageSize AS VARCHAR) + ')...';

SELECT * 
FROM dbo.PaginationTest
ORDER BY ID
OFFSET @RowsToSkip ROWS
FETCH NEXT @PageSize ROWS ONLY;
GO

-- Cleanup
DROP TABLE dbo.PaginationTest;
GO