-- Ensure we start with execution enabled
SET NOEXEC OFF;
GO

USE [sample];
GO

SET NOCOUNT ON;
GO

PRINT 'INFO | --- Real Life Use Case: The "Scratchpad" (Temp Table) ---';

-- Scenario: We want to generate a report of People, but we need to do some
-- "heavy processing" on the data before showing it.
-- Instead of one giant complex query, we use a Temp Table (#) as a workspace.
--
-- WHY NOT A REGULAR TABLE?
-- 1. Automatic Cleanup: #Tables disappear when the session ends. No junk left behind.
-- 2. Isolation: Two users can run this script at the same time without conflict.
--    Each user gets their own private version of #ReportStaging.

-- 1. Clean up if it exists (Good practice for re-running scripts)
-- Note on "tempdb..#ReportStaging": The two dots (..) mean "default schema".
-- It is shorthand for "tempdb.dbo.#ReportStaging".
IF OBJECT_ID('tempdb..#ReportStaging') IS NOT NULL
    DROP TABLE #ReportStaging;
GO

-- 2. Create the Temporary Table (The Scratchpad)
-- Note the single hash (#) prefix. This means it lives in tempdb.
CREATE TABLE #ReportStaging (
    PersonID INT,
    PersonName NVARCHAR(50),
    StatusMessage NVARCHAR(100) -- A column we will calculate later
);
GO

-- 3. Load raw data (The "Extract" phase)
PRINT 'INFO | Loading raw data into #ReportStaging...';
INSERT INTO #ReportStaging (PersonID, PersonName)
SELECT ID, Name FROM dbo.tblPerson;
GO

-- 4. Process the data (The "Transform" phase)
-- In real life, this could be complex math, tax calculations, or text formatting.

PRINT 'INFO | Processing data: Marking VIPs...';
-- Logic: Anyone with an ID < 5 is a "VIP"
UPDATE #ReportStaging
SET StatusMessage = 'VIP Member'
WHERE PersonID < 5;

PRINT 'INFO | Processing data: Marking New Users...';
-- Logic: Anyone else is a "New User"
UPDATE #ReportStaging
SET StatusMessage = 'Standard User'
WHERE StatusMessage IS NULL;

-- 5. Output the final result (The "Load" phase)
PRINT 'INFO | Final Report:';
SELECT * FROM #ReportStaging ORDER BY PersonID;
GO

-- 6. Cleanup (Optional, as # tables drop automatically when session ends)
DROP TABLE #ReportStaging;
GO

-- Difference Recap:
-- @Variable: In-memory only, scope is just the current batch. Good for small lists.
-- #TempTable: Actual table in tempdb, scope is the whole session. Good for heavy lifting.