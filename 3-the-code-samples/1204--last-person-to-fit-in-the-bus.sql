/*
    https://leetcode.com/problems/last-person-to-fit-in-the-bus/
*/

use thecodesamples;
go

/*
    ############################################################
    #   PREPARE TABLE QUEUE
    ############################################################
*/
if OBJECT_ID('thecodesamples..Queue', 'U') is null
begin
    PRINT 'table Queue does not exists'
    PRINT 'creating table Queue'
    Create table Queue 
    (
        person_id int, 
        person_name varchar(30), 
        weight int, 
        turn int
    )
end

Truncate table [Queue];
GO
insert into [Queue] (person_id, person_name, weight, turn) 
values 
      ('5', 'Alice'     , '250', '1')
    , ('4', 'Bob'       , '175', '5')
    , ('3', 'Alex'      , '350', '2')
    , ('6', 'John Cena' , '400', '3')
    , ('1', 'Winston'   , '500', '6')
    , ('2', 'Marie'     , '200', '4')
;
GO

select * from [Queue]
order by turn
;
GO
/*
    ############################################################
    #   START EXERCISE
    ############################################################
*/
WITH totals                             -- need CTE to create running_weight alias to reference later
AS (
    SELECT
        person_name
        , weight
        , turn
        , SUM(weight) 
            OVER
            (
                ORDER BY turn           -- compute running weight in turn order
            ) 
            AS running_weight           -- create the running weight column
    FROM [Queue]
    -- WHERE total_weight <= 1000       -- cannot reference alias in the where clause
)
SELECT TOP 1                            -- get the first in descending order
    *                                   -- return all columns
FROM totals                             -- reference CTE
WHERE running_weight <= 1000            -- exclude running weight > 1000 using windows function alias
ORDER BY turn DESC                      -- ensure we got the last as first value
;

