SELECT
    FORMAT (GETDATE (), 'yyyy-MM-dd HH:mm:ss') AS today,
    FORMAT (DATEADD (DAY, - (DATEPART (WEEKDAY, GETDATE ()) + 5), GETDATE ()), 'yyyy-MM-dd') AS firstDay,
    FORMAT(DATEADD(DAY, - (DATEPART (WEEKDAY, GETDATE ()) + 26), GETDATE ()), 'yyyy-MM-dd') as first_day_of_the_last_four_weeks,
    FORMAT (DATEADD (DAY, 1 - DATEPART (WEEKDAY, GETDATE ()), GETDATE ()), 'yyyy-MM-dd') AS lastDay,
    MAX(d.weekly_start_monday_period) AS week_name
FROM
    derived.dim_date d;