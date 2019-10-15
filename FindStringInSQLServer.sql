SET NOCOUNT ON ;

BEGIN TRY DROP TABLE #DATABASES END TRY BEGIN CATCH END CATCH
BEGIN TRY DROP TABLE #Dependencies END TRY BEGIN CATCH END CATCH

CREATE TABLE #DATABASES (
    database_ID int,
    database_name VARCHAR(100)
);

INSERT INTO #DATABASES (database_ID, database_name)
SELECT database_ID, name from sys.databases
where database_id IN (1,2,3,4) /* Update the where condition to look for a specific database or remove the where clause to search in whole DB server */

DECLARE
    @database_id int,
    @database_name sysname,
    @sql varchar(max);

CREATE TABLE #dependencies(
    referencing_database varchar(max),
    referencing_object_name varchar(max),
    referencing_object_type varchar(max),
);

WHILE (SELECT COUNT(*) FROM #databases) > 0 
BEGIN
    SELECT TOP 1 
        @database_id = database_ID,
        @database_name= database_name
    FROM #databases;

    SET @SQL = 'INSERT INTO #dependencies select DB_NAME(' +
                CONVERT(varchar, @database_id) +
                '), name, type_desc FROM '+
                quotename(@database_name) +
                '.sys.objects P inner join '+
                quotename(@database_name) +
                '.sys.syscomments C ON O.object_Id = C.id where c.ctext like ''%Business_date%'' OR C.text like ''%Business_date%''';
    
    EXEC (@SQL);
    DELETE FROM #databases WHERE database_id = @database_id;
END;

SET NOCOUNT OFF

SELECT 
    DISTINCT 
        referencing_database, 
        referencing_object_name, 
        referencing_object_type 
FROM #dependencies
WHERE referencing_object_name<> 'sp_help'; /* update or remove the where clause as per the requirement */

DROP TABLE #databases;
DROP TABLE #dependencies;

