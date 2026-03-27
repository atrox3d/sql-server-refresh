-- create sp for logging

use [sample];
GO

SELECT DB_NAME() AS db_name;
GO

/*
IF OBJECT_ID('spLog', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.spLog
    PRINT 'dbo.spLog DELETED'
END
IF OBJECT_ID('spInfo', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.spInfo
    PRINT 'dbo.spInfo DELETED'
END
IF OBJECT_ID('spWarn', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.spWarn
    PRINT 'dbo.spWarn DELETED'
END
IF OBJECT_ID('spError', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.spError
    PRINT 'dbo.spError DELETED'
END
*/
DROP PROCEDURE IF EXISTS 
        dbo.spLog, 
        dbo.spInfo, 
        dbo.spWarn, 
        dbo.spError,
        dbo.spCreate_table_log,
        dbo.spFlush;
PRINT 'Cleanup complete.';
GO

CREATE OR ALTER PROCEDURE dbo.spCreate_table_log
    @DropIfExists BIT = 0
AS
BEGIN
    IF @DropIfExists = 1
    BEGIN
        DROP TABLE IF EXISTS dbo.tblLog;
        EXEC dbo.spInfo 'DELETED dbo.tblLog'
    END
    
    IF OBJECT_ID('dbo.tblLog', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.tblLog (
            -- TimeStamp DATETIME DEFAULT CONVERT(NVARCHAR, GETDATE(), 120),
            TimeStamp DATETIME DEFAULT GETDATE(),
            Level NVARCHAR(10),
            Message NVARCHAR(MAX),
            isDisplayed BIT DEFAULT 0
        )
        EXEC dbo.spInfo 'CREATED dbo.tblLog'
    END
END
GO
-- create tblLog

-- spLog - base sp for logging

-- EXEC dbo.spCreate_table_log;
-- SELECT * FROM dbo.tblLog;

CREATE OR ALTER PROCEDURE dbo.spFLush
AS
BEGIN
    EXEC dbo.spCreate_table_log;    
    SELECT
        [Timestamp]
        , [Level]
        , [Message]
        -- [isDisplayed]
    FROM tblLog
    WHERE isDisplayed = 0;

    UPDATE dbo.tblLog
    SET [isDisplayed] = 1
    WHERE [isDisplayed] = 0;
END
GO
CREATE OR ALTER PROCEDURE dbo.spLog
    @Level NVARCHAR(10),    -- failing to specify size defaults to 1 !!!
    @Message NVARCHAR(MAX),
    @Flush BIT = 0
AS
BEGIN
    EXEC dbo.spCreate_table_log;    
    INSERT INTO dbo.tblLog
    (Level, Message)
    SELECT
        -- GETDATE() as [Timestamp],
        @Level as [Level], 
        @Message as [Message];

    IF @Flush = 1
        EXEC dbo.spFlush

    DECLARE @Date NVARCHAR(20) = CONVERT(NVARCHAR, GETDATE(), 120) -- Style 120 is the "Golden Standard"
    SET @Level = UPPER(@Level)
    -- PRINT '@Date: ' + @Date;
    -- PRINT '@Level: ' + @Level;
    DECLARE @Msg NVARCHAR(MAX) = FORMATMESSAGE('%s | %s | %s', 
        @Date,
        @Level, 
        @Message
    );
    PRINT @Msg;
END
GO


EXEC dbo.spLog 'INFO', 'hello';
EXEC dbo.spLog 'INFO', 'hi', 1;
GO
-- # ## add info, warning, error helpers

CREATE OR ALTER PROCEDURE dbo.spInfo
    @Message NVARCHAR(MAX)
AS
BEGIN
    EXEC dbo.spLog 'INFO', @Message;
END
GO


CREATE OR ALTER PROCEDURE dbo.spWarn
    @Message NVARCHAR(MAX)
AS
BEGIN
    EXEC dbo.spLog 'WARN', @Message;
END
GO


CREATE OR ALTER PROCEDURE dbo.spError
    @Message NVARCHAR(MAX)
AS
BEGIN
    DECLARE @ErrorMsg NVARCHAR(MAX) = ''
    -- SELECT ERROR_NUMBER(), ERROR_MESSAGE();
    IF ERROR_MESSAGE() IS NOT NULL
        SET @ErrorMsg = FORMATMESSAGE('%s: %i - %s', 
            @Message, 
            ERROR_NUMBER(), 
            ERROR_MESSAGE()
        );
    ELSE
        SET @ErrorMsg = @Message;
    

    EXEC dbo.spLog 'ERROR', @ErrorMsg;
END
GO


-- # ## test sps

SELECT DB_NAME() AS db_name;
GO

PRINT 'start'
EXEC dbo.spLog @Level='INFO', @Message='hello'
EXEC dbo.spInfo @Message='hello'
EXEC dbo.spWarn @Message='hello'
EXEC dbo.spError @Message='hello'
PRINT 'end'
GO



