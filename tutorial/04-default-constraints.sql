USE [sample];
GO
/*
    Best Practice: Stop "rows affected" noise
*/
SET NOCOUNT ON;

SELECT DB_NAME() AS db_name;
PRINT 'INFO | Initial Database Context: ' + DB_NAME();
GO
/*
************************************************************************************
    prepare data
************************************************************************************
*/
DELETE FROM sample.dbo.tblPerson;
-- GO
TRUNCATE TABLE sample.dbo.tblPerson;
-- GO

INSERT INTO sample.dbo.tblPerson
VALUES 
    (1, 'john',  'j@j.com',      1),
    (2, 'mary',  'm@m.com',      2),
    (3, 'simon', 's@s.com',      1),
    (4, 'sam',   'sam@sam.com',  1),
    (5, 'may',   'may@may.com',  1),
    (6, 'kerry', 'k@k.com',      3)
;

SELECT * FROM sample.dbo.tblPerson;
GO
/*
************************************************************************************
    Drop constraint if it exists to ensure deterministic behavior (start fresh)
************************************************************************************
*/
IF OBJECT_ID('sample.dbo.DF_tblPerson_GenderId', 'D') IS NOT NULL
    BEGIN
        ALTER TABLE sample.dbo.tblPerson DROP CONSTRAINT DF_tblPerson_GenderId;
        PRINT 'INFO | Default constraint DF_tblPerson_GenderId dropped.';
    END
GO
/*
************************************************************************************
    skip genderid during insert
    without constraint genderid will be null by default
************************************************************************************
*/
INSERT INTO sample.dbo.tblPerson
(ID, Name, Email)
VALUES (7, 'rich',  'r@r.com');             -- genderid is null by default, no default constraint yet

SELECT 
        *,
        'default genderid w/o constraint is NULL' as NOTE
FROM sample.dbo.tblPerson
WHERE ID = 7
;
GO
/*
************************************************************************************
    create default constraint if it doesnt exist
    when tblPerson.genderID is not specified the default is 3 (Unknown)
************************************************************************************
*/
IF OBJECT_ID('sample.dbo.DF_tblPerson_GenderId', 'D') IS NULL
    BEGIN
        -- add default constraint for genderid
        ALTER TABLE sample.dbo.tblPerson
        ADD CONSTRAINT DF_tblPerson_GenderId
        DEFAULT 3 FOR GenderId;
        PRINT 'INFO | Default constraint DF_tblPerson_GenderId added.';
    END
ELSE
    BEGIN
        PRINT 'INFO | Default constraint DF_tblPerson_GenderId already exists.'
    END
GO

/*
************************************************************************************
    skip genderid during insert
    with constraint genderid will be 3 by default
************************************************************************************
*/
INSERT INTO sample.dbo.tblPerson
(ID, Name, Email)
VALUES (8, 'mike',  'mike@r.com');          -- genderid is null by default. default applied

SELECT 
        *,
        'default genderid w/ constraint is 3' as NOTE
FROM sample.dbo.tblPerson
WHERE ID = 8;
GO

-- retry add null gender row intentionally
INSERT INTO sample.dbo.tblPerson
(ID, Name, Email, GenderId)
VALUES (9, 'Johnny',  'j@r.com', NULL);     -- genderid is null intentionally, no default applied
SELECT 
        *,
        'intentionally set genderID to NULL' as NOTE
FROM sample.dbo.tblPerson
WHERE ID = 9;
GO
