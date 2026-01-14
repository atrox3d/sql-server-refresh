-- Simulate an "Array" using a Table Variable
DECLARE @NameArray TABLE (
    Idx INT IDENTITY(1,1), -- Acts as the array index
    Value NVARCHAR(50)     -- Acts as the value
);

-- Initialize the "Array" with values
INSERT INTO @NameArray (Value)
VALUES ('John'), ('Mary'), ('Peter'), ('Steve'), ('Laura');

DECLARE @Index INT = 1;
DECLARE @TotalItems INT = (SELECT COUNT(*) FROM @NameArray);
DECLARE @CurrentName NVARCHAR(50);

WHILE (@Index <= @TotalItems)
BEGIN
    -- Get value at current index (Like: name = arr[i])
    SELECT @CurrentName = Value FROM @NameArray WHERE Idx = @Index;

    INSERT INTO dbo.tblPerson1 (Name)
    VALUES (@CurrentName);

    PRINT 'INFO | Inserted Name: ' + @CurrentName;
    SET @Index = @Index + 1;
END
The more efficient, set-based approach (avoids loops)
Insert all values from the table variable in a single operation.
PRINT 'INFO | Inserting all names from the table variable in a single set-based operation...';
This is inserting from a SOURCE (the table variable).
INSERT INTO dbo.tblPerson1 (Name)
SELECT Value FROM @NameArray;
GO

PRINT 'INFO | --- A Truly Dynamic Example ---';
PRINT 'INFO | Now, lets insert names from a different table based on a condition.';

-- 1. Get some fresh data into the main tblPerson table
EXEC dbo.sp_ResetDemoData;

-- 2. Dynamically insert only the 'Male' (GenderId = 1) people into our new table.
-- The source of this data is determined at runtime by the SELECT query.
INSERT INTO dbo.tblPerson1 (Name)
SELECT Name FROM dbo.tblPerson WHERE GenderId = 1;
GO
