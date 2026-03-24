use [sample];
GO

CREATE OR ALTER PROCEDURE dbo.spLog
    @Level NVARCHAR(10),    -- failing to specify size defaults to 1 !!!
    @Message NVARCHAR(MAX)
AS
BEGIN
    SELECT
        GETDATE() as [Timestamp],
        @Level as [Level], 
        @Message as [Message];

    DECLARE @Msg NVARCHAR(MAX) = FORMATMESSAGE('%s | %s | %s', 
        CONVERT(NVARCHAR, GETDATE(), 120), -- Style 120 is the "Golden Standard"        UPPER(@Level), 
        @Message
    );
    PRINT @Msg;
END
GO

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

EXEC dbo.spLog @Level='INFO', @Message='hello'
EXEC dbo.spInfo @Message='hello'
EXEC dbo.spWarn @Message='hello'
EXEC dbo.spError @Message='hello'
GO
