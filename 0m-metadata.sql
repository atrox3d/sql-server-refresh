PRINT 'INFO | --- How to "Describe" a Table in SQL Server ---';
PRINT 'INFO | There is no DESCRIBE command. Use the sp_help system stored procedure.';
GO

This is the primary equivalent of DESCRIBE. It returns multiple result sets
with columns, indexes, constraints, etc.
EXEC sp_help 'dbo.Test1';
GO

For just column information, you can use sp_columns.
PRINT 'INFO | For a more focused view on just the columns, use sp_columns:';
EXEC sp_columns 'Test1';
GO

PRINT 'INFO | --- MySQL "SHOW" Equivalents ---';
PRINT 'INFO | SQL Server uses ANSI Standard INFORMATION_SCHEMA views instead of SHOW.';
GO

-- Equivalent to: SHOW TABLES;
SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
    AND TABLE_NAME LIKE 'test%'
;

-- Equivalent to: SHOW COLUMNS FROM Test1;
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME like 'Test%';
GO
