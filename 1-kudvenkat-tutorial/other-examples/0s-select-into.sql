-- Standard pattern: Check if it exists, drop it, then recreate it
-- The ".." notation means "default schema" (dbo). So it resolves to tempdb.dbo.#MyTempTable
IF OBJECT_ID('tempdb..#MyTempTable') IS NOT NULL
    DROP TABLE #MyTempTable;

-- Now this will succeed because the table is gone
SELECT 
    ID, 
    Name,
    CAST(0 AS BIT) AS IsDisplayed -- Create boolean column initialized to 0 (False)
INTO #MyTempTable
FROM dbo.tblPerson;


-- Assume #MyTempTable already exists and has data.
-- This appends new rows to the bottom.
INSERT INTO #MyTempTable (ID, Name, IsDisplayed)
SELECT ID, Name, 0
FROM dbo.tblPerson
WHERE ID > 100;

-- 1. Select only new (undisplayed) items
SELECT * FROM #MyTempTable WHERE IsDisplayed = 0;

-- 2. Mark them as displayed so they don't show up next time
UPDATE #MyTempTable 
SET IsDisplayed = 1 
WHERE IsDisplayed = 0;
