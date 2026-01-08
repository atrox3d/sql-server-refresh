-- create db if it not exists already
IF DB_ID('sample') IS NULL
	CREATE DATABASE sample;

-- check if there is a db 'sample'
SELECT name, database_id, create_date
FROM sys.databases
WHERE name = 'sample'
;

-- rename sample to sample2 with commands
ALTER DATABASE sample MODIFY NAME = sample2;

-- rename back sample using stored procedure
EXECUTE sp_renamedb 'sample2', 'sample';

DROP DATABASE sample;
