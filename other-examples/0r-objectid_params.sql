/*
    get all available params for OBJECT_ID() function
*/
SELECT DISTINCT type, type_desc 
FROM sys.all_objects  -- 'all_objects' includes system-level definitions
ORDER BY type;
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
*/
