CREATE PROCEDURE USP_TRUNCATE_TABLE
(
  @TABLENAME NVARCHAR(100),
  @ISDEBUG BIT = 0,
  @SCHEMA_OWNER NVARCHAR(20) = NULL 
)
WITH EXECUTE AS OWNER
/*******************************************************************************************
* PURPOSE : Replace TRUNCATE TABLE Statement without DDL Admin permission within current DB
* Procedure : USP_TRUNCATE_TABLE 
********************************************************************************************/
AS 
BEGIN
    SET NOCOUNT ON
    
    DECLARE @objectName VARCHAR(80)
           ,@errNumber INT
           ,@errMessage VARCHAR(4000)
           ,@sDBName VARCHAR(100)
           ,@SQLSTRING NVARCHAR(600)
           ,@fullTableName NVARCHAR(200)
    
    BEGIN TRY 
           SET @sDBName = DB_NAME();
           SELECT @objectName = @sDBName + 'dbo.' + OBJECT_NAME(@@ProcID);
           SET @errNumber = 0;
           SET @errMessage = '';
           
           IF @SCHEMA_OWNER IS NULL
               SET @fullTableName = N'DBO.' + @TABLENAME ;
           ELSE 
               SET @fullTableName = @SCHEMA_OWNER + '.' + @TABLENAME ;
               
           PRINT 'BEFORE TRUNCATE TABLE : ' + @fullTableName ;
           
           SET @SQLSTRING = N'TRUNCATE TABLE ' + @fullTableName ; 
           
           IF NOT EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(@fullTableName) AND TYPE IN(N'U'))
           BEGIN
               SET @errMessage = 'Invalid table object : ' + @fullTableName;
               RAISEERROR(@errMessage, 16, 1);
           END
           
           IF @ISDEBUG = 1
           BEGIN
               PRINT @SQLSTRING;
           END
           ELSE 
           BEGIN
               EXEC SP_EXECUTESQL @SQLSTRING;
           END
           
           PRINT 'AFTER TRUNCATE TABLE : ' + @fullTableName
     END TRY
     
     BEGIN CATCH --In case of errors
                                                                                                            
         SELECT @errNumber = ERROR_NUMBER()
               ,@errMessage = ISNULL(ERROR_MESSAGE(), 'ERRORS : ') + ' ERROR LINE NUMBER : ' + CAST(ERROR_LINE() AS VARCHAR(20)) + ' ERROR NUMBER : ' + CAST(@ERRnUMBER AS VARCHAR(12))
               
         PRINT ' ERROR OCCURED IN SP : ' + @objectName + ' WITH ERROR : + @errMessage
         
         RAISEERROR(@errMessage, 16, 1)
         
     END CATCH
     
     RETURN @errNumber
END
GO

           
           
