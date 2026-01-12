-- get sql server version:
-- Microsoft SQL server 2022 ...
-- double @ is for system functions or global variables
select @@version as version;

-- global variables examples
select @@ROWCOUNT as rows_affected;

select @@SERVERNAME as server_name;

select @@SERVICENAME as service_name;

select @@ERROR;