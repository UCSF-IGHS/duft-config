SELECT
    FORMAT (GETDATE (), 'yyyy-MM-dd HH:mm:ss') AS today,
    FORMAT (DATEADD(DAY, -7, CAST(GETDATE() AS DATE)), 'yyyy-MM-dd') AS firstDay,
    FORMAT(DATEADD(DAY, -27, DATEADD(DAY, -1, GETDATE())), 'yyyy-MM-dd') AS first_day_of_the_last_four_weeks,
    FORMAT (DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), 'yyyy-MM-dd') AS lastDay,
    MAX(
        CASE DATENAME(WEEKDAY, DATEADD(DAY, -7, CAST(GETDATE() AS DATE)))
            WHEN 'Monday' THEN d.weekly_start_monday_period
            WHEN 'Tuesday' THEN d.weekly_start_tuesday_period
            WHEN 'Wednesday' THEN d.weekly_start_wednesday_period
            WHEN 'Thursday' THEN d.weekly_start_thursday_period
            WHEN 'Friday' THEN d.weekly_start_friday_period
            WHEN 'Saturday' THEN d.weekly_start_saturday_period
            WHEN 'Sunday' THEN d.weekly_start_sunday_period
        END) AS week_name
FROM
    derived.dim_date d;