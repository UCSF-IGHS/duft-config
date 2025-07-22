SELECT
    FORMAT (GETDATE (), 'yyyy-MM-dd HH:mm:ss') AS today,
    FORMAT (DATEADD (DAY, - (DATEPART (WEEKDAY, GETDATE ()) + 5), GETDATE ()), 'yyyy-MM-dd') AS firstDay,
    FORMAT (DATEADD (DAY, 1 - DATEPART (WEEKDAY, GETDATE ()), GETDATE ()), 'yyyy-MM-dd') AS lastDay,
    MAX(d.weekly_start_monday_period) AS week_name
FROM
    derived.dim_date d
WHERE
    d.date BETWEEN DATEADD (DAY, - (DATEPART (WEEKDAY, GETDATE ()) + 27), GETDATE ()) 
    AND DATEADD (DAY, 1 - DATEPART (WEEKDAY, GETDATE ()), GETDATE ());