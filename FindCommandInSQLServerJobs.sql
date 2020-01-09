SELECT
  J.name,
  J.description,
  JS.step_name,
  JS.database_name,
  JS.command
  --J.*, /*Commented out, can be used if required */
  --JS.* /*Commented out, can be used if required */
FROM MSDB.DBO.SYSJOBS AS J
INNER JOIN MSDB.DBO.SYSJOBSTEPS AS JS
ON J.JOB_ID = JS.JOB_ID 
WHERE JS.COMMAND LIKE '%<ENTER STRING HERE TO FIND IT IN SQL JOB STEPS>%'
