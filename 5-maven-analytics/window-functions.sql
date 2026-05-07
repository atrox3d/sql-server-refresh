use mavenanalytics;
GO

/*
    ############################################################
    #   PREPARE TABLE
    ############################################################
*/
IF OBJECT_ID('baby_names') IS NULL
    CREATE TABLE baby_names (
        Gender VARCHAR(10),
        Name VARCHAR(50),
        Total INT
    );

TRUNCATE TABLE baby_names;

INSERT INTO baby_names (Gender, Name, Total) 
VALUES
        ('Girl' , 'Ava'     , 95),
        ('Girl' , 'Emma'    , 106),
        ('Boy'  , 'Ethan'   , 115),
        ('Girl' , 'Isabella', 100),
        ('Boy'  , 'Jacob'   , 101),
        ('Boy'  , 'Liam'    , 84),
        ('Boy'  , 'Logan'   , 73),
        ('Boy'  , 'Noah'    , 120),
        ('Girl' , 'Olivia'  , 100),
        ('Girl' , 'Sophia'  , 88);
GO

SELECT * FROM baby_names;
GO

/*
    ############################################################
    #   START EXERCISE
    ############################################################
*/
SELECT
    *
    , ROW_NUMBER() OVER(ORDER BY Total DESC)    AS Popularity
    , RANK() OVER(ORDER BY Total DESC)          AS Ranking
    , DENSE_RANK() OVER(ORDER BY Total DESC)    AS DenseRanking
FROM baby_names;
GO

SELECT
    *
    , ROW_NUMBER() OVER(
        PARTITION BY Gender
        ORDER BY Total DESC
    )    AS Popularity
FROM baby_names;
GO

/*
    ############################################################
    #   FIRST_VALUE AND LAST_VALUE
    ############################################################
*/
SELECT
    *
    , FIRST_VALUE(Name) OVER(ORDER BY Total DESC) AS OverallTopName
    , FIRST_VALUE(Name) OVER(PARTITION BY Gender ORDER BY Total DESC) AS TopNameInGender
    , LAST_VALUE(Name) OVER(
        ORDER BY Total DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS OverallBottomName
FROM baby_names;
GO

/*
    ############################################################
    #   DISPLAY ONLY THE FIRST VALUE OF EACH WINDOW (TOP 1)
    ############################################################
*/
-- This pattern is the standard way to solve "Top N per Group" problems.
WITH RankedByGender AS (
    SELECT
        Gender
        , Name
        , Total
        , ROW_NUMBER() OVER(PARTITION BY Gender ORDER BY Total DESC) AS RankIndex
    FROM baby_names
)
SELECT 
    Gender, Name, Total
FROM RankedByGender
WHERE RankIndex = 1; -- This effectively filters the result to the "First Value" of each window
GO

/*
    ############################################################
    #   PRACTICING FRAME VARIATIONS (ROWS VS RANGE)
    ############################################################
*/
SELECT
    Name
    , Total
    -- This is the "Running Total" logic. 
    -- NOTE: If you omit this, SQL defaults to RANGE, which handles ties differently!
    , SUM(Total) OVER(ORDER BY Total DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
    -- Physical: Just the row before and current row
    , SUM(Total) OVER(ORDER BY Total DESC 
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS PhysicalPrevPlusCurrent
    
    -- Logical: If totals are tied, it includes all tied rows
    , SUM(Total) OVER(ORDER BY Total DESC 
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ValueBasedRunningTotal
    
    -- Lookahead: Current row plus the next 2 rows
    , LEAD(Name, 1) OVER(ORDER BY Total DESC) AS NextName
FROM baby_names;
GO

/*
    ############################################################
    #   AGGREGATES AS WINDOW FUNCTIONS
    ############################################################
*/
SELECT
    Name
    , Gender
    , Total
    -- Running Count: How many babies have we "seen" so far?
    , COUNT(*) OVER(ORDER BY Total DESC) AS RunningCount
    
    -- Windowed Max: What is the highest Total in this Gender?
    , MAX(Total) OVER(PARTITION BY Gender) AS MaxTotalInGender
    
    -- Moving Average: Average of current row and the 2 rows immediately before it
    , AVG(Total) OVER(ORDER BY Total DESC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeRowMovingAvg
FROM baby_names;
GO
