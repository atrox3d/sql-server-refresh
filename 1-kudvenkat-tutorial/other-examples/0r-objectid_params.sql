use [sample];
GO
/*
type    type_desc
---     ------------------
AF      AGGREGATE_FUNCTION
FN	    SQL_SCALAR_FUNCTION
FS	    CLR_SCALAR_FUNCTION
IF	    SQL_INLINE_TABLE_VALUED_FUNCTION
IT	    INTERNAL_TABLE
P 	    SQL_STORED_PROCEDURE
PC	    CLR_STORED_PROCEDURE
S 	    SYSTEM_TABLE
SQ	    SERVICE_QUEUE
TF	    SQL_TABLE_VALUED_FUNCTION
U 	    USER_TABLE
V 	    VIEW
X 	    EXTENDED_STORED_PROCEDURE
C 	    CHECK_CONSTRAINT
D 	    DEFAULT_CONSTRAINT
F 	    FOREIGN_KEY_CONSTRAINT
PK	    PRIMARY_KEY_CONSTRAINT*/

IF OBJECT_ID('dbo.ObjectTypes', 'U') IS NOT NULL
    DROP TABLE dbo.ObjectTypes;
GO

;WITH ObjectTypes AS (
    SELECT DISTINCT type, type_desc FROM sys.all_objects
    UNION
    SELECT DISTINCT type, type_desc FROM sys.objects WHERE type IN ('F', 'PK', 'C', 'D')
)
SELECT type, type_desc
INTO dbo.ObjectTypes
FROM ObjectTypes
ORDER BY type;
GO

select * from dbo.ObjectTypes;
GO
