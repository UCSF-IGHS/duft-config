SELECT
 	TOP 1
    FORMAT (GETDATE (), 'yyyy-MM-dd HH:mm:ss') AS todayTime,
    FORMAT (GETDATE (), 'yyyy-MM-dd') AS today,
    FORMAT(created_datetime, 'yyyy-MM-dd HH:mm:ss') as lastUpdated
FROM
    todays_lab_analysis 
ORDER BY created_datetime;