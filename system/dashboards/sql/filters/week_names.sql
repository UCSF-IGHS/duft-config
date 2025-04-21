SELECT 
    weekly_start_monday_period + ': ' + 
    FORMAT(CAST(LEFT(weekly_start_monday_day_dates, CHARINDEX('-', weekly_start_monday_day_dates) - 2) AS DATE), 'MMM dd yyyy') + 
    ' - ' + 
    FORMAT(CAST(RIGHT(weekly_start_monday_day_dates, LEN(weekly_start_monday_day_dates) - CHARINDEX('-', weekly_start_monday_day_dates) - 1) AS DATE), 'MMM dd yyyy') 
    AS label,
    weekly_start_monday_period as value
FROM 
    derived.dim_date
GROUP BY 
    weekly_start_monday_period, 
    weekly_start_monday_day_dates
ORDER BY 
    MIN(CAST(LEFT(weekly_start_monday_day_dates, CHARINDEX('-', weekly_start_monday_day_dates) - 2) AS DATE)) DESC;
