-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- IMPORTANT: To run this in SSMS, you MUST enable "SQLCMD Mode"
-- Go to the Menu bar: Query -> SQLCMD Mode
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE [sample];
GO

PRINT '[MAIN] Starting main script...';

-- The :r command parses the file and injects its content here.
-- Note: It usually requires the full path.
:r 0f-include-me.sql

PRINT '[MAIN] Back in main script.';
GO