USE lab_visual_analysis
GO
PRINT 'clearing all stored procedures in dbo'
EXEC dbo.sp_xf_system_drop_all_stored_procedures_in_schema 'dbo' 
GO

        
-----------------------------------------------------------------------------------------------
-- sp_xf_system_drop_all_stored_procedures_in_schema
--

PRINT 'Creating dbo.sp_xf_system_drop_all_stored_procedures_in_schema'
GO


CREATE OR ALTER PROCEDURE dbo.sp_xf_system_drop_all_stored_procedures_in_schema(@schema AS NVARCHAR(255)) AS
BEGIN

    DECLARE @SQL NVARCHAR ( MAX );

    SET @SQL = N'';
    SELECT
        @SQL = @SQL + N'
    DROP PROCEDURE [' + @schema + '].[' + RTRIM(c.name) +']; '
    FROM
        sys.objects AS c
    WHERE
        c.[type] = 'P'
        AND SCHEMA_NAME(c.schema_id) = @schema
    ORDER BY
        c.[type];

    EXEC(@SQL)
    PRINT 'Dropped all stored procedures in schema: ' + @schema

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_xf_system_drop_all_foreign_keys_in_schema
--

PRINT 'Creating dbo.sp_xf_system_drop_all_foreign_keys_in_schema'
GO


CREATE OR ALTER PROCEDURE dbo.sp_xf_system_drop_all_foreign_keys_in_schema(@schema AS NVARCHAR(255)) AS
BEGIN

    DECLARE @SQL NVARCHAR ( MAX );

    SET @SQL = N'';
    SELECT
        @SQL = @SQL + N'
    ALTER TABLE ' + @schema + '.' + QUOTENAME( t.name ) + ' DROP CONSTRAINT ' + QUOTENAME( c.name ) + ';' 
    FROM
        sys.objects AS c
        INNER JOIN sys.tables AS t ON c.parent_object_id = t.[object_id]
        INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id] 
    WHERE
        c.[type] ='F'
        AND SCHEMA_NAME(t.schema_id) = @schema
    ORDER BY
    c.[type];

    EXEC(@SQL)
    PRINT @SQL
    PRINT N'Dropped all FKs in schema: ' + @schema

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_xf_system_drop_all_primary_keys_in_schema
--

PRINT 'Creating dbo.sp_xf_system_drop_all_primary_keys_in_schema'
GO


CREATE OR ALTER PROCEDURE dbo.sp_xf_system_drop_all_primary_keys_in_schema(@schema AS NVARCHAR(255)) AS
BEGIN

    DECLARE @SQL NVARCHAR ( MAX );

    SET @SQL = N'';
    SELECT
        @SQL = @SQL + N'
    ALTER TABLE ' + @schema + '.' + QUOTENAME( t.name ) + ' DROP CONSTRAINT ' + QUOTENAME( c.name ) + ';' 
    FROM
        sys.objects AS c
        INNER JOIN sys.tables AS t ON c.parent_object_id = t.[object_id]
        INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id] 
    WHERE
        c.[type] ='PK'
        AND SCHEMA_NAME(t.schema_id) = @schema
    ORDER BY
        c.[type];

    EXEC(@SQL)
    PRINT @SQL
    PRINT N'Dropped PKs in schema: ' + @schema

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_xf_system_drop_all_functions_in_schema
--

PRINT 'Creating dbo.sp_xf_system_drop_all_functions_in_schema'
GO


CREATE OR ALTER PROCEDURE dbo.sp_xf_system_drop_all_functions_in_schema(@schema AS NVARCHAR(255)) AS
BEGIN

    DECLARE @SQL NVARCHAR ( MAX );

    SET @SQL = N'';
    SELECT
        @SQL = @SQL + N'
    DROP FUNCTION [' + @schema + '].[' + RTRIM(c.name) +']; '
    FROM
        sys.objects AS c
    WHERE
        c.[type] IN ('FN', 'IF', 'FN', 'AF', 'FS', 'FT')
        AND SCHEMA_NAME(c.schema_id) = @schema
    ORDER BY
        c.[type];

    EXEC(@SQL)
    PRINT 'Dropped functions in schema: ' + @schema

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_xf_system_drop_all_views_in_schema
--

PRINT 'Creating dbo.sp_xf_system_drop_all_views_in_schema'
GO


CREATE OR ALTER PROCEDURE dbo.sp_xf_system_drop_all_views_in_schema(@schema AS NVARCHAR(255)) AS
BEGIN

    DECLARE @name VARCHAR(128)
    DECLARE @SQL VARCHAR(254)

    SELECT @name = (SELECT TOP 1 [name] FROM sys.objects WHERE [type] = 'V' AND SCHEMA_NAME(schema_id) = @schema ORDER BY [name])

    WHILE @name IS NOT NULL
    BEGIN
        SELECT @SQL = 'DROP VIEW [' + @schema + '].[' + RTRIM(@name) +']'
        EXEC (@SQL)
        PRINT 'Dropped view: ' + @name
        SELECT @name = (SELECT TOP 1 [name] FROM sys.objects WHERE [type] = 'V' AND SCHEMA_NAME(schema_id) = @schema AND [name] > @name ORDER BY [name])
    END

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_xf_system_drop_all_tables_in_schema
--

PRINT 'Creating dbo.sp_xf_system_drop_all_tables_in_schema'
GO


CREATE OR ALTER PROCEDURE dbo.sp_xf_system_drop_all_tables_in_schema(@schema AS NVARCHAR(255)) AS
BEGIN

    DECLARE @name VARCHAR(128)
    DECLARE @SQL NVARCHAR ( MAX );

    SELECT @name = (SELECT TOP 1 [name] FROM sys.objects WHERE [type] = 'U' AND SCHEMA_NAME(schema_id) = @schema ORDER BY [name])

    WHILE @name IS NOT NULL
    BEGIN
        SELECT @SQL = 'DROP TABLE [' + @schema + '].[' + RTRIM(@name) +']'
        EXEC (@SQL)
        PRINT 'Dropped table: ' + @name
        SELECT @name = (SELECT TOP 1 [name] FROM sys.objects WHERE [type] = 'U' AND SCHEMA_NAME(schema_id) = @schema AND [name] > @name ORDER BY [name])
    END

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_xf_system_drop_all_objects_in_schema
--

PRINT 'Creating dbo.sp_xf_system_drop_all_objects_in_schema'
GO


CREATE OR ALTER PROCEDURE dbo.sp_xf_system_drop_all_objects_in_schema(@schema AS VARCHAR(255)) AS
BEGIN

    EXEC dbo.sp_xf_system_drop_all_views_in_schema @schema;
    EXEC dbo.sp_xf_system_drop_all_functions_in_schema @schema;
    EXEC dbo.sp_xf_system_drop_all_foreign_keys_in_schema @schema;
    EXEC dbo.sp_xf_system_drop_all_primary_keys_in_schema @schema;
    EXEC dbo.sp_xf_system_drop_all_tables_in_schema @schema;
    EXEC dbo.sp_xf_system_drop_all_stored_procedures_in_schema @schema;

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_xf_system_calculate_weekly_number_by_day
--

PRINT 'Creating dbo.sp_xf_system_calculate_weekly_number_by_day'
GO

CREATE PROCEDURE dbo.sp_xf_system_calculate_weekly_number_by_day(
	@date AS DATE,
    @start_day_number INT,
    @week_start_date AS DATE,
    @week_end_date AS DATE,
    @week_number AS INT,
    @year_number AS INT,
    @weekly_start_period VARCHAR(255) OUTPUT,
    @weekly_start_day_dates VARCHAR(255) OUTPUT,
    @week_number_output AS INT OUTPUT,
    @year_number_output AS INT OUTPUT,
    @week_end_date_output AS DATE OUTPUT
    ) AS
BEGIN

 	DECLARE @actual_year_number INT;
 	DECLARE @start_year_number INT;
    DECLARE @end_year_number INT;
    DECLARE @year_start_date DATE;
    DECLARE @year_end_date DATE;
    DECLARE @start_date DATE;
    DECLARE @end_date DATE;
    DECLARE @day_of_the_week INT;
    DECLARE @start_date_offset INT;
    DECLARE @end_date_offset INT;
    DECLARE @start_date_string VARCHAR(255);
    DECLARE @end_date_string VARCHAR(255);
	SET DATEFIRST @start_day_number;
	SET @day_of_the_week =DATEPART(WEEKDAY, @date) ;
	SET @start_date_offset = @day_of_the_week - 1;
	SET @end_date_offset = 7 - @day_of_the_week;
	SET @week_start_date = DATEADD(DAY, -@start_date_offset, @date);
	
	IF (@date > @week_end_date )
	BEGIN
		SET @week_start_date = @date;
		SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
		SET @week_number = @week_number + 1;
		SET @actual_year_number= UPPER(FORMAT(@week_start_date,'yy'));
		IF (@actual_year_number > @year_number)
			BEGIN
				SET @week_number = 1;
				SET @year_number_output = @actual_year_number;
				SET @year_number = @actual_year_number;
			END
	END
	
	SET @week_end_date = DATEADD(DAY, @end_date_offset, @date);
	SET @start_date_string = CONCAT(CONCAT(FORMAT(@week_start_date, 'MMM dd'),', '), @year_number);
    SET @end_year_number = UPPER(FORMAT(@week_end_date,'yy'))
	SET @end_date_string = CONCAT(CONCAT(FORMAT(@week_end_date, 'MMM dd'),', '), @end_year_number);
    SELECT @week_number_output = @week_number;
    SELECT @week_end_date_output = @week_end_date;
    SELECT @year_number_output = @year_number_output;
    SELECT @weekly_start_period = CONCAT('W',CONCAT(FORMAT(@week_number, '00'),CONCAT('Y', @year_number)));
	SELECT @weekly_start_day_dates = CONCAT(CONCAT(@start_date_string,' - '), @end_date_string);

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_etl_tracking_create
--

PRINT 'Creating dbo.sp_etl_tracking_create'
GO

CREATE OR ALTER PROCEDURE dbo.sp_etl_tracking_create AS
BEGIN

    DROP TABLE IF EXISTS dbo.etl_tracking;

    CREATE TABLE dbo.etl_tracking(
        [id] INT NOT NULL IDENTITY PRIMARY KEY,
        sp_name NVARCHAR(255) NOT NULL,
        start_time DATETIME NULL,
        end_time DATETIME NULL,
        [status] NVARCHAR(255) NULL
    );

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_etl_tracking_insert_start_of_sp_execution
--

PRINT 'Creating dbo.sp_etl_tracking_insert_start_of_sp_execution'
GO

CREATE OR ALTER PROCEDURE dbo.sp_etl_tracking_insert_start_of_sp_execution(@sp_name AS NVARCHAR(255)) AS
BEGIN

IF (EXISTS (SELECT *
   FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_SCHEMA = 'dbo'
   AND TABLE_NAME = 'etl_tracking'))
   BEGIN

        INSERT INTO dbo.etl_tracking (
            sp_name,
            start_time,
            end_time,
            [status]
        )
        VALUES (
            @sp_name,
            GETDATE(),
            NULL,
            'STARTED'
        )    

   END;
ELSE
   BEGIN
      PRINT 'Tracking table does not exist'
   END;

END

GO
        

-----------------------------------------------------------------------------------------------
-- sp_etl_tracking_update_end_of_sp_execution
--

PRINT 'Creating dbo.sp_etl_tracking_update_end_of_sp_execution'
GO

CREATE OR ALTER PROCEDURE dbo.sp_etl_tracking_update_end_of_sp_execution(@sp_name AS NVARCHAR(255)) AS
BEGIN

    UPDATE dbo.etl_tracking SET 
        [status] = 'COMPLETED',
        end_time = GETDATE()
    WHERE
        sp_name = @sp_name;

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_age
--

PRINT 'Creating dbo.fn_calculate_age'
GO


CREATE OR ALTER FUNCTION dbo.fn_staging_calculate_age(@earliest_date AS DATE, @latest_date AS DATE)
RETURNS INT
AS
BEGIN

	DECLARE @age INT
	DECLARE @earliest_date_as_yyyyddmm INT
	DECLARE @latest_date_as_yyyyddmm INT
	DECLARE @yyyyddmm_formatting_code INT = 112
	DECLARE @coefficient_for_converting_to_years INT = 10000

	SET @earliest_date_as_yyyyddmm = CONVERT ( CHAR(8), @earliest_date, @yyyyddmm_formatting_code)
	SET @latest_date_as_yyyyddmm = CONVERT ( CHAR(8), @latest_date, @yyyyddmm_formatting_code)
	
	SET @age = (@latest_date_as_yyyyddmm - @earliest_date_as_yyyyddmm) / @coefficient_for_converting_to_years
	
	RETURN @age

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_annual_period
--

PRINT 'Creating dbo.fn_calculate_annual_period'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_annual_period(@date AS DATE, @fyType AS VARCHAR(50))
RETURNS VARCHAR(50)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @year_number INT
	DECLARE @month_number INT
	DECLARE @year_start_month INT
	DECLARE @annual_period VARCHAR(50)

	SET @year_number = UPPER(FORMAT(@date,'yy'))
	SET @month_number = MONTH(@date)
	
	SET @year_start_month = CASE @fyType
		WHEN 'calender' THEN 1
		WHEN 'gov' THEN 7
		WHEN 'pepfar' THEN 10
	END

	IF @year_start_month = 1 
		BEGIN
			SET @year_number = @year_number
		END
	ELSE IF @month_number >= @year_start_month
		BEGIN
			SET @year_number = @year_number + 1
		END

	SET @annual_period = CONCAT('FY', @year_number)
	
	RETURN @annual_period

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_day_name
--

PRINT 'Creating dbo.fn_calculate_day_name'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_day_name(@date AS DATE)
RETURNS VARCHAR(50)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @day_name VARCHAR(50)

	SET @day_name = FORMAT(@date, 'dddd') 
	RETURN @day_name

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_day_number
--

PRINT 'Creating dbo.fn_calculate_day_number'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_day_number(@date AS DATE)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @day_number INT

	SET @day_number = DATEPART(dayofyear, @date)
	RETURN @day_number

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_month_number
--

PRINT 'Creating dbo.fn_calculate_month_number'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_month_number(@date AS DATE)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @month_number INT

	SET @month_number = MONTH(@date)

	
	RETURN @month_number

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_month_period
--

PRINT 'Creating dbo.fn_calculate_month_period'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_month_period(@date AS DATE)
RETURNS VARCHAR(50)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @year_number INT
	DECLARE @month_number INT
	DECLARE @quarter_number INT
	DECLARE @month_period VARCHAR(50)

	SET @month_period = UPPER(FORMAT(@date, 'MMM', 'en-US'))
	SET @year_number = UPPER(FORMAT(@date,'yy'))
	
	SET @month_period = CONCAT(@month_period, @year_number)
	
	RETURN @month_period

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_months_between_dates
--

PRINT 'Creating dbo.fn_calculate_months_between_dates'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_months_between_dates(@earliest_date AS DATE, @latest_date AS DATE)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @average_days_in_a_month FLOAT = 30.436875E
	DECLARE @total_days INT
	DECLARE @months INT

	SET @total_days = DATEDIFF(DAY, @earliest_date, @latest_date)
	SET @months = @total_days / @average_days_in_a_month
	
	RETURN @months

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_quarter_period
--

PRINT 'Creating dbo.fn_calculate_quarter_period'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_quarter_period(@date AS DATE, @fyType AS VARCHAR(50))
RETURNS VARCHAR(50)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @year_number INT
	DECLARE @month_number INT
	DECLARE @year_start_month INT
	DECLARE @quarter_number INT
	DECLARE @quarter_diff_num INT
	DECLARE @quarter_period VARCHAR(50)

	SET @month_number = MONTH(@date)
	SET @year_number = UPPER(FORMAT(@date,'yy'))
	SET @year_start_month = CASE @fyType
		WHEN 'calender' THEN 1
		WHEN 'gov' THEN 7
		WHEN 'pepfar' THEN 10
	END
	SET @quarter_diff_num = CASE @fyType
		WHEN 'calender' THEN 0
		WHEN 'gov' THEN -6
		WHEN 'pepfar' THEN -9
	END
	SET @quarter_number = DATEPART(QUARTER,DATEADD(MONTH, @quarter_diff_num, @date))
	
	IF @year_start_month = 1 
		BEGIN
			SET @year_number = @year_number
		END
	ELSE IF @month_number >= @year_start_month
		BEGIN
			SET @year_number = @year_number + 1
		END
	
	SET @quarter_period = CONCAT('Q',CONCAT(@quarter_number,CONCAT('FY', @year_number)))
	
	RETURN @quarter_period

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_semi_annual_period
--

PRINT 'Creating dbo.fn_calculate_semi_annual_period'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_semi_annual_period(@date AS DATE, @fyType AS VARCHAR(50))
RETURNS VARCHAR(50)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @year_number INT
	DECLARE @month_number INT
	DECLARE @year_start_month INT
	DECLARE @semi_annual_number INT
	DECLARE @quarter_diff_num INT
	DECLARE @semi_annual_period VARCHAR(50)

	SET @month_number = MONTH(@date)
	SET @year_number = UPPER(FORMAT(@date,'yy'))
	SET @year_start_month = CASE @fyType
		WHEN 'calender' THEN 1
		WHEN 'gov' THEN 7
		WHEN 'pepfar' THEN 10
	END
	
	IF @year_start_month = 1
		BEGIN
			SET @year_number = @year_number
			SET @semi_annual_number = (DATEPART(mm, @date)-1)/6
			SET @semi_annual_number = @semi_annual_number + 1
		END
	ELSE IF @month_number >= @year_start_month
		BEGIN
			SET @year_number = @year_number + 1
			SET @semi_annual_number = 1
		END
	ELSE
		BEGIN
			SET @semi_annual_number = 2
		END
	
	SET @semi_annual_period = CONCAT('S',CONCAT(@semi_annual_number,CONCAT('FY', @year_number)))
	
	RETURN @semi_annual_period

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_years_between_dates
--

PRINT 'Creating dbo.fn_calculate_years_between_dates'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_years_between_dates(@earliest_date AS DATE, @latest_date AS DATE)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @average_days_in_a_year FLOAT = 365.25
	DECLARE @total_days INT
	DECLARE @years INT

	SET @total_days = DATEDIFF(DAY, @earliest_date, @latest_date)
	SET @years = @total_days / @average_days_in_a_year
	
	RETURN @years

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_age_group_name
--

PRINT 'Creating dbo.fn_calculate_age_group_name'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_age_group_name(@age AS INT)
RETURNS VARCHAR(255)
AS
BEGIN

	DECLARE @age_group_name VARCHAR(50)
	
	SET 
    	@age_group_name = CASE
            WHEN @age IS NULL THEN 'UNKNOWN' 
            WHEN @age < 5 THEN '0-4' 
            WHEN @age >= 5 AND  @age <= 9 THEN '5-9' 
            WHEN @age >= 10 AND @age <= 14 THEN '10-14' 
            WHEN @age >=15 AND @age <= 19 THEN '15-19' 
            WHEN @age >= 20 AND @age <=24 THEN '20-24' 
            WHEN @age >=25 THEN '25+' 
        END;
	
	RETURN @age_group_name

END

GO
        

-----------------------------------------------------------------------------------------------
-- fn_calculate_day_number_by_name
--

PRINT 'Creating dbo.fn_calculate_day_number_by_name'
GO


CREATE OR ALTER FUNCTION dbo.fn_calculate_day_number_by_name(@day_name AS VARCHAR(255))
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @day_number INT;
	SET @day_number = CASE UPPER(@day_name)
                    WHEN 'SUNDAY' THEN 7
                    WHEN 'MONDAY' THEN 1
                    WHEN 'TUESDAY' THEN 2
                    WHEN 'WEDNESDAY' THEN 3
                    WHEN 'THURSDAY' THEN 4
                    WHEN 'FRIDAY' THEN 5
                    WHEN 'SATURDAY' THEN 6
    END
	RETURN @day_number;

END;

GO
        

-----------------------------------------------------------------------------------------------
-- sp_data_processing
--

PRINT 'Creating dbo.sp_data_processing'
GO


CREATE OR ALTER PROCEDURE dbo.sp_data_processing AS
BEGIN

    EXEC sp_etl_tracking_create;
    EXEC z.sp_data_processing;
    EXEC derived.sp_data_processing;
    EXEC final.sp_data_processing;

END

GO
USE lab_visual_analysis
GO
PRINT 'clearing all stored procedures in z'
EXEC dbo.sp_xf_system_drop_all_stored_procedures_in_schema 'z' 
GO

        

-----------------------------------------------------------------------------------------------
-- z_unique_device_logs_create
--

PRINT 'Creating z.z_unique_device_logs_create'
GO

CREATE OR ALTER PROCEDURE z.z_unique_device_logs_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'z.z_unique_device_logs_create';

-- $BEGIN

        SELECT
            device_name,
            device_code,
            date_broken_down,
            date_reported,
            date_fixed,
            break_down_reason
        INTO
            z.z_unique_device_logs
        FROM
            (
                SELECT 
                    DeviceName AS device_name,
                    DeviceCode AS device_code,
                    CONVERT(DATE, DateBrokenDown) AS date_broken_down,
                    CONVERT(DATE, DateReported) AS date_reported,
                    CONVERT(DATE, DateFixed) AS date_fixed,
                    BreakdownReason AS break_down_reason,
                    ROW_NUMBER() 
                    OVER( 
                        PARTITION BY 
                            DeviceName,
                            DeviceCode,
                            CONVERT(DATE, DateBrokenDown),
                            CONVERT(DATE, DateReported),
                            CONVERT(DATE, DateFixed) 
                        ORDER BY 
                            Id DESC
                        ) 
                    AS duplicate
                FROM
                    [source].tbl_Device_Logs tdl
            ) sq
        WHERE
            duplicate = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'z.z_unique_device_logs_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- z_unique_devices_create
--

PRINT 'Creating z.z_unique_devices_create'
GO

CREATE OR ALTER PROCEDURE z.z_unique_devices_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'z.z_unique_devices_create';

-- $BEGIN
    SELECT
        DISTINCT
        DeviceCode AS device_code,
        DeviceName AS device_name,
        DeviceName AS original_device_name,
        'sample' as source
    INTO
        z.z_unique_device
    FROM
        [source].tbl_Sample
    WHERE
        LEN(ISNULL(DeviceName,'')) > 0;

    INSERT INTO
        z.z_unique_device
    (
        device_code,
        device_name,
        original_device_name,
        source
    )
    SELECT
        DISTINCT
        DeviceCode AS device_code,
        DeviceName AS device_name,
        DeviceName AS original_device_name,
        'logs' as source
    FROM
        [source].tbl_Device_Logs
    WHERE
        DeviceName NOT IN
        (
            SELECT
                original_device_name
            FROM
                z.z_unique_device
        )
        AND LEN(ISNULL(DeviceName,'')) > 0;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'z.z_unique_devices_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- z_unique_devices_update_device_name
--

PRINT 'Creating z.z_unique_devices_update_device_name'
GO

CREATE OR ALTER PROCEDURE z.z_unique_devices_update_device_name AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'z.z_unique_devices_update_device_name';

-- $BEGIN

    UPDATE
        ud
    SET
        ud.device_name = 
            CASE 
                WHEN
                    LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Cobas')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Cobas4800')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Cobas4800_53638')
                THEN
                    'Cobas 4800'
                WHEN
                    LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Cobas6800')
                THEN
                    'Cobas 6800'
                WHEN
                    LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Cobas8800')
                THEN
                    'Cobas 8800'
                WHEN
                    LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Cobas96')
                THEN
                    'Cobas 96'
                WHEN
                    LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Abbortm2000')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Abbotm2000')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Abbott')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('AbbottM2000')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('abbott_275022320')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Abbott_275022321')
                THEN
                    'Abbott m2000'
                WHEN
                    LOWER(REPLACE(original_device_name, ' ','')) = LOWER('CAP/CDTM')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('CAP/CTM')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('CAP/CTM48')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('CAP/CTM96')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('cap/ctm/96')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('Capctm')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('CAPCTM96')
                    OR LOWER(REPLACE(original_device_name, ' ','')) = LOWER('CAP/CTM9600')
                THEN
                    'CAP/CTM'
                ELSE
                    original_device_name
            END
    FROM
        z.z_unique_device ud

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'z.z_unique_devices_update_device_name';

END
GO
        

-----------------------------------------------------------------------------------------------
-- z_unique_devices
--

PRINT 'Creating z.z_unique_devices'
GO

CREATE OR ALTER PROCEDURE z.z_unique_devices AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'z.z_unique_devices';

-- $BEGIN

    EXEC z.z_unique_devices_create;
    EXEC z.z_unique_devices_update_device_name;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'z.z_unique_devices';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_data_processing
--

PRINT 'Creating z.sp_data_processing'
GO

CREATE OR ALTER PROCEDURE z.sp_data_processing AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'z.sp_data_processing';

-- $BEGIN

    PRINT 'Dropping Foreign Keys'
    EXEC dbo.sp_xf_system_drop_all_foreign_keys_in_schema 'z'

    PRINT 'Dropping tables'
    EXEC dbo.sp_xf_system_drop_all_tables_in_schema 'z'

    EXEC z.z_unique_device_logs_create;
    EXEC z.z_unique_devices;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'z.sp_data_processing';

END
GO
USE lab_visual_analysis
GO
PRINT 'clearing all stored procedures in derived'
EXEC dbo.sp_xf_system_drop_all_stored_procedures_in_schema 'derived' 
GO

        

-----------------------------------------------------------------------------------------------
-- sp_dim_facility_create
--

PRINT 'Creating derived.sp_dim_facility_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_facility_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_facility_create';

-- $BEGIN
CREATE TABLE derived.dim_facility(
    facility_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    facility_name NVARCHAR(255) NOT NULL,
    hfr_code NVARCHAR(255) NOT NULL,
    region NVARCHAR(255) NOT NULL,
    district NVARCHAR(255) NOT NULL,
    council NVARCHAR(255) NOT NULL
);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_facility_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_facility_insert
--

PRINT 'Creating derived.sp_dim_facility_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_facility_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_facility_insert';

-- $BEGIN

    WITH CTE_facilities AS (
        SELECT 
            HfrCode,
            Name AS facility_name,
            HfrCode AS hfr_code,
            Region AS region,
            District,
            Council,
            ROW_NUMBER() 
                OVER(
                    PARTITION BY HfrCode
                    ORDER BY HfrCode 
                    )
            AS RN 
        FROM
            [source].tbl_Facilities tf
    UNION ALL
    SELECT 
        'UNKNOWN',
        'UNKNOWN',
        'UNKNOWN',
        'UNKNOWN',
        'UNKNOWN',
        'UNKNOWN',
        1
    )
    INSERT INTO derived.dim_facility (
        facility_name,
        hfr_code,
        region,
        district,
        council
    )
    SELECT
        facility_name,
        hfr_code,
        region,
        district,
        council
    FROM
        CTE_facilities
    WHERE
        RN = 1
        
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_facility_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_facility
--

PRINT 'Creating derived.sp_dim_facility'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_facility AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_facility';

-- $BEGIN

EXEC derived.sp_dim_facility_create;
EXEC derived.sp_dim_facility_insert;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_facility';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_create
--

PRINT 'Creating derived.sp_dim_date_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_create';

-- $BEGIN

CREATE TABLE derived.dim_date  (
  date_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [date] DATE NULL,
  day_name NVARCHAR (255),
  day_number INT,
  annual_period_pepfar NVARCHAR (255),
  annual_period_gov NVARCHAR (255),
  annual_period_calendar NVARCHAR (255),
  semi_annual_period_gov NVARCHAR (255),
  semi_annual_period_calendar NVARCHAR (255),
  semi_annual_period_pepfar NVARCHAR (255),
  quarter_period_gov NVARCHAR (255),
  quarter_period_pepfar NVARCHAR (255),
  quarter_period_calendar NVARCHAR (255),
  month_period NVARCHAR (255),
  month_number NVARCHAR (255),
  weekly_start_monday_period NVARCHAR (255),
  weekly_start_monday_day_dates NVARCHAR (255),
  weekly_start_tuesday_period NVARCHAR (255),
  weekly_start_tuesday_day_dates NVARCHAR (255),
  weekly_start_wednesday_period NVARCHAR (255),
  weekly_start_wednesday_day_dates NVARCHAR (255),
  weekly_start_thursday_period NVARCHAR (255),
  weekly_start_thursday_day_dates NVARCHAR (255),
  weekly_start_friday_period NVARCHAR (255),
  weekly_start_friday_day_dates NVARCHAR (255),
  weekly_start_saturday_period NVARCHAR (255),
  weekly_start_saturday_day_dates NVARCHAR (255),
  weekly_start_sunday_period NVARCHAR (255),
  weekly_start_sunday_day_dates NVARCHAR (255)
);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_insert
--

PRINT 'Creating derived.sp_dim_date_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_insert';

-- $BEGIN
Set NOCOUNT ON;
SET DATEFIRST 1;
DECLARE @BeginDate DATE
DECLARE @EndDate DATE
DECLARE @RowNum INT = 1;
DECLARE @DateCounter DATE;
DECLARE @day_name NVARCHAR (255);
DECLARE @day_number NVARCHAR (255);
DECLARE @annual_period_pepfar NVARCHAR (255);
DECLARE @annual_period_gov NVARCHAR (255);
DECLARE @annual_period_calendar NVARCHAR (255);
DECLARE @semi_annual_period_gov NVARCHAR (255);
DECLARE @semi_annual_period_calendar NVARCHAR (255);
DECLARE @semi_annual_period_pepfar NVARCHAR (255);
DECLARE @quarter_period_gov NVARCHAR (255);
DECLARE @quarter_period_pepfar NVARCHAR (255);
DECLARE @quarter_period_calendar NVARCHAR (255);
DECLARE @month_period NVARCHAR (255);
DECLARE @month_number NVARCHAR (255);
--SET @BeginDate = CONVERT(DATE, DATEADD(MONTH, -4, GETDATE()));
SET @BeginDate = '2024-01-01';
SET @EndDate = DATEADD(DAY, -1, GETDATE());
SET @DateCounter = @BeginDate;
WHILE @DateCounter <= @EndDate
BEGIN

SET @day_name = dbo.fn_calculate_day_name(@DateCounter)
SET @day_number = dbo.fn_calculate_day_number(@DateCounter)
SET @annual_period_pepfar = dbo.fn_calculate_annual_period(@DateCounter,'pepfar')
SET @annual_period_gov = dbo.fn_calculate_annual_period(@DateCounter,'gov')
SET @annual_period_calendar = dbo.fn_calculate_annual_period(@DateCounter,'calender')
SET @semi_annual_period_gov = dbo.fn_calculate_semi_annual_period(@DateCounter,'gov')
SET @semi_annual_period_calendar = dbo.fn_calculate_semi_annual_period(@DateCounter,'calender')
SET @semi_annual_period_pepfar = dbo.fn_calculate_semi_annual_period(@DateCounter,'pepfar')
SET @quarter_period_gov = dbo.fn_calculate_quarter_period(@DateCounter,'gov')
SET @quarter_period_calendar = dbo.fn_calculate_quarter_period(@DateCounter,'calender')
SET @quarter_period_pepfar = dbo.fn_calculate_quarter_period(@DateCounter,'pepfar')
SET @month_period = dbo.fn_calculate_month_period(@DateCounter)
SET @month_number = dbo.fn_calculate_month_number(@DateCounter)

  INSERT INTO derived.dim_date(
    [date],
    day_name,
    day_number,
    annual_period_pepfar,
    annual_period_gov,
    annual_period_calendar,
    semi_annual_period_gov,
    semi_annual_period_calendar,
    semi_annual_period_pepfar,
    quarter_period_gov,
    quarter_period_pepfar,
    quarter_period_calendar,
    month_period,
    month_number
  )
  VALUES ( 
    @DateCounter,
    @day_name,
    @day_number,
    @annual_period_pepfar,
    @annual_period_gov,
    @annual_period_calendar,
    @semi_annual_period_gov,
    @semi_annual_period_calendar,
    @semi_annual_period_pepfar,
    @quarter_period_gov,
    @quarter_period_pepfar,
    @quarter_period_calendar,
    @month_period,
    @month_number
  );     

  -- Increment the date counter for next pass thru the loop      
  SET @DateCounter = DATEADD(DAY, 1, @DateCounter);

END;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_update_weekly_start_friday
--

PRINT 'Creating derived.sp_dim_date_update_weekly_start_friday'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_update_weekly_start_friday AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_update_weekly_start_friday';

-- $BEGIN

  DECLARE @dim_date_weekly TABLE (
      [date] DATE,
      weekly_start_period NVARCHAR (255),
      weekly_start_day_dates NVARCHAR (255)
  );
  DECLARE @date DATE;
  DECLARE @weekly_start_period NVARCHAR (255);
  DECLARE @weekly_start_day_dates NVARCHAR (255);
  DECLARE @week_number INT;
  DECLARE @year_number INT;
  DECLARE @start_day_number INT;
  DECLARE @week_start_date DATE;
  DECLARE @week_end_date DATE;
  DECLARE @previous_year_number INT;
  DECLARE @startDay NVARCHAR (255);
  SET @startDay = 'friday';
  SET @start_day_number = dbo.fn_calculate_day_number_by_name(@startDay);
  SELECT @week_start_date = MIN(date) from [derived].dim_date;
  SET DATEFIRST @start_day_number;
  SET @week_number = DATEPART(wk, @week_start_date);
  SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
  SET @year_number = UPPER(FORMAT(@week_start_date,'yy'));
  SET @previous_year_number = @year_number;
  DECLARE update_period_cursor CURSOR FOR
  SELECT
    [date]
  FROM
    derived.dim_date

  OPEN update_period_cursor;

  FETCH NEXT FROM update_period_cursor INTO @date;

  WHILE @@FETCH_STATUS = 0
  BEGIN
      EXEC dbo.sp_xf_system_calculate_weekly_number_by_day 
        @date =@date,
        @start_day_number = @start_day_number,
        @week_start_date = @week_start_date,
        @week_end_date = @week_end_date,
        @week_number = @week_number,
        @year_number = @year_number,
        @year_number_output = @year_number OUTPUT,
        @week_number_output = @week_number OUTPUT,
        @week_end_date_output = @week_end_date OUTPUT,
        @weekly_start_period = @weekly_start_period OUTPUT,
        @weekly_start_day_dates = @weekly_start_day_dates OUTPUT;

      INSERT INTO @dim_date_weekly (
        [date],
        weekly_start_period,
        weekly_start_day_dates
        )
      VALUES (
        @date,
        @weekly_start_period,
        @weekly_start_day_dates
        );

      FETCH NEXT FROM update_period_cursor INTO @date;
  END;

  CLOSE update_period_cursor;
  DEALLOCATE update_period_cursor;

  UPDATE
    dd
  SET
    weekly_start_friday_period = weekly_start_period,
    weekly_start_friday_day_dates = weekly_start_day_dates
  FROM
    derived.dim_date dd
  INNER JOIN
    @dim_date_weekly dw ON dd.[date] = dw.[date];

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_update_weekly_start_friday';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_update_weekly_start_monday
--

PRINT 'Creating derived.sp_dim_date_update_weekly_start_monday'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_update_weekly_start_monday AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_update_weekly_start_monday';

-- $BEGIN

  DECLARE @dim_date_weekly TABLE (
      [date] DATE,
      weekly_start_period NVARCHAR (255),
      weekly_start_day_dates NVARCHAR (255)
  );
  DECLARE @date DATE;
  DECLARE @weekly_start_period NVARCHAR (255);
  DECLARE @weekly_start_day_dates NVARCHAR (255);
  DECLARE @week_number INT;
  DECLARE @year_number INT;
  DECLARE @start_day_number INT;
  DECLARE @week_start_date DATE;
  DECLARE @week_end_date DATE;
  DECLARE @previous_year_number INT;
  DECLARE @startDay NVARCHAR (255);
  SET @startDay = 'monday';
  SET @start_day_number = dbo.fn_calculate_day_number_by_name(@startDay);
  SELECT @week_start_date = MIN(date) from [derived].dim_date;
  SET DATEFIRST @start_day_number;
  SET @week_number = DATEPART(wk, @week_start_date);
  SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
  SET @year_number = UPPER(FORMAT(@week_start_date,'yy'));
  SET @previous_year_number = @year_number;
  DECLARE update_period_cursor CURSOR FOR
  SELECT
    [date]
  FROM
    derived.dim_date

  OPEN update_period_cursor;

  FETCH NEXT FROM update_period_cursor INTO @date;

  WHILE @@FETCH_STATUS = 0
  BEGIN
      EXEC dbo.sp_xf_system_calculate_weekly_number_by_day 
        @date =@date,
        @start_day_number = @start_day_number,
        @week_start_date = @week_start_date,
        @week_end_date = @week_end_date,
        @week_number = @week_number,
        @year_number = @year_number,
        @year_number_output = @year_number OUTPUT,
        @week_number_output = @week_number OUTPUT,
        @week_end_date_output = @week_end_date OUTPUT,
        @weekly_start_period = @weekly_start_period OUTPUT,
        @weekly_start_day_dates = @weekly_start_day_dates OUTPUT;

      INSERT INTO @dim_date_weekly (
        [date],
        weekly_start_period,
        weekly_start_day_dates
        )
      VALUES (
        @date,
        @weekly_start_period,
        @weekly_start_day_dates
        );

      FETCH NEXT FROM update_period_cursor INTO @date;
  END;

  CLOSE update_period_cursor;
  DEALLOCATE update_period_cursor;

  UPDATE
    dd
  SET
    weekly_start_monday_period = weekly_start_period,
    weekly_start_monday_day_dates = weekly_start_day_dates
  FROM
    derived.dim_date dd
  INNER JOIN
    @dim_date_weekly dw ON dd.[date] = dw.[date];

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_update_weekly_start_monday';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_update_weekly_start_saturday
--

PRINT 'Creating derived.sp_dim_date_update_weekly_start_saturday'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_update_weekly_start_saturday AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_update_weekly_start_saturday';

-- $BEGIN

  DECLARE @dim_date_weekly TABLE (
      [date] DATE,
      weekly_start_period NVARCHAR (255),
      weekly_start_day_dates NVARCHAR (255)
  );
  DECLARE @date DATE;
  DECLARE @weekly_start_period NVARCHAR (255);
  DECLARE @weekly_start_day_dates NVARCHAR (255);
  DECLARE @week_number INT;
  DECLARE @year_number INT;
  DECLARE @start_day_number INT;
  DECLARE @week_start_date DATE;
  DECLARE @week_end_date DATE;
  DECLARE @previous_year_number INT;
  DECLARE @startDay NVARCHAR (255);
  SET @startDay = 'saturday';
  SET @start_day_number = dbo.fn_calculate_day_number_by_name(@startDay);
  SELECT @week_start_date = MIN(date) from [derived].dim_date;
  SET DATEFIRST @start_day_number;
  SET @week_number = DATEPART(wk, @week_start_date);
  SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
  SET @year_number = UPPER(FORMAT(@week_start_date,'yy'));
  SET @previous_year_number = @year_number;
  DECLARE update_period_cursor CURSOR FOR
  SELECT
    [date]
  FROM
    derived.dim_date

  OPEN update_period_cursor;

  FETCH NEXT FROM update_period_cursor INTO @date;

  WHILE @@FETCH_STATUS = 0
  BEGIN
      EXEC dbo.sp_xf_system_calculate_weekly_number_by_day 
        @date =@date,
        @start_day_number = @start_day_number,
        @week_start_date = @week_start_date,
        @week_end_date = @week_end_date,
        @week_number = @week_number,
        @year_number = @year_number,
        @year_number_output = @year_number OUTPUT,
        @week_number_output = @week_number OUTPUT,
        @week_end_date_output = @week_end_date OUTPUT,
        @weekly_start_period = @weekly_start_period OUTPUT,
        @weekly_start_day_dates = @weekly_start_day_dates OUTPUT;

      INSERT INTO @dim_date_weekly (
        [date],
        weekly_start_period,
        weekly_start_day_dates
        )
      VALUES (
        @date,
        @weekly_start_period,
        @weekly_start_day_dates
        );

      FETCH NEXT FROM update_period_cursor INTO @date;
  END;

  CLOSE update_period_cursor;
  DEALLOCATE update_period_cursor;

  UPDATE
    dd
  SET
    weekly_start_saturday_period = weekly_start_period,
    weekly_start_saturday_day_dates = weekly_start_day_dates
  FROM
    derived.dim_date dd
  INNER JOIN
    @dim_date_weekly dw ON dd.[date] = dw.[date];

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_update_weekly_start_saturday';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_update_weekly_start_sunday
--

PRINT 'Creating derived.sp_dim_date_update_weekly_start_sunday'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_update_weekly_start_sunday AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_update_weekly_start_sunday';

-- $BEGIN

  DECLARE @dim_date_weekly TABLE (
      [date] DATE,
      weekly_start_period NVARCHAR (255),
      weekly_start_day_dates NVARCHAR (255)
  );
  DECLARE @date DATE;
  DECLARE @weekly_start_period NVARCHAR (255);
  DECLARE @weekly_start_day_dates NVARCHAR (255);
  DECLARE @week_number INT;
  DECLARE @year_number INT;
  DECLARE @start_day_number INT;
  DECLARE @week_start_date DATE;
  DECLARE @week_end_date DATE;
  DECLARE @previous_year_number INT;
  DECLARE @startDay NVARCHAR (255);
  SET @startDay = 'sunday';
  SET @start_day_number = dbo.fn_calculate_day_number_by_name(@startDay);
  SELECT @week_start_date = MIN(date) from [derived].dim_date;
  SET DATEFIRST @start_day_number;
  SET @week_number = DATEPART(wk, @week_start_date);
  SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
  SET @year_number = UPPER(FORMAT(@week_start_date,'yy'));
  SET @previous_year_number = @year_number;
  DECLARE update_period_cursor CURSOR FOR
  SELECT
    [date]
  FROM
    derived.dim_date

  OPEN update_period_cursor;

  FETCH NEXT FROM update_period_cursor INTO @date;

  WHILE @@FETCH_STATUS = 0
  BEGIN
      EXEC dbo.sp_xf_system_calculate_weekly_number_by_day 
        @date =@date,
        @start_day_number = @start_day_number,
        @week_start_date = @week_start_date,
        @week_end_date = @week_end_date,
        @week_number = @week_number,
        @year_number = @year_number,
        @year_number_output = @year_number OUTPUT,
        @week_number_output = @week_number OUTPUT,
        @week_end_date_output = @week_end_date OUTPUT,
        @weekly_start_period = @weekly_start_period OUTPUT,
        @weekly_start_day_dates = @weekly_start_day_dates OUTPUT;

      INSERT INTO @dim_date_weekly (
        [date],
        weekly_start_period,
        weekly_start_day_dates
        )
      VALUES (
        @date,
        @weekly_start_period,
        @weekly_start_day_dates
        );

      FETCH NEXT FROM update_period_cursor INTO @date;
  END;

  CLOSE update_period_cursor;
  DEALLOCATE update_period_cursor;

  UPDATE
    dd
  SET
    weekly_start_sunday_period = weekly_start_period,
    weekly_start_sunday_day_dates = weekly_start_day_dates
  FROM
    derived.dim_date dd
  INNER JOIN
    @dim_date_weekly dw ON dd.[date] = dw.[date];

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_update_weekly_start_sunday';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_update_weekly_start_thursday
--

PRINT 'Creating derived.sp_dim_date_update_weekly_start_thursday'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_update_weekly_start_thursday AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_update_weekly_start_thursday';

-- $BEGIN

  DECLARE @dim_date_weekly TABLE (
      [date] DATE,
      weekly_start_period NVARCHAR (255),
      weekly_start_day_dates NVARCHAR (255)
  );
  DECLARE @date DATE;
  DECLARE @weekly_start_period NVARCHAR (255);
  DECLARE @weekly_start_day_dates NVARCHAR (255);
  DECLARE @week_number INT;
  DECLARE @year_number INT;
  DECLARE @start_day_number INT;
  DECLARE @week_start_date DATE;
  DECLARE @week_end_date DATE;
  DECLARE @previous_year_number INT;
  DECLARE @startDay NVARCHAR (255);
  SET @startDay = 'thursday';
  SET @start_day_number = dbo.fn_calculate_day_number_by_name(@startDay);
  SELECT @week_start_date = MIN(date) from [derived].dim_date;
  SET DATEFIRST @start_day_number;
  SET @week_number = DATEPART(wk, @week_start_date);
  SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
  SET @year_number = UPPER(FORMAT(@week_start_date,'yy'));
  SET @previous_year_number = @year_number;
  DECLARE update_period_cursor CURSOR FOR
  SELECT
    [date]
  FROM
    derived.dim_date

  OPEN update_period_cursor;

  FETCH NEXT FROM update_period_cursor INTO @date;

  WHILE @@FETCH_STATUS = 0
  BEGIN
      EXEC dbo.sp_xf_system_calculate_weekly_number_by_day 
        @date =@date,
        @start_day_number = @start_day_number,
        @week_start_date = @week_start_date,
        @week_end_date = @week_end_date,
        @week_number = @week_number,
        @year_number = @year_number,
        @year_number_output = @year_number OUTPUT,
        @week_number_output = @week_number OUTPUT,
        @week_end_date_output = @week_end_date OUTPUT,
        @weekly_start_period = @weekly_start_period OUTPUT,
        @weekly_start_day_dates = @weekly_start_day_dates OUTPUT;

      INSERT INTO @dim_date_weekly (
        [date],
        weekly_start_period,
        weekly_start_day_dates
        )
      VALUES (
        @date,
        @weekly_start_period,
        @weekly_start_day_dates
        );

      FETCH NEXT FROM update_period_cursor INTO @date;
  END;

  CLOSE update_period_cursor;
  DEALLOCATE update_period_cursor;

  UPDATE
    dd
  SET
    weekly_start_thursday_period = weekly_start_period,
    weekly_start_thursday_day_dates = weekly_start_day_dates
  FROM
    derived.dim_date dd
  INNER JOIN
    @dim_date_weekly dw ON dd.[date] = dw.[date];

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_update_weekly_start_thursday';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_update_weekly_start_tuesday
--

PRINT 'Creating derived.sp_dim_date_update_weekly_start_tuesday'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_update_weekly_start_tuesday AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_update_weekly_start_tuesday';

-- $BEGIN

  DECLARE @dim_date_weekly TABLE (
      [date] DATE,
      weekly_start_period NVARCHAR (255),
      weekly_start_day_dates NVARCHAR (255)
  );
  DECLARE @date DATE;
  DECLARE @weekly_start_period NVARCHAR (255);
  DECLARE @weekly_start_day_dates NVARCHAR (255);
  DECLARE @week_number INT;
  DECLARE @year_number INT;
  DECLARE @start_day_number INT;
  DECLARE @week_start_date DATE;
  DECLARE @week_end_date DATE;
  DECLARE @previous_year_number INT;
  DECLARE @startDay NVARCHAR (255);
  SET @startDay = 'tuesday';
  SET @start_day_number = dbo.fn_calculate_day_number_by_name(@startDay);
  SELECT @week_start_date = MIN(date) from [derived].dim_date;
  SET DATEFIRST @start_day_number;
  SET @week_number = DATEPART(wk, @week_start_date);
  SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
  SET @year_number = UPPER(FORMAT(@week_start_date,'yy'));
  SET @previous_year_number = @year_number;
  DECLARE update_period_cursor CURSOR FOR
  SELECT
    [date]
  FROM
    derived.dim_date

  OPEN update_period_cursor;

  FETCH NEXT FROM update_period_cursor INTO @date;

  WHILE @@FETCH_STATUS = 0
  BEGIN
      EXEC dbo.sp_xf_system_calculate_weekly_number_by_day 
        @date =@date,
        @start_day_number = @start_day_number,
        @week_start_date = @week_start_date,
        @week_end_date = @week_end_date,
        @week_number = @week_number,
        @year_number = @year_number,
        @year_number_output = @year_number OUTPUT,
        @week_number_output = @week_number OUTPUT,
        @week_end_date_output = @week_end_date OUTPUT,
        @weekly_start_period = @weekly_start_period OUTPUT,
        @weekly_start_day_dates = @weekly_start_day_dates OUTPUT;

      INSERT INTO @dim_date_weekly (
        [date],
        weekly_start_period,
        weekly_start_day_dates
        )
      VALUES (
        @date,
        @weekly_start_period,
        @weekly_start_day_dates
        );

      FETCH NEXT FROM update_period_cursor INTO @date;
  END;

  CLOSE update_period_cursor;
  DEALLOCATE update_period_cursor;

  UPDATE
    dd
  SET
    weekly_start_tuesday_period = weekly_start_period,
    weekly_start_tuesday_day_dates = weekly_start_day_dates
  FROM
    derived.dim_date dd
  INNER JOIN
    @dim_date_weekly dw ON dd.[date] = dw.[date];

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_update_weekly_start_tuesday';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date_update_weekly_start_wednesday
--

PRINT 'Creating derived.sp_dim_date_update_weekly_start_wednesday'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date_update_weekly_start_wednesday AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date_update_weekly_start_wednesday';

-- $BEGIN

  DECLARE @dim_date_weekly TABLE (
      [date] DATE,
      weekly_start_period NVARCHAR (255),
      weekly_start_day_dates NVARCHAR (255)
  );
  DECLARE @date DATE;
  DECLARE @weekly_start_period NVARCHAR (255);
  DECLARE @weekly_start_day_dates NVARCHAR (255);
  DECLARE @week_number INT;
  DECLARE @year_number INT;
  DECLARE @start_day_number INT;
  DECLARE @week_start_date DATE;
  DECLARE @week_end_date DATE;
  DECLARE @previous_year_number INT;
  DECLARE @startDay NVARCHAR (255);
  SET @startDay = 'wednesday';
  SET @start_day_number = dbo.fn_calculate_day_number_by_name(@startDay);
  SELECT @week_start_date = MIN(date) from [derived].dim_date;
  SET DATEFIRST @start_day_number;
  SET @week_number = DATEPART(wk, @week_start_date);
  SET @week_end_date = DATEADD(DAY, 6, @week_start_date );
  SET @year_number = UPPER(FORMAT(@week_start_date,'yy'));
  SET @previous_year_number = @year_number;
  DECLARE update_period_cursor CURSOR FOR
  SELECT
    [date]
  FROM
    derived.dim_date

  OPEN update_period_cursor;

  FETCH NEXT FROM update_period_cursor INTO @date;

  WHILE @@FETCH_STATUS = 0
  BEGIN
      EXEC dbo.sp_xf_system_calculate_weekly_number_by_day 
        @date =@date,
        @start_day_number = @start_day_number,
        @week_start_date = @week_start_date,
        @week_end_date = @week_end_date,
        @week_number = @week_number,
        @year_number = @year_number,
        @year_number_output = @year_number OUTPUT,
        @week_number_output = @week_number OUTPUT,
        @week_end_date_output = @week_end_date OUTPUT,
        @weekly_start_period = @weekly_start_period OUTPUT,
        @weekly_start_day_dates = @weekly_start_day_dates OUTPUT;

      INSERT INTO @dim_date_weekly (
        [date],
        weekly_start_period,
        weekly_start_day_dates
        )
      VALUES (
        @date,
        @weekly_start_period,
        @weekly_start_day_dates
        );

      FETCH NEXT FROM update_period_cursor INTO @date;
  END;

  CLOSE update_period_cursor;
  DEALLOCATE update_period_cursor;

  UPDATE
    dd
  SET
    weekly_start_wednesday_period = weekly_start_period,
    weekly_start_wednesday_day_dates = weekly_start_day_dates
  FROM
    derived.dim_date dd
  INNER JOIN
    @dim_date_weekly dw ON dd.[date] = dw.[date];

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date_update_weekly_start_wednesday';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_date
--

PRINT 'Creating derived.sp_dim_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_date';

-- $BEGIN

EXEC derived.sp_dim_date_create;
EXEC derived.sp_dim_date_insert;
EXEC derived.sp_dim_date_update_weekly_start_monday;
EXEC derived.sp_dim_date_update_weekly_start_tuesday;
EXEC derived.sp_dim_date_update_weekly_start_wednesday;
EXEC derived.sp_dim_date_update_weekly_start_thursday;
EXEC derived.sp_dim_date_update_weekly_start_friday;
EXEC derived.sp_dim_date_update_weekly_start_saturday;
EXEC derived.sp_dim_date_update_weekly_start_sunday;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_commodity_create
--

PRINT 'Creating derived.sp_dim_commodity_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_commodity_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_commodity_create';

-- $BEGIN
CREATE TABLE derived.dim_commodity(
    commodity_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    commodity_code NVARCHAR(255) NOT NULL,
    commodity_name NVARCHAR(255) NULL
);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_commodity_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_commodity_insert
--

PRINT 'Creating derived.sp_dim_commodity_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_commodity_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_commodity_insert';

-- $BEGIN
    INSERT INTO derived.dim_commodity (
        commodity_code,
        commodity_name
    )
    SELECT
        CommodityCode AS commodity_code,
        CommodityName AS commodity_name
    FROM
        [source].tbl_Commodity_Transactions

        
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_commodity_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_commodity
--

PRINT 'Creating derived.sp_dim_commodity'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_commodity AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_commodity';

-- $BEGIN

EXEC derived.sp_dim_commodity_create;
EXEC derived.sp_dim_commodity_insert;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_commodity';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_device_create
--

PRINT 'Creating derived.sp_dim_device_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_device_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_device_create';

-- $BEGIN
CREATE TABLE derived.dim_device(
    device_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    original_device_name NVARCHAR(255) NULL,
    device_code NVARCHAR(255) NULL,
    device_name NVARCHAR(255) NULL,
    source NVARCHAR(255) NULL,
    is_hvl_device INT NULL,
    is_eid_device INT NULL
);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_device_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_device_insert
--

PRINT 'Creating derived.sp_dim_device_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_device_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_device_insert';

-- $BEGIN

    
    INSERT INTO derived.dim_device (
        device_code,
        device_name,
        original_device_name,
        source
    )
    SELECT 
        device_code,
        device_name,
        original_device_name,
        [source]
    FROM
        (
            SELECT 
                device_code,
                device_name,
                original_device_name,
                [source],
                ROW_NUMBER() OVER(
                PARTITION BY
                    device_name
                ORDER BY
                    device_name
                ) RN
            FROM
                z.z_unique_device
        ) ud
    WHERE
        ud.RN = 1
        AND LEN(ISNULL(ud.device_name,'')) > 0;



        
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_device_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_device_update_is_hvl_device
--

PRINT 'Creating derived.sp_dim_device_update_is_hvl_device'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_device_update_is_hvl_device AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_device_update_is_hvl_device';

-- $BEGIN
     WITH cte_test_name AS (
        SELECT 
            DISTINCT 
            REPLACE(UPPER(DeviceName), ' ','') device_name
        FROM 
            [source].tbl_Sample
        WHERE 
            TestName = 'HIVVL'
            OR TestName ='HIVDR'
    )
    UPDATE dd
        SET
           dd.is_hvl_device = 
            CASE
                WHEN
                    ts.device_name IS NOT NULL 
                THEN 1
                ELSE 0
            END
    FROM
        derived.dim_device AS dd
    LEFT JOIN 
        cte_test_name AS ts ON dd.device_name = ts.device_name 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_device_update_is_hvl_device';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_device_update_is_eid_device
--

PRINT 'Creating derived.sp_dim_device_update_is_eid_device'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_device_update_is_eid_device AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_device_update_is_eid_device';

-- $BEGIN
    WITH cte_test_name AS (
        SELECT 
            DISTINCT 
            REPLACE(UPPER(DeviceName), ' ','') device_name
        FROM 
            [source].tbl_Sample
        WHERE 
            TestName = 'EID'
    )
    UPDATE dd
        SET
           dd.is_eid_device = 
            CASE
                WHEN
                    ts.device_name IS NOT NULL 
                THEN 1
                ELSE 0
            END
    FROM
        derived.dim_device AS dd
    LEFT JOIN 
        cte_test_name AS ts ON dd.device_name = ts.device_name 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_device_update_is_eid_device';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_device
--

PRINT 'Creating derived.sp_dim_device'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_device AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_device';

-- $BEGIN

EXEC derived.sp_dim_device_create;
EXEC derived.sp_dim_device_insert;
EXEC derived.sp_dim_device_update_is_hvl_device;
EXEC derived.sp_dim_device_update_is_eid_device;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_device';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_sample_create
--

PRINT 'Creating derived.sp_dim_sample_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_sample_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_sample_create';

-- $BEGIN
CREATE TABLE derived.dim_sample(
    sample_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    sample_tracking_id NVARCHAR(255) NOT NULL,
    sample_type NVARCHAR(255) NULL,
    test_name NVARCHAR(255) NULL,
    sample_quality_status NVARCHAR(255) NULL,
    rejection_reason NVARCHAR(255) NULL,
    clean_rejection_reason NVARCHAR(255) NULL,
    entry_modality NVARCHAR(255) NULL,
    hub_facility_id UNIQUEIDENTIFIER NULL,
    is_accepted INT NULL,
    device_id UNIQUEIDENTIFIER NULL,
    result  NVARCHAR(255) NULL,
    collected_date DATE NULL,
    lab_received_date DATE NULL,
    tested_date DATE NULL,
    result_authorized_date DATE NULL,
    result_dispatched_date DATE NULL,
    is_valid_record INT NULL DEFAULT 1,
    cleaning_comment NVARCHAR(255) NULL
);

ALTER TABLE derived.dim_sample ADD CONSTRAINT FK_derived_dim_sample_hub_facility FOREIGN KEY (hub_facility_id) REFERENCES derived.dim_facility(facility_id);
ALTER TABLE derived.dim_sample ADD CONSTRAINT FK_derived_dim_sample_device FOREIGN KEY (device_id) REFERENCES derived.dim_device(device_id);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_sample_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_sample_insert
--

PRINT 'Creating derived.sp_dim_sample_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_sample_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_sample_insert';

-- $BEGIN

    INSERT INTO [derived].dim_sample
    (
        sample_tracking_id,
        sample_type,
        test_name,
        sample_quality_status,
        rejection_reason,
        entry_modality,
        hub_facility_id,
        is_accepted,
        device_id,
        result,
        collected_date,
        lab_received_date,
        tested_date,
        result_authorized_date,
        result_dispatched_date
    )
    SELECT 
        sampletrackingid AS sample_tracking_id,
        ds.SampleType AS sample_type,
        ds.TestName AS test_name,
        ds.SampleQualityStatus AS sample_quality_status,
        NULLIF(ds.SampleRejectionReason, '') AS rejection_reason,
        ds.EntryModality AS entry_modality,
        hf.facility_id AS hub_facility_id,
        CASE
            WHEN
                SampleQualityStatus ='Accepted'
            THEN 1
            ELSE
                0
        END AS is_accepted,
        dv.device_id,
        NULLIF(LTRIM(RTRIM(ds.Results)), ''),
        ds.CollectionDate AS collected_date,
        ds.ReceivedDate AS lab_received_date,
        ds.TestDate AS tested_date,
        ds.AuthorisedDate AS result_authorized_date,
        ds.DispatchDate AS result_dispatched_date
    FROM
        [source].tbl_Sample ds
    LEFT JOIN
        [derived].dim_facility hf ON ds.HubHfrCode = hf.hfr_code COLLATE Latin1_General_100_CS_AS
    LEFT JOIN
        z.z_unique_device ud ON ud.original_device_name = ds.DeviceName COLLATE Latin1_General_100_CS_AS
     LEFT JOIN
        [derived].dim_device dv ON ud.device_name = dv.device_name COLLATE Latin1_General_100_CS_AS
   
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_sample_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_sample_update_clean_rejection_reason
--

PRINT 'Creating derived.sp_dim_sample_update_clean_rejection_reason'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_sample_update_clean_rejection_reason AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_sample_update_clean_rejection_reason';

-- $BEGIN

    UPDATE 
        ds
    SET 
        clean_rejection_reason = 
        CASE 
            WHEN 
                ds.rejection_reason = 'BLOOD' 
                OR ds.rejection_reason = 'Blood spots in contact each other'
                OR ds.rejection_reason = 'Old whole blood specimen with more than 24 hrs reaching the separation point' 
                OR ds.rejection_reason LIKE '%Hemolysed%'
                THEN  'Hemolysed sample'
            WHEN 
                ds.rejection_reason = 'Serum separation due to improper drying or collection' 
                OR ds.rejection_reason = 'Clotted or layered blood spot'
                OR ds.rejection_reason = 'Clotted Sample' 
                OR ds.rejection_reason LIKE '%clot%'
                OR ds.rejection_reason LIKE '%blood spot%'
                THEN  'Clotted specimen'
            WHEN 
                ds.rejection_reason = 'Insufficient specimen as per specific SOP' 
                OR ds.rejection_reason = 'Low volume'
                OR ds.rejection_reason = 'Sample did not fill the cycle in the DBS card' 
                OR ds.rejection_reason LIKE '%insufficient sample or specimen%' 
                OR ds.rejection_reason LIKE '%poor quality%' 
                THEN  'Insufficient sample has been submitted (Low volume)'
            WHEN 
                ds.rejection_reason = 'Unlabelled or mislabelled specimen' 
                OR ds.rejection_reason = 'Mismatched information on request form and specimen'
                OR ds.rejection_reason = 'Mismatched information between DBS card and laboratory test request form' 
                OR ds.rejection_reason = 'Incompletely filled requisition form' 
                OR ds.rejection_reason LIKE '%incomplete form or card%' 
                THEN  'Incomplete form'
            WHEN 
                ds.rejection_reason = 'Old DBS card with more than 14 days of collection' 
                OR ds.rejection_reason LIKE '%vacutainer%'
                OR ds.rejection_reason LIKE '%expired%'
                OR ds.rejection_reason LIKE '%more than days%'
                THEN  'Expired vacutainer/DBS Card'
            WHEN 
                ds.rejection_reason = 'No humidity indicator' 
                OR ds.rejection_reason = 'Indicating silica gel in the package' 
                THEN  'Improper packaging'
            ELSE 
                'Others'
        END
    FROM [derived].[dim_sample] AS ds

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_sample_update_clean_rejection_reason';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_sample_update_is_valid_record
--

PRINT 'Creating derived.sp_dim_sample_update_is_valid_record'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_sample_update_is_valid_record AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_sample_update_is_valid_record';

-- $BEGIN

    -------------------------------------------------------
    -- 'Missing HFR code'
    -------------------------------------------------------

    UPDATE
    ds
        SET
            ds.cleaning_comment = 'Missing HFR code',
            ds.is_valid_record = 0
    FROM
        derived.dim_sample ds
    WHERE
        ds.is_valid_record = 1
        AND ds.hub_facility_id IS NULL;
    
    -------------------------------------------------------
    -- 'Missing Test Name'
    -------------------------------------------------------

    UPDATE
    ds
        SET
            ds.cleaning_comment = 'Missing Test Name',
            ds.is_valid_record = 0
    FROM
        derived.dim_sample ds
    WHERE
        ds.is_valid_record = 1
        AND ds.test_name NOT IN ('HIVVL','EID');
    
    -------------------------------------------------------
    -- 'Missing Collected Or Received date'
    -------------------------------------------------------

    UPDATE
    ds
        SET
            ds.cleaning_comment = 'Missing Collected Or Received date',
            ds.is_valid_record = 0
    FROM
        derived.dim_sample ds
    WHERE
        ds.is_valid_record = 1
        AND (
            ds.collected_date IS NULL
            OR ds.lab_received_date IS NULL
        );

    -------------------------------------------------------
    -- 'Earlier Received date than Collected date'
    -------------------------------------------------------

    UPDATE
    ds
        SET
            ds.cleaning_comment = 'Earlier Received date than Collected date',
            ds.is_valid_record = 0
    FROM
        derived.dim_sample ds
    WHERE
        ds.is_valid_record = 1
        AND ds.lab_received_date > ds.collected_date;
    
    -------------------------------------------------------
    -- 'Earlier Dispatched date than Test date'
    -------------------------------------------------------

    UPDATE
    ds
        SET
            ds.cleaning_comment = 'Earlier Dispatched date than Test date',
            ds.is_valid_record = 0
    FROM
        derived.dim_sample ds
    WHERE
        ds.is_valid_record = 1
        AND ds.tested_date > ds.result_dispatched_date;

    -------------------------------------------------------
    -- 'Rejected but has Result'
    -------------------------------------------------------

    UPDATE
    ds
        SET
            ds.cleaning_comment = 'Rejected but has Result',
            ds.is_valid_record = 0
    FROM
        derived.dim_sample ds
    WHERE
        ds.is_valid_record = 1
        AND ds.clean_rejection_reason IS NOT NULL
        AND ds.result IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_sample_update_is_valid_record';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_sample
--

PRINT 'Creating derived.sp_dim_sample'
GO

CREATE OR ALTER PROCEDURE derived.sp_dim_sample AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_dim_sample';

-- $BEGIN

EXEC derived.sp_dim_sample_create;
EXEC derived.sp_dim_sample_insert;
EXEC derived.sp_dim_sample_update_clean_rejection_reason;
EXEC derived.sp_dim_sample_update_is_valid_record;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_dim_sample';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_create
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_create';

-- $BEGIN

    CREATE TABLE derived.fact_daily_commodity_status(
        daily_commodity_status_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
        commodity_id UNIQUEIDENTIFIER NULL,
        report_date DATE NOT NULL,
        quantity_received_in_the_last_3months INT NOT NULL DEFAULT 0,
        quantity_used_in_the_last_3months INT NOT NULL DEFAULT 0,
        quantity_expired_in_the_last_3months INT NOT NULL DEFAULT 0,
        available_balance INT NULL,
        average_monthly_usage INT NULL,
        months_of_stock INT NULL,
        quantity_expired INT NULL,
        quantity_expiring_in_the_next_30days INT NULL
    );

    ALTER TABLE derived.dim_commodity ADD CONSTRAINT fk_derived_fact_daily_commodity_status FOREIGN KEY (commodity_id) REFERENCES derived.dim_commodity(commodity_id);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_insert
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_insert';

-- $BEGIN

    INSERT INTO derived.fact_daily_commodity_status
    (
        report_date,
		commodity_id
    )

	SELECT
		dd.date,
		dc.commodity_id  
	FROM 
		derived.dim_date dd 
	CROSS JOIN 
		derived.dim_commodity dc; 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_quantity_received_in_the_last_3months
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_quantity_received_in_the_last_3months'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_quantity_received_in_the_last_3months AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_received_in_the_last_3months';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.quantity_received_in_the_last_3months = tct.TransactionQuantity
    FROM 
        [derived].fact_daily_commodity_status fds
    INNER JOIN 
        [derived].dim_commodity dc ON fds.commodity_id = dc.commodity_id
    INNER JOIN 
        [source].tbl_Commodity_Transactions tct ON dc.commodity_code = tct.CommodityCode AND tct.TransactionType = 'received'
    WHERE 
        tct.TransactionDate BETWEEN DATEADD(month, -3, fds.report_date) AND fds.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_received_in_the_last_3months';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_quantity_used_in_the_last_3months
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_quantity_used_in_the_last_3months'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_quantity_used_in_the_last_3months AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_used_in_the_last_3months';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.quantity_used_in_the_last_3months = tct.TransactionQuantity
    FROM 
        [derived].fact_daily_commodity_status fds
    INNER JOIN 
        [derived].dim_commodity dc ON fds.commodity_id = dc.commodity_id
    INNER JOIN 
        [source].tbl_Commodity_Transactions tct ON dc.commodity_code = tct.CommodityCode AND tct.TransactionType = 'used'
    WHERE 
        tct.TransactionDate BETWEEN DATEADD(month, -3, fds.report_date) AND fds.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_used_in_the_last_3months';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_quantity_expired_in_the_last_3months
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_quantity_expired_in_the_last_3months'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_quantity_expired_in_the_last_3months AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_expired_in_the_last_3months';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.quantity_expired_in_the_last_3months = tct.TransactionQuantity
    FROM 
        [derived].fact_daily_commodity_status fds
    INNER JOIN 
        [derived].dim_commodity dc ON fds.commodity_id = dc.commodity_id
    INNER JOIN 
        [source].tbl_Commodity_Transactions tct ON dc.commodity_code = tct.CommodityCode AND tct.ExpireDate IS NOT NULL
    WHERE 
        tct.ExpireDate BETWEEN DATEADD(month, -3, fds.report_date) AND fds.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_expired_in_the_last_3months';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_available_balance
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_available_balance'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_available_balance AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_available_balance';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.available_balance = fds.quantity_received_in_the_last_3months - (fds.quantity_used_in_the_last_3months + fds.quantity_expired_in_the_last_3months)
    FROM 
        [derived].fact_daily_commodity_status fds
    WHERE 
        fds.quantity_received_in_the_last_3months - (fds.quantity_used_in_the_last_3months + fds.quantity_expired_in_the_last_3months) >= 0;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_available_balance';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_average_monthly_usage
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_average_monthly_usage'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_average_monthly_usage AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_average_monthly_usage';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.average_monthly_usage = CEILING(fds.available_balance / 3.0)
    FROM 
        [derived].fact_daily_commodity_status fds;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_average_monthly_usage';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_months_of_stock
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_months_of_stock'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_months_of_stock AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_months_of_stock';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.months_of_stock = FLOOR(fds.available_balance / fds.average_monthly_usage) 
    FROM
        [derived].fact_daily_commodity_status fds
    WHERE
        fds.average_monthly_usage <> 0;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_months_of_stock';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_quantity_expired
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_quantity_expired'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_quantity_expired AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_expired';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.quantity_expired = tct.TransactionQuantity
    FROM 
        [derived].fact_daily_commodity_status fds
    INNER JOIN 
        [derived].dim_commodity dc ON fds.commodity_id = dc.commodity_id
    INNER JOIN 
        [source].tbl_Commodity_Transactions tct ON dc.commodity_code = tct.CommodityCode AND tct.ExpireDate IS NOT NULL
    WHERE 
        tct.ExpireDate = fds.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_expired';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status_update_quantity_expiring_in_the_next_30days
--

PRINT 'Creating derived.sp_fact_daily_commodity_status_update_quantity_expiring_in_the_next_30days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status_update_quantity_expiring_in_the_next_30days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_expiring_in_the_next_30days';

-- $BEGIN

    UPDATE 
        fds
    SET 
        fds.quantity_expiring_in_the_next_30days = tct.TransactionQuantity
    FROM 
        [derived].fact_daily_commodity_status fds
    INNER JOIN 
        [derived].dim_commodity dc ON fds.commodity_id = dc.commodity_id
    INNER JOIN 
        [source].tbl_Commodity_Transactions tct ON dc.commodity_code = tct.CommodityCode AND tct.ExpireDate IS NOT NULL
    WHERE 
        tct.ExpireDate BETWEEN fds.report_date AND DATEADD(DAY, 30, fds.report_date);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status_update_quantity_expiring_in_the_next_30days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_commodity_status
--

PRINT 'Creating derived.sp_fact_daily_commodity_status'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_commodity_status AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_commodity_status';

-- $BEGIN

    EXEC derived.sp_fact_daily_commodity_status_create;
    EXEC derived.sp_fact_daily_commodity_status_insert;
    EXEC derived.sp_fact_daily_commodity_status_update_quantity_received_in_the_last_3months;
    EXEC derived.sp_fact_daily_commodity_status_update_quantity_used_in_the_last_3months;
    EXEC derived.sp_fact_daily_commodity_status_update_quantity_expired_in_the_last_3months;
    EXEC derived.sp_fact_daily_commodity_status_update_available_balance;
    EXEC derived.sp_fact_daily_commodity_status_update_average_monthly_usage;
    EXEC derived.sp_fact_daily_commodity_status_update_months_of_stock;
    EXEC derived.sp_fact_daily_commodity_status_update_quantity_expired;
    EXEC derived.sp_fact_daily_commodity_status_update_quantity_expiring_in_the_next_30days;

-- $END 

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_commodity_status';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_create
--

PRINT 'Creating derived.sp_fact_daily_device_status_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_create';

-- $BEGIN

    CREATE TABLE derived.fact_daily_device_status(
        device_daily_status_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
        report_date DATE NOT NULL,
        device_id UNIQUEIDENTIFIER NOT NULL,
        has_been_broken INT NULL,
        has_been_fixed INT NULL,
        is_broken INT NULL,
        days_since_broken INT NULL,
        number_of_days_before_fixed INT NULL,
        is_active INT NOT NULL DEFAULT 0,
        breakdown_reason NVARCHAR(255) NULL,
        last_date_active DATE NULL
    );

    ALTER TABLE derived.fact_daily_device_status ADD CONSTRAINT fk_derived_fact_daily_device_status FOREIGN KEY (device_id) REFERENCES derived.dim_device(device_id);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_insert
--

PRINT 'Creating derived.sp_fact_daily_device_status_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_insert';

-- $BEGIN

    INSERT INTO derived.fact_daily_device_status
    (
        report_date,
		device_id
    )
	SELECT 
		dd.date,
		dv.device_id  
	FROM 
		derived.dim_date dd 
	CROSS JOIN 
		derived.dim_device dv 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_breakdown_reason
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_breakdown_reason'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_breakdown_reason AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_breakdown_reason';

-- $BEGIN

    UPDATE 
        ds
    SET
        ds.breakdown_reason = dl.break_down_reason
    FROM
        [derived].fact_daily_device_status AS ds
    LEFT JOIN 
        [derived].dim_device dd ON ds.device_id = dd.device_id
    LEFT JOIN 
        z.z_unique_device_logs AS dl ON dl.device_name = dd.device_name
            AND ds.report_date >= dl.date_broken_down
            AND (ds.report_date < dl.date_fixed 
                OR dl.date_fixed IS NULL
            )
    WHERE
        ds.is_broken = 1 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_breakdown_reason';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_days_since_broken
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_days_since_broken'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_days_since_broken AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_days_since_broken';

-- $BEGIN

    UPDATE 
        fd 
    SET
        days_since_broken = DATEDIFF(DAY, last_date_active, report_date)
    FROM
        [derived].fact_daily_device_status fd
    WHERE
	    fd.is_broken = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_days_since_broken';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_has_been_broken
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_has_been_broken'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_has_been_broken AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_has_been_broken';

-- $BEGIN

    UPDATE 
            ds
        SET
            ds.has_been_broken = 1
    FROM
        [derived].fact_daily_device_status AS ds
    INNER JOIN 
        [derived].dim_device dd ON ds.device_id = dd.device_id
    INNER JOIN 
        z.z_unique_device_logs AS dl ON dl.device_name = dd.device_name
            AND dl.date_broken_down = ds.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_has_been_broken';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_has_been_fixed
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_has_been_fixed'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_has_been_fixed AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_has_been_fixed';

-- $BEGIN

    UPDATE 
        ds 
    SET
        has_been_fixed = 1
    FROM
        [derived].fact_daily_device_status AS ds
    INNER JOIN 
        [derived].dim_device dd ON ds.device_id = dd.device_id
    INNER JOIN 
        z.z_unique_device_logs AS dl ON dl.device_name = dd.device_name  
            AND dl.date_fixed = ds.report_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_has_been_fixed';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_is_broken
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_is_broken'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_is_broken AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_is_broken';

-- $BEGIN

    UPDATE 
        ds 
    SET 
        is_broken =
        CASE
            WHEN 
                ds.report_date >= dl.date_broken_down
                AND (ds.report_date < dl.date_fixed
                OR dl.date_fixed IS NULL )
            THEN 1
            WHEN 
                ds.report_date >= dl.date_fixed
            THEN 0
            ELSE 
                NULL
        END
    FROM 
        [derived].fact_daily_device_status AS ds
    LEFT JOIN 
        [derived].dim_device AS dd ON ds.device_id = dd.device_id
    LEFT JOIN 
        z.z_unique_device_logs AS dl ON dl.device_name = dd.device_name
            AND ds.report_date >= dl.date_broken_down
    WHERE
        ds.has_been_fixed IS NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_is_broken';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_number_of_days_before_fixed
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_number_of_days_before_fixed'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_number_of_days_before_fixed AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_number_of_days_before_fixed';

-- $BEGIN

    UPDATE 
        ds 
    SET 
        number_of_days_before_fixed = 
        DATEDIFF(DAY, dl.date_broken_down, dl.date_fixed)
    FROM 
        [derived].fact_daily_device_status AS ds
    LEFT JOIN 
        [derived].dim_device AS dd ON ds.device_id = dd.device_id
    LEFT JOIN 
        z.z_unique_device_logs AS dl ON dl.device_name = dd.device_name
    WHERE 
        dl.date_fixed = ds.report_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_number_of_days_before_fixed';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_is_active
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_is_active'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_is_active AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_is_active';

-- $BEGIN

    UPDATE 
        ds
    SET 
        ds.is_active = 
            CASE 
                WHEN 
                    is_broken IS NULL 
                    OR is_broken = 0
                THEN  1
                ELSE  0
            END
    FROM
        [derived].fact_daily_device_status ds

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_is_active';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status_update_last_date_active
--

PRINT 'Creating derived.sp_fact_daily_device_status_update_last_date_active'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status_update_last_date_active AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status_update_last_date_active';

-- $BEGIN

    UPDATE 
        ds
    SET
        ds.last_date_active = CONVERT(DATE, zt.date_broken_down)
    FROM 
        [derived].fact_daily_device_status ds
    LEFT JOIN 
        [derived].dim_device dd ON ds.device_id = dd.device_id
    LEFT JOIN 
        z.z_unique_device_logs AS zt ON zt.device_name = dd.device_name 
    WHERE
        ds.report_date BETWEEN CONVERT(DATE, zt.date_broken_down) AND CONVERT(DATE, zt.date_fixed)

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status_update_last_date_active';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_device_status
--

PRINT 'Creating derived.sp_fact_daily_device_status'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_device_status AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_device_status';

-- $BEGIN

    EXEC derived.sp_fact_daily_device_status_create;
    EXEC derived.sp_fact_daily_device_status_insert;
    EXEC derived.sp_fact_daily_device_status_update_has_been_broken;
    EXEC derived.sp_fact_daily_device_status_update_has_been_fixed;
    EXEC derived.sp_fact_daily_device_status_update_is_broken;
    EXEC derived.sp_fact_daily_device_status_update_number_of_days_before_fixed;
    EXEC derived.sp_fact_daily_device_status_update_is_active;
    EXEC derived.sp_fact_daily_device_status_update_days_since_broken;
    EXEC derived.sp_fact_daily_device_status_update_breakdown_reason;
    EXEC derived.sp_fact_daily_device_status_update_last_date_active;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_device_status';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_status_create
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_status_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_status_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_create';

-- $BEGIN

    CREATE TABLE derived.fact_daily_hvl_sample_status (
        daily_hvl_sample_status_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
        _hfr_id NVARCHAR(255) NOT NULL,
        sample_id UNIQUEIDENTIFIER NOT NULL,
        report_date DATE NOT NULL,
        is_collected_on_report_date INT NULL,
        is_collected INT NULL,
        is_accepted_on_report_date INT NULL,
        is_accepted INT NULL,
        is_received_at_the_testing_lab_on_report_date INT NULL,
        is_received_at_testing_lab INT NULL,
        is_rejected_at_the_testing_lab_on_report_date INT NULL,
        hvl_plasma_rejected_at_the_testing_lab INT NULL,
        hvl_wholeblood_rejected_at_the_testing_lab INT NULL,
        is_received_by_entry_modality_lab INT NULL,
        is_received_by_entry_modality_hub INT NULL,
        is_tested_on_report_date INT NULL,
        hvl_plasma_tested_at_the_testing_lab INT NULL,
        hvl_wholeblood_tested_at_the_testing_lab INT NULL,
        hvl_sample_received_type_plasma INT NULL,
        hvl_sample_received_type_wholeblood INT NULL,
        result NVARCHAR (255) NULL,
        result_numeric INT NULL,
        samples_tested_with_results_equal_or_above_1000 INT NULL,
        samples_tested_with_results_less_than_1000_or_above_50 INT NULL,
        samples_tested_with_results_less_than_50 INT NULL,
        is_invalid_result INT NULL,
        is_failed_result INT NULL,
        is_result_pending INT NULL,
        is_target_not_detected INT NULL,
        is_authorized_on_report_date INT NULL,
        is_authorized INT NULL,
        is_dispatched_on_report_date INT NULL,
        hvl_plasma_dispatched INT NULL,
        hvl_wholeblood_dispatched INT NULL,
        days_in_wait_at_the_lab INT NULL,
        days_waited_at_the_lab INT NULL,
        is_less_than_or_equal_to_7_days_aging INT NULL,
        is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging INT NULL,
        is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging INT NULL,
        is_greater_than_21_days_aging INT NULL,
        days_between_sample_collected_and_received_date INT NULL,
        sample_collected_and_received_date_in_less_or_equal_5_days INT NULL,
        sample_collected_and_received_date_between_6_to_10_days INT NULL,
        sample_collected_and_received_date_between_11_to_15_days INT NULL,
        sample_collected_and_received_date_greater_than_15_days INT NULL,
        days_between_sample_received_and_authorised_date INT NULL,
        sample_received_and_authorised_date_in_less_or_equal_5_days INT NULL,
        sample_received_and_authorised_date_between_6_to_10_days INT NULL,
        sample_received_and_authorised_date_between_11_to_15_days INT NULL,
        sample_received_and_authorised_date_greater_than_15_days INT NULL,
        days_between_sample_collected_and_authorised_date INT NULL,
        sample_collected_and_authorised_date_in_less_or_equal_10_days INT NULL,
        sample_collected_and_authorised_date_between_11_to_14_days INT NULL,
        sample_collected_and_authorised_date_between_15_to_21_days INT NULL,
        sample_collected_and_authorised_date_greater_than_21_days INT NULL,
        days_between_sample_received_and_tested_date INT NULL,
        sample_received_and_tested_date_in_less_or_equal_5_days INT NULL,
        sample_received_and_tested_date_between_6_to_10_days INT NULL,
        sample_received_and_tested_date_between_11_to_15_days INT NULL,
        sample_received_and_tested_date_greater_than_15_days INT NULL
    );
    ALTER TABLE derived.fact_daily_hvl_sample_status ADD CONSTRAINT fk_derived_fact_daily_hvl_sample_status_sample FOREIGN KEY (sample_id) REFERENCES derived.dim_sample(sample_id);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_status_insert
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_status_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_status_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_insert';

-- $BEGIN

    INSERT INTO [derived].fact_daily_hvl_sample_status
    (
		_hfr_id,
        sample_id,
        report_date
    )

	SELECT
		ISNULL(df.hfr_code, uf.hfr_code) AS _hfr_id,
		ds.sample_id,
		ISNULL(dd.[date], ds.collected_date) report_date
	FROM
		[derived].dim_sample ds
	INNER JOIN
		[derived].dim_date dd 
		ON dd.[date] >= ds.collected_date 
		AND dd.[date] <= COALESCE(ds.result_dispatched_date, ds.result_authorized_date, ds.tested_date, ds.lab_received_date, ds.collected_date)
	LEFT JOIN
		[derived].dim_facility df
		ON df.facility_id = ds.hub_facility_id
	LEFT JOIN
		[derived].dim_facility uf
		ON uf.facility_name = 'UNKNOWN'
	WHERE
		test_name = 'HIVVL'
	;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_collected_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_collected_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_collected_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_collected_on_report_date';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_collected_on_report_date = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds ON fs.sample_id = ds.sample_id 
	WHERE 
		fs.report_date = ds.collected_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_collected_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_collected
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_collected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_collected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_collected';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_collected =  CASE
								WHEN fs.report_date > = ds.collected_date THEN 1
							ELSE 0
							END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds ON fs.sample_id = ds.sample_id 
		AND fs.report_date >= ds.collected_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_collected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_status_update_is_accepted
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_status_update_is_accepted'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_status_update_is_accepted AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_accepted';

-- $BEGIN
    
    UPDATE
        fe
    SET
        fe.is_accepted = 1
    FROM 
        [derived].fact_daily_hvl_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date >= ds.lab_received_date
	WHERE 
	    ds.sample_quality_status ='Accepted';


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_accepted';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_status_update_is_accepted_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_status_update_is_accepted_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_status_update_is_accepted_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_accepted_on_report_date';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_accepted_on_report_date = 1
    FROM 
        [derived].fact_daily_hvl_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date = ds.lab_received_date
        AND ds.sample_quality_status ='Accepted'


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_accepted_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_received_at_the_testing_lab_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_received_at_the_testing_lab_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_received_at_the_testing_lab_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_received_at_the_testing_lab_on_report_date';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_received_at_the_testing_lab_on_report_date = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds 
		ON fs.sample_id = ds.sample_id 
		AND fs.report_date = ds.lab_received_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_received_at_the_testing_lab_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_rejected_at_the_testing_lab_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_rejected_at_the_testing_lab_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_rejected_at_the_testing_lab_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_rejected_at_the_testing_lab_on_report_date';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_rejected_at_the_testing_lab_on_report_date = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.lab_received_date 
	WHERE
		ds.sample_quality_status = 'RejectedLab'

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_rejected_at_the_testing_lab_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_plasma_rejected_at_the_testing_lab
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_plasma_rejected_at_the_testing_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_plasma_rejected_at_the_testing_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_plasma_rejected_at_the_testing_lab';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_plasma_rejected_at_the_testing_lab = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.lab_received_date
	WHERE
		ds.sample_quality_status = 'RejectedLab'
		AND ds.sample_type = 'Plasma'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_plasma_rejected_at_the_testing_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_wholeblood_rejected_at_the_testing_lab
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_rejected_at_the_testing_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_rejected_at_the_testing_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_rejected_at_the_testing_lab';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_wholeblood_rejected_at_the_testing_lab = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.lab_received_date
	WHERE
		ds.sample_quality_status = 'RejectedLab'
		AND ds.sample_type = 'Wholeblood'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_rejected_at_the_testing_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_lab
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_lab';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_received_by_entry_modality_lab = 1
FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.lab_received_date
	WHERE
		ds.entry_modality = 'lab'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_hub
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_hub'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_hub AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_hub';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_received_by_entry_modality_hub = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND report_date = ds.lab_received_date
	WHERE
		ds.entry_modality = 'hub'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_hub';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_tested_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_tested_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_tested_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_tested_on_report_date';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_tested_on_report_date = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds ON fs.sample_id = ds.sample_id 
		AND fs.report_date = ds.tested_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_tested_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_plasma_tested_at_the_testing_lab
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_plasma_tested_at_the_testing_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_plasma_tested_at_the_testing_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_plasma_tested_at_the_testing_lab';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_plasma_tested_at_the_testing_lab = 
		CASE
			WHEN 
				ds.sample_type = 'Plasma' 
			THEN 1
			ELSE 0
		END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds ON fs.sample_id = ds.sample_id
		AND is_tested_on_report_date = 1
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_plasma_tested_at_the_testing_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_wholeblood_tested_at_the_testing_lab
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_tested_at_the_testing_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_tested_at_the_testing_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_tested_at_the_testing_lab';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_wholeblood_tested_at_the_testing_lab = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.tested_date
	WHERE
		ds.sample_type = 'Wholeblood'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_tested_at_the_testing_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_sample_received_type_plasma
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_plasma'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_plasma AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_plasma';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_sample_received_type_plasma = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.lab_received_date 
	WHERE
		ds.sample_type = 'plasma'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_plasma';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_sample_received_type_wholeblood
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_wholeblood'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_wholeblood AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_wholeblood';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_sample_received_type_wholeblood = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.lab_received_date
	WHERE
		ds.sample_type = 'wholeblood'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_wholeblood';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_authorized_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_authorized_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_authorized_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_authorized_on_report_date';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_authorized_on_report_date = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.result_authorized_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_authorized_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_authorized
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_authorized'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_authorized AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_authorized';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_authorized = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds ON fs.sample_id = ds.sample_id 
		AND fs.report_date >= ds.result_authorized_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_authorized';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_dispatched_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_dispatched_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_dispatched_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_dispatched_on_report_date';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_dispatched_on_report_date = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds ON fs.sample_id = ds.sample_id
	WHERE 
		fs.report_date = ds.result_dispatched_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_dispatched_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_plasma_dispatched
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_plasma_dispatched'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_plasma_dispatched AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_plasma_dispatched';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_plasma_dispatched = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.result_dispatched_date
	WHERE
		ds.sample_type = 'Plasma'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_plasma_dispatched';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_hvl_wholeblood_dispatched
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_dispatched'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_dispatched AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_dispatched';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.hvl_wholeblood_dispatched = 1
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.result_dispatched_date
	WHERE
		ds.sample_type = 'Wholeblood'
	
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_dispatched';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_result
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_result'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_result';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.result  = ts.Results 
	FROM
		derived.fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds ON fs.sample_id = ds.sample_id
	INNER JOIN 
		source.tbl_Sample ts ON ts.sampleTrackingId = ds.sample_tracking_id 
	WHERE
		ds.result_authorized_date = fs.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_result_numeric
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_result_numeric'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_result_numeric AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_result_numeric';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.result_numeric  = 
		CASE
			WHEN fs.result LIKE '%<20%'
				OR fs.result LIKE '%<40%'
				OR fs.result LIKE '%< 40%'
				OR fs.result LIKE '%Target Not Detected%'
			THEN 11
			WHEN fs.result LIKE '%150%'
				OR fs.result LIKE '%< 150%'
			THEN 150
			ELSE TRY_CAST(fs.result AS INT)
		END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	WHERE
		fs.result IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_result_numeric';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_status_update_is_target_not_detected
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_status_update_is_target_not_detected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_status_update_is_target_not_detected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_target_not_detected';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_target_not_detected = 
        CASE
            WHEN LOWER(REPLACE(ds.result, ' ', '')) IN ('targetnotdetected', 'tnd')
            THEN 1
            WHEN LOWER(REPLACE(ds.result, ' ', '')) NOT IN ('targetdetected', 'tnd')
            THEN 0
        END 
    FROM 
        [derived].fact_daily_hvl_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.is_tested_on_report_date = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_target_not_detected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_status_update_is_result_pending
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_status_update_is_result_pending'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_status_update_is_result_pending AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_result_pending';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_result_pending = 1
    FROM 
        [derived].fact_daily_hvl_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date >= ds.tested_date
        AND fe.report_date < ds.result_authorized_date ;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status_update_is_result_pending';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_samples_tested_with_results_equal_or_above_1000
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_equal_or_above_1000'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_equal_or_above_1000 AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_equal_or_above_1000';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.samples_tested_with_results_equal_or_above_1000 = 
		CASE
			WHEN 
				fs.result_numeric >= 1000 
			THEN 1
			ELSE 0
		END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	WHERE 
		is_tested_on_report_date = 1

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_equal_or_above_1000';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_1000_or_above_50
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_1000_or_above_50'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_1000_or_above_50 AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_1000_or_above_50';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.samples_tested_with_results_less_than_1000_or_above_50 = 
		CASE
			WHEN 
				fs.result_numeric < 1000
				AND fs.result_numeric > 50  
			THEN 1
			ELSE 0
		END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	WHERE 
		is_tested_on_report_date = 1

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_1000_or_above_50';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_50
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_50'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_50 AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_50';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.samples_tested_with_results_less_than_50 = 
		CASE
			WHEN 
				fs.result_numeric < 50 
			THEN 1
			ELSE 0
		END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	WHERE 
		is_tested_on_report_date = 1


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_50';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_invalid_result
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_invalid_result'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_invalid_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_invalid_result';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_invalid_result = 
		CASE
			WHEN 
				LOWER(fs.result) = 'invalid'  
			THEN 1
			ELSE 0
		END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.tested_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_invalid_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_is_failed_result
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_is_failed_result'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_is_failed_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_failed_result';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.is_failed_result = 
		CASE
			WHEN 
				fs.result = 'Failed' 
			THEN 1
			ELSE 0
		END
	FROM
		[derived].fact_daily_hvl_sample_status fs
	INNER JOIN
		[derived].dim_sample ds
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.tested_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_is_failed_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_days_in_wait_at_the_lab
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_days_in_wait_at_the_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_days_in_wait_at_the_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_in_wait_at_the_lab';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.days_in_wait_at_the_lab = 
			DATEDIFF(DAY,ds.lab_received_date, fs.report_date)
	FROM
		derived.fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date <= ds.tested_date 
		AND fs.report_date >= ds.lab_received_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_in_wait_at_the_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_days_waited_at_the_lab
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_days_waited_at_the_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_days_waited_at_the_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_waited_at_the_lab';

-- $BEGIN

	UPDATE
		fs
	SET
		fs.days_waited_at_the_lab = 
			DATEDIFF(DAY,ds.lab_received_date, ds.tested_date)
	FROM
		derived.fact_daily_hvl_sample_status fs
	INNER JOIN
		derived.dim_sample ds 
		ON fs.sample_id = ds.sample_id
		AND fs.report_date = ds.tested_date 
		AND ds.tested_date >= ds.lab_received_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_waited_at_the_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_aging
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_aging'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_aging AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_aging';

-- $BEGIN

	UPDATE fh
        SET
            fh.is_less_than_or_equal_to_7_days_aging = 
                CASE
                    WHEN
                        fh.days_in_wait_at_the_lab <= 7  
                    THEN 1
                    ELSE 0
                END,
			fh.is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging =
                CASE
                    WHEN
                        fh.days_in_wait_at_the_lab > 7
                        AND fh.days_in_wait_at_the_lab <= 14  
                    THEN 1
                    ELSE 0
                END,
			fh.is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging = 
                CASE
                    WHEN
                        fh.days_in_wait_at_the_lab > 14 
                        AND fh.days_in_wait_at_the_lab <= 21 
                    THEN 1
                    ELSE 0
                END,
			fh.is_greater_than_21_days_aging = 
                CASE
                    WHEN
                        fh.days_in_wait_at_the_lab > 21 
                    THEN 1
                    ELSE 0
                END
    FROM
        [derived].fact_daily_hvl_sample_status fh
    WHERE
        fh.days_in_wait_at_the_lab IS NOT NULL
        AND fh.is_tested_on_report_date = 1


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_aging';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_received_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_received_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_received_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_received_date';

-- $BEGIN

    UPDATE 
        fs
        SET 
            days_between_sample_collected_and_received_date = 
            DATEDIFF(day, ds.collected_date, ds.lab_received_date)
    FROM
        [derived].fact_daily_hvl_sample_status fs
    INNER JOIN
        [derived].dim_sample ds 
        ON fs.sample_id = ds.sample_id
        AND report_date = ds.lab_received_date
        AND ds.collected_date <= ds.lab_received_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_received_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_authorised_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_authorised_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_authorised_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_authorised_date';

-- $BEGIN

    UPDATE 
        fs
    SET 
        fs.days_between_sample_collected_and_authorised_date = 
        DATEDIFF(day, ds.collected_date, ds.result_authorized_date)
    FROM
        derived.fact_daily_hvl_sample_status fs
    INNER JOIN
        derived.dim_sample ds 
        ON fs.sample_id = ds.sample_id 
        AND fs.report_date = ds.result_authorized_date
    WHERE
        ds.collected_date <= ds.result_authorized_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_authorised_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_days_between_sample_received_and_authorised_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_authorised_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_authorised_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_authorised_date';

-- $BEGIN

    UPDATE 
        fs
        SET 
            days_between_sample_received_and_authorised_date = 
            DATEDIFF(day, ds.lab_received_date, ds.result_authorized_date)
    FROM
        derived.fact_daily_hvl_sample_status fs
    INNER JOIN
        [derived].dim_sample ds ON fs.sample_id = ds.sample_id
        AND report_date = ds.result_authorized_date
        AND ds.lab_received_date <= ds.result_authorized_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_authorised_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_days_between_sample_received_and_tested_date
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_tested_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_tested_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_tested_date';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.days_between_sample_received_and_tested_date = 
        DATEDIFF(day, ds.lab_received_date, ds.tested_date)
    FROM
        derived.fact_daily_hvl_sample_status fs
    INNER JOIN
        [derived].dim_sample ds
        ON fs.sample_id = ds.sample_id
        AND fs.report_date = ds.tested_date
    WHERE
        ds.lab_received_date <= ds.tested_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_tested_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_6_to_10_days';

-- $BEGIN

    UPDATE 
            fs
        SET
            fs.sample_collected_and_received_date_between_6_to_10_days = 
                CASE
                    WHEN 
                        days_between_sample_collected_and_received_date >= 6
                        AND days_between_sample_collected_and_received_date <= 10
                    THEN 1
                    ELSE 0
                END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_11_to_15_days';

-- $BEGIN

    UPDATE 
            fs
        SET
            fs.sample_collected_and_received_date_between_11_to_15_days = 
                CASE
                    WHEN 
                        days_between_sample_collected_and_received_date >= 11 
                        AND days_between_sample_collected_and_received_date <= 15 
                    THEN 1
                    ELSE 0
                END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_greater_than_15_days';

-- $BEGIN

    UPDATE 
            fs
        SET
            fs.sample_collected_and_received_date_greater_than_15_days = 
                CASE
                    WHEN 
                        days_between_sample_collected_and_received_date > 15 
                    THEN 1
                    ELSE 0
                END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_in_less_or_equal_5_days';

-- $BEGIN

    UPDATE 
            fs
    SET
        fs.sample_collected_and_received_date_in_less_or_equal_5_days = 
        CASE
            WHEN
                days_between_sample_collected_and_received_date <= 5 
            THEN 1
            ELSE 0
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_in_less_or_equal_5_days';

-- $BEGIN

    UPDATE 
            fs
    SET
        fs.sample_received_and_authorised_date_in_less_or_equal_5_days = 
        CASE
            WHEN
                days_between_sample_received_and_authorised_date <= 5 THEN 1
            ELSE 0
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_6_to_10_days';

-- $BEGIN

    UPDATE 
            fs
        SET
            fs.sample_received_and_authorised_date_between_6_to_10_days = 
                CASE
                    WHEN 
                        days_between_sample_received_and_authorised_date >= 6
                        AND days_between_sample_received_and_authorised_date <= 10
                    THEN 1
                    ELSE 0
                END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_11_to_15_days';

-- $BEGIN


    UPDATE 
            fs
        SET
            fs.sample_received_and_authorised_date_between_11_to_15_days = 
                CASE
                    WHEN 
                        days_between_sample_received_and_authorised_date >= 11
                        AND days_between_sample_received_and_authorised_date <= 15
                    THEN 1
                    ELSE 0
                END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_greater_than_15_days';

-- $BEGIN

    UPDATE 
            fs
        SET
            fs.sample_received_and_authorised_date_greater_than_15_days = 
                CASE
                    WHEN 
                        days_between_sample_received_and_authorised_date >= 15 THEN 1
                    ELSE 0
                END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_in_less_or_equal_10_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_in_less_or_equal_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_in_less_or_equal_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_in_less_or_equal_10_days';

-- $BEGIN

    UPDATE 
        fs
    SET
        fs.sample_collected_and_authorised_date_in_less_or_equal_10_days = 
        CASE
            WHEN
                fs.days_between_sample_collected_and_authorised_date <= 10 
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE 
        fs.days_between_sample_collected_and_authorised_date IS NOT NULL
        AND fs.is_authorized_on_report_date = 1

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_in_less_or_equal_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_11_to_14_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_11_to_14_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_11_to_14_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_11_to_14_days';

-- $BEGIN

    UPDATE 
        fs
    SET
        fs.sample_collected_and_authorised_date_between_11_to_14_days = 
        CASE
            WHEN
                fs.days_between_sample_collected_and_authorised_date >= 11 
                AND fs.days_between_sample_collected_and_authorised_date <= 14 
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        fs.days_between_sample_collected_and_authorised_date IS NOT NULL
        AND fs.is_authorized_on_report_date = 1

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_11_to_14_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_15_to_21_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_15_to_21_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_15_to_21_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_15_to_21_days';

-- $BEGIN

    UPDATE 
        fs
    SET
        fs.sample_collected_and_authorised_date_between_15_to_21_days = 
        CASE
            WHEN
                fs.days_between_sample_collected_and_authorised_date >= 15 
                AND fs.days_between_sample_collected_and_authorised_date <= 21 
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        fs.days_between_sample_collected_and_authorised_date IS NOT NULL
        AND fs.is_authorized_on_report_date = 1

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_15_to_21_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_greater_than_21_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_greater_than_21_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_greater_than_21_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_greater_than_21_days';

-- $BEGIN

    UPDATE 
        fs
    SET
        fs.sample_collected_and_authorised_date_greater_than_21_days = 
        CASE
            WHEN
                fs.days_between_sample_collected_and_authorised_date > 21 
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        fs.days_between_sample_collected_and_authorised_date IS NOT NULL
        AND fs.is_authorized_on_report_date = 1

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_greater_than_21_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_in_less_or_equal_to_5_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_in_less_or_equal_to_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_in_less_or_equal_to_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_in_less_or_equal_to_5_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_in_less_or_equal_5_days = 
        CASE
            WHEN
                fs.days_between_sample_received_and_tested_date <= 5
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        fs.days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_in_less_or_equal_to_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_6_to_10_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_between_6_to_10_days = 
        CASE
            WHEN
                fs.days_between_sample_received_and_tested_date >= 6
                AND fs.days_between_sample_received_and_tested_date <= 10
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        fs.days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_11_to_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_between_11_to_15_days = 
        CASE
            WHEN
                fs.days_between_sample_received_and_tested_date >= 11
                AND fs.days_between_sample_received_and_tested_date <= 15
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        fs.days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_greater_than_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_greater_than_15_days = 
        CASE
            WHEN
                fs.days_between_sample_received_and_tested_date > 15
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_hvl_sample_status fs
    WHERE
        fs.days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_hvl_sample_status
--

PRINT 'Creating derived.sp_fact_daily_hvl_sample_status'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_hvl_sample_status AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status';

-- $BEGIN

    EXEC derived.sp_fact_daily_hvl_sample_status_create;
    EXEC derived.sp_fact_daily_hvl_sample_status_insert;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_collected_on_report_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_collected;
    EXEC derived.sp_fact_daily_hvl_sample_status_update_is_accepted;
    EXEC derived.sp_fact_daily_hvl_sample_status_update_is_accepted_on_report_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_received_at_the_testing_lab_on_report_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_rejected_at_the_testing_lab_on_report_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_plasma_rejected_at_the_testing_lab;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_rejected_at_the_testing_lab;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_lab;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_received_by_entry_modality_hub;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_tested_on_report_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_plasma_tested_at_the_testing_lab;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_tested_at_the_testing_lab;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_plasma;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_sample_received_type_wholeblood;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_authorized_on_report_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_authorized;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_dispatched_on_report_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_plasma_dispatched;
    EXEC derived.sp_fact_daily_hvl_sample_update_hvl_wholeblood_dispatched;
    EXEC derived.sp_fact_daily_hvl_sample_update_result;
    EXEC derived.sp_fact_daily_hvl_sample_update_result_numeric;
    EXEC derived.sp_fact_daily_hvl_sample_status_update_is_target_not_detected;
    EXEC derived.sp_fact_daily_hvl_sample_status_update_is_result_pending;
    EXEC derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_equal_or_above_1000;
    EXEC derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_1000_or_above_50;
    EXEC derived.sp_fact_daily_hvl_sample_update_samples_tested_with_results_less_than_50;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_invalid_result;
    EXEC derived.sp_fact_daily_hvl_sample_update_is_failed_result;
    EXEC derived.sp_fact_daily_hvl_sample_update_days_in_wait_at_the_lab;
    EXEC derived.sp_fact_daily_hvl_sample_update_days_waited_at_the_lab;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_aging;
    EXEC derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_received_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_days_between_sample_collected_and_authorised_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_authorised_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_days_between_sample_received_and_tested_date;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_6_to_10_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_between_11_to_15_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_greater_than_15_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_received_date_in_less_or_equal_5_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_in_less_or_equal_5_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_6_to_10_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_between_11_to_15_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_authorised_date_greater_than_15_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_in_less_or_equal_10_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_11_to_14_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_between_15_to_21_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_collected_and_authorised_date_greater_than_21_days;
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_in_less_or_equal_to_5_days;    
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_6_to_10_days;  
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_between_11_to_15_days; 
    EXEC derived.sp_fact_daily_hvl_sample_update_sample_received_and_tested_date_greater_than_15_days;  

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_hvl_sample_status';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_create
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_create';

-- $BEGIN

CREATE TABLE derived.fact_daily_eid_sample_status(
    daily_eid_sample_status_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    _hfr_id NVARCHAR(255) NOT NULL,
    sample_id UNIQUEIDENTIFIER NOT NULL,
    report_date DATE NOT NULL,
    is_collected_on_report_date INT NULL,
    is_collected INT NULL,
    is_accepted_on_report_date INT NULL,
    is_accepted INT NULL,
    is_received_at_the_testing_lab_on_report_date INT NULL,
    is_rejected_at_the_testing_lab_on_report_date INT NULL,
    is_received_at_testing_lab INT NULL,
    is_received_by_entry_modality_lab INT NULL,
    is_received_by_entry_modality_hub INT NULL,
    is_tested_on_report_date INT NULL,
    eid_sample_received_type_dbs INT NULL,
    result NVARCHAR(255) NULL,
    is_sample_tested_positive INT NULL,
    is_sample_tested_negative INT NULL,
    is_sample_tested_result_not_detected INT NULL,
    is_invalid_result INT NULL,
    is_failed_result INT NULL,
    is_indeterminate_result INT NULL,
    is_result_pending INT NULL,
    is_authorized INT NULL,
    is_authorized_on_report_date INT NULL,
    is_dispatched_on_report_date INT NULL,
    days_between_sample_collected_and_received_date INT NULL,
    sample_collected_and_received_date_in_less_or_equal_5_days INT NULL,
    sample_collected_and_received_date_between_6_to_10_days INT NULL,
    sample_collected_and_received_date_between_11_to_15_days INT NULL,
    sample_collected_and_received_date_greater_than_15_days INT NULL,
    sample_received_and_authorised_date_in_less_or_equal_5_days INT NULL,
    sample_received_and_authorised_date_between_6_to_10_days INT NULL,
    sample_received_and_authorised_date_between_11_to_15_days INT NULL,
    sample_received_and_authorised_date_greater_than_15_days INT NULL,
    days_between_sample_collected_and_authorised_date INT NULL,
    days_between_sample_received_and_authorised_date INT NULL,
    sample_collected_and_authorised_date_in_less_or_equal_10_days INT NULL,
    sample_collected_and_authorised_date_between_11_to_14_days INT NULL,
    sample_collected_and_authorised_date_between_15_to_21_days INT NULL,
    sample_collected_and_authorised_date_greater_than_21_days INT NULL,
    days_between_sample_received_and_tested_date INT NULL,
    sample_received_and_tested_date_in_less_or_equal_5_days INT NULL,
    sample_received_and_tested_date_between_6_to_10_days INT NULL,
    sample_received_and_tested_date_between_11_to_15_days INT NULL,
    sample_received_and_tested_date_greater_than_15_days INT NULL,
    days_in_wait_at_the_lab INT NULL,
    days_waited_at_the_lab INT NULL,
    is_less_than_or_equal_to_7_days_aging INT NULL,
    is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging INT NULL,
    is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging INT NULL,
    is_greater_than_21_days_aging INT NULL
);

ALTER TABLE derived.fact_daily_eid_sample_status ADD CONSTRAINT fk_derived_fact_daily_eid_sample_status FOREIGN KEY (sample_id) REFERENCES derived.dim_sample(sample_id);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_insert
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_insert';

-- $BEGIN

    INSERT INTO [derived].fact_daily_eid_sample_status
    (
		_hfr_id,
        sample_id,
        report_date
    )
	SELECT
		ISNULL(df.hfr_code, uf.hfr_code) AS _hfr_id,
		ds.sample_id,
		ISNULL(dd.[date], ds.collected_date) report_date
	FROM
		[derived].dim_sample ds
	INNER JOIN
		[derived].dim_date dd 
		ON dd.[date] >= ds.collected_date 
		AND dd.[date] <= COALESCE(ds.result_dispatched_date, ds.result_authorized_date, ds.tested_date, ds.lab_received_date, ds.collected_date)
	LEFT JOIN
		[derived].dim_facility df
		ON df.facility_id = ds.hub_facility_id
	LEFT JOIN
		[derived].dim_facility uf
		ON uf.facility_name = 'UNKNOWN'
	WHERE 
		ds.test_name = 'EID'

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_received_at_the_testing_lab_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_received_at_the_testing_lab_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_received_at_the_testing_lab_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_received_at_the_testing_lab_on_report_date';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_received_at_the_testing_lab_on_report_date = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.lab_received_date
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_received_at_the_testing_lab_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_rejected_at_the_testing_lab_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_rejected_at_the_testing_lab_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_rejected_at_the_testing_lab_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_rejected_at_the_testing_lab_on_report_date';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_rejected_at_the_testing_lab_on_report_date = 
        CASE 
            WHEN 
                ds.sample_quality_status = 'RejectedLab'
            THEN 1
            ELSE 0
        END
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.lab_received_date;
        

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_rejected_at_the_testing_lab_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_hub
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_hub'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_hub AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_hub';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_received_by_entry_modality_hub = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.lab_received_date 
    WHERE
        ds.entry_modality = 'hub' 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_hub';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_lab
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_lab';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_received_by_entry_modality_lab = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.lab_received_date
    WHERE
        ds.entry_modality = 'lab' 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_tested_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_tested_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_tested_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_tested_on_report_date';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_tested_on_report_date = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.tested_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_tested_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_collected_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_collected_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_collected_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_collected_on_report_date';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_collected_on_report_date = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date = ds.collected_date


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_collected_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_collected
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_collected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_collected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_collected';

-- $BEGIN

    UPDATE fe
        SET
            fe.is_collected = 
            CASE
                WHEN
                    ds.collected_date <= fe.report_date THEN 1
                ELSE 0
            END
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds 
    ON 
        fe.sample_id = ds.sample_id 


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_collected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_accepted_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_accepted_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_accepted_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_accepted_on_report_date';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_accepted_on_report_date = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date = ds.lab_received_date
        AND ds.sample_quality_status ='Accepted'


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_accepted_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_accepted
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_accepted'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_accepted AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_accepted';

-- $BEGIN
    
    UPDATE
        fe
    SET
        fe.is_accepted = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date >= ds.lab_received_date
	WHERE 
	    ds.sample_quality_status ='Accepted';


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_accepted';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_authorized_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_authorized_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_authorized_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_authorized_on_report_date';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_authorized_on_report_date = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date = ds.result_authorized_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_authorized_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_authorized
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_authorized'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_authorized AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_authorized';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_authorized = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date >= ds.result_authorized_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_authorized';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_eid_sample_received_type_dbs
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_eid_sample_received_type_dbs'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_eid_sample_received_type_dbs AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_eid_sample_received_type_dbs';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.eid_sample_received_type_dbs = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.lab_received_date
    WHERE
        ds.sample_type = 'dbs'

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_eid_sample_received_type_dbs';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_result
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_result'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_result';

-- $BEGIN

    UPDATE fe
        SET
            fe.result = ts.Results
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        derived.dim_sample ds 
    ON
        fe.sample_id = ds.sample_id
    INNER JOIN
        [source].tbl_Sample ts 
    ON 
        ts.SampleTrackingId = ds.sample_tracking_id
    AND
        ds.tested_date = fe.report_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_sample_tested_positive
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_positive'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_positive AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_positive';

-- $BEGIN

    UPDATE fe
        SET fe.is_sample_tested_positive = 
            CASE 
                WHEN 
                    LOWER(fe.result) LIKE '%positive%'
                THEN 1 
                ELSE 0 
            END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        fe.result IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_positive';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_sample_tested_negative
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_negative'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_negative AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_negative';

-- $BEGIN

    UPDATE fe
        SET 
            fe.is_sample_tested_negative = 
            CASE 
                WHEN 
                    LOWER(fe.result) LIKE '%negative%' 
                THEN 1 
                ELSE 0 
            END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        fe.result IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_negative';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_indeterminate_result
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_indeterminate_result'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_indeterminate_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_indeterminate_result';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_indeterminate_result = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    WHERE
        fe.is_tested_on_report_date = 1
        AND ISNULL(fe.is_sample_tested_positive,0) != 1
        AND ISNULL(fe.is_sample_tested_negative,0) != 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_indeterminate_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_result_pending
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_result_pending'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_result_pending AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_result_pending';

-- $BEGIN

    UPDATE
        fe
    SET
        fe.is_result_pending = 1
    FROM 
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds
        ON fe.sample_id = ds.sample_id 
        AND fe.report_date >= ds.tested_date
        AND fe.report_date < ds.result_authorized_date ;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_result_pending';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_sample_tested_result_not_detected
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_result_not_detected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_result_not_detected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_result_not_detected';

-- $BEGIN

    UPDATE fe
        SET fe.is_sample_tested_result_not_detected = 
            CASE 
                WHEN 
                    LOWER(REPLACE(fe.result, ' ', '')) = 'targetnotdetected' 
                THEN 1 
                ELSE 0 
            END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        fe.result IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_result_not_detected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_invalid_result
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_invalid_result'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_invalid_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_invalid_result';

-- $BEGIN

UPDATE fe
    SET fe.is_invalid_result = 
        CASE 
            WHEN 
                LOWER(fe.result) = 'invalid' 
            THEN 1 
            ELSE 0 
        END
FROM
    [derived].fact_daily_eid_sample_status fe
WHERE
    fe.result IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_invalid_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_failed_result
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_failed_result'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_failed_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_failed_result';

-- $BEGIN

UPDATE fe
    SET fe.is_failed_result = 
        CASE 
            WHEN 
                fe.result = 'Failed' 
            THEN 1 
            ELSE 0 
        END
FROM
    [derived].fact_daily_eid_sample_status fe
WHERE
    fe.result IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_failed_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_is_dispatched_on_report_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_is_dispatched_on_report_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_is_dispatched_on_report_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_dispatched_on_report_date';

-- $BEGIN

    UPDATE fe
        SET
            fe.is_dispatched_on_report_date = 1
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds 
        ON fe.sample_id = ds.sample_id 
        AND ds.result_dispatched_date = fe.report_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_is_dispatched_on_report_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_received_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_received_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_received_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_received_date';

-- $BEGIN

    UPDATE 
        fe
        SET 
            days_between_sample_collected_and_received_date = 
            DATEDIFF(day, ds.collected_date, ds.lab_received_date)
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds 
        ON fe.sample_id = ds.sample_id
        AND report_date = ds.lab_received_date
        AND ds.collected_date <= ds.lab_received_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_received_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_authorised_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_authorised_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_authorised_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_authorised_date';

-- $BEGIN

    UPDATE 
        fe
        SET 
            fe.days_between_sample_collected_and_authorised_date = 
            DATEDIFF(day, ds.collected_date, ds.result_authorized_date)
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.result_authorized_date
        AND ds.collected_date <= ds.result_authorized_date


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_authorised_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_authorised_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_authorised_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_authorised_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_authorised_date';

-- $BEGIN

    UPDATE 
        fe
        SET 
            days_between_sample_received_and_authorised_date = 
            DATEDIFF(day, ds.lab_received_date, ds.result_authorized_date)
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds 
        ON fe.sample_id = ds.sample_id
        AND report_date = ds.result_authorized_date
        AND ds.lab_received_date <= ds.result_authorized_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_authorised_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_tested_date
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_tested_date'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_tested_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_tested_date';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.days_between_sample_received_and_tested_date = 
        DATEDIFF(day, ds.lab_received_date, ds.tested_date)
    FROM
        derived.fact_daily_eid_sample_status fs
    INNER JOIN
        [derived].dim_sample ds
        ON fs.sample_id = ds.sample_id
        AND fs.report_date = ds.tested_date
    WHERE
        ds.lab_received_date <= ds.tested_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_tested_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_6_to_10_days';

-- $BEGIN

    UPDATE 
            fe
        SET
            fe.sample_collected_and_received_date_between_6_to_10_days = 
                CASE
                    WHEN 
                        days_between_sample_collected_and_received_date >= 6
                        AND days_between_sample_collected_and_received_date <= 10
                    THEN 1
                END
    FROM
       [derived].fact_daily_eid_sample_status fe
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_11_to_15_days';

-- $BEGIN

    UPDATE 
            fe
        SET
            fe.sample_collected_and_received_date_between_11_to_15_days = 
                CASE
                    WHEN 
                        days_between_sample_collected_and_received_date >= 11
                        AND days_between_sample_collected_and_received_date <= 15
                    THEN 1
                END
    FROM
       [derived].fact_daily_eid_sample_status fe
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_greater_than_15_days';

-- $BEGIN

    UPDATE 
            fe
        SET
            fe.sample_collected_and_received_date_greater_than_15_days = 
                CASE
                    WHEN 
                        days_between_sample_collected_and_received_date > 15 THEN 1
                END
    FROM
       [derived].fact_daily_eid_sample_status fe
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_in_less_or_equal_5_days';

-- $BEGIN

	UPDATE 
            fe
    SET
        fe.sample_collected_and_received_date_in_less_or_equal_5_days = 
        CASE
            WHEN
                days_between_sample_collected_and_received_date <= 5 
            THEN 1
            ELSE 0
        END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_received_at_the_testing_lab_on_report_date = 1
        AND days_between_sample_collected_and_received_date IS NOT NULL


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_6_to_10_days';

-- $BEGIN

    UPDATE 
            fe
        SET
            fe.sample_received_and_authorised_date_between_6_to_10_days = 
                CASE
                    WHEN 
                        days_between_sample_received_and_authorised_date >= 6
                        AND days_between_sample_received_and_authorised_date <= 10
                    THEN 1
                END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_11_to_15_days';

-- $BEGIN

    UPDATE 
            fe
        SET
            fe.sample_received_and_authorised_date_between_11_to_15_days = 
                CASE
                    WHEN 
                        days_between_sample_received_and_authorised_date >= 11
                        AND days_between_sample_received_and_authorised_date <= 15
                    THEN 1
                END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_greater_than_15_days';

-- $BEGIN

    UPDATE 
            fe
        SET
            fe.sample_received_and_authorised_date_greater_than_15_days = 
                CASE
                    WHEN 
                        days_between_sample_received_and_authorised_date >= 15 THEN 1
                END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_in_less_or_equal_5_days';

-- $BEGIN

	UPDATE 
            fe
    SET
        fe.sample_received_and_authorised_date_in_less_or_equal_5_days = 
        CASE
            WHEN
                days_between_sample_received_and_authorised_date <= 5 THEN 1
        END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_received_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_in_less_or_equal_10_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_in_less_or_equal_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_in_less_or_equal_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_in_less_or_equal_10_days';

-- $BEGIN

    UPDATE 
        fe
    SET
        fe.sample_collected_and_authorised_date_in_less_or_equal_10_days = 
        CASE
            WHEN
                days_between_sample_collected_and_authorised_date <= 10 
                THEN 1
                ELSE NULL
        END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_collected_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_in_less_or_equal_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_11_to_14_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_11_to_14_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_11_to_14_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_11_to_14_days';

-- $BEGIN

    UPDATE 
        fe
    SET
        fe.sample_collected_and_authorised_date_between_11_to_14_days = 
        CASE
            WHEN 
                days_between_sample_collected_and_authorised_date >= 11
                AND days_between_sample_collected_and_authorised_date <= 14 
                THEN 1
                ELSE NULL
        END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_collected_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_11_to_14_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_15_to_21_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_15_to_21_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_15_to_21_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_15_to_21_days';

-- $BEGIN

    UPDATE 
          fe
        SET
            fe.sample_collected_and_authorised_date_between_15_to_21_days = 
            CASE
                WHEN 
                    days_between_sample_collected_and_authorised_date >= 15
                    AND days_between_sample_collected_and_authorised_date <= 21 THEN 1
            END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_collected_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_15_to_21_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_greater_than_21_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_greater_than_21_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_greater_than_21_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_greater_than_21_days';

-- $BEGIN

    UPDATE 
          fe
        SET
            fe.sample_collected_and_authorised_date_greater_than_21_days = 
            CASE
                WHEN 
                    days_between_sample_collected_and_authorised_date > 21 THEN 1
            END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        is_authorized_on_report_date = 1
        AND days_between_sample_collected_and_authorised_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_greater_than_21_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_in_less_or_equal_5_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_in_less_or_equal_5_days = 
        CASE
            WHEN
                days_between_sample_received_and_tested_date <= 5
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_eid_sample_status fs
    WHERE
        days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_6_to_10_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_between_6_to_10_days = 
        CASE
            WHEN
                days_between_sample_received_and_tested_date >= 6
                AND days_between_sample_received_and_tested_date <= 10
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_eid_sample_status fs
    WHERE
        days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_11_to_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_between_11_to_15_days = 
        CASE
            WHEN
                days_between_sample_received_and_tested_date >= 11
                AND days_between_sample_received_and_tested_date <= 15
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_eid_sample_status fs
    WHERE
        days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_greater_than_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.sample_received_and_tested_date_greater_than_15_days = 
        CASE
            WHEN
                days_between_sample_received_and_tested_date > 15
            THEN 1
            ELSE NULL
        END
    FROM
        derived.fact_daily_eid_sample_status fs
    WHERE
        days_between_sample_received_and_tested_date IS NOT NULL

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_days_in_wait_at_the_lab
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_days_in_wait_at_the_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_days_in_wait_at_the_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_in_wait_at_the_lab';

-- $BEGIN

    UPDATE 
        fe
    SET 
        days_in_wait_at_the_lab = 
            DATEDIFF(DAY,ds.lab_received_date, fe.report_date)
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds 
        ON fe.sample_id = ds.sample_id
        AND fe.report_date <= ds.tested_date 
		AND fe.report_date >= ds.lab_received_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_in_wait_at_the_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_days_waited_at_the_lab
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_days_waited_at_the_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_days_waited_at_the_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_waited_at_the_lab';

-- $BEGIN

    UPDATE 
        fe
    SET 
        days_waited_at_the_lab = 
            DATEDIFF(DAY,ds.lab_received_date, ds.tested_date)
    FROM
        [derived].fact_daily_eid_sample_status fe
    INNER JOIN
        [derived].dim_sample ds 
        ON fe.sample_id = ds.sample_id
        AND fe.report_date = ds.tested_date 
		AND ds.tested_date >= ds.lab_received_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_days_waited_at_the_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status_update_sample_aging
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status_update_sample_aging'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status_update_sample_aging AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_aging';

-- $BEGIN

	UPDATE fe
        SET
            fe.is_less_than_or_equal_to_7_days_aging = 
                CASE
                    WHEN
                        fe.days_in_wait_at_the_lab <=7  
                    THEN 1
                    ELSE 0
                END,
			fe.is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging =
                CASE
                    WHEN
                        fe.days_in_wait_at_the_lab >7
                        AND fe.days_in_wait_at_the_lab <=14  
                    THEN 1
                    ELSE 0
                END,
			fe.is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging = 
                CASE
                    WHEN
                        fe.days_in_wait_at_the_lab > 14 
                        AND fe.days_in_wait_at_the_lab <= 21 
                    THEN 1
                    ELSE 0
                END,
			fe.is_greater_than_21_days_aging = 
                CASE
                    WHEN
                        fe.days_in_wait_at_the_lab > 21 
                    THEN 1
                    ELSE 0
                END
    FROM
        [derived].fact_daily_eid_sample_status fe
    WHERE
        fe.days_in_wait_at_the_lab IS NOT NULL
        AND fe.is_tested_on_report_date = 1


-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status_update_sample_aging';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_eid_sample_status
--

PRINT 'Creating derived.sp_fact_daily_eid_sample_status'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_daily_eid_sample_status AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_daily_eid_sample_status';

-- $BEGIN

    EXEC derived.sp_fact_daily_eid_sample_status_create;
    EXEC derived.sp_fact_daily_eid_sample_status_insert;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_received_at_the_testing_lab_on_report_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_rejected_at_the_testing_lab_on_report_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_hub;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_received_by_entry_modality_lab;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_tested_on_report_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_collected_on_report_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_collected;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_accepted_on_report_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_accepted;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_authorized_on_report_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_authorized;
    EXEC derived.sp_fact_daily_eid_sample_status_update_eid_sample_received_type_dbs;
    EXEC derived.sp_fact_daily_eid_sample_status_update_result;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_positive;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_negative;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_indeterminate_result;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_result_pending;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_sample_tested_result_not_detected;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_invalid_result;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_failed_result;
    EXEC derived.sp_fact_daily_eid_sample_status_update_is_dispatched_on_report_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_received_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_days_between_sample_collected_and_authorised_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_authorised_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_days_between_sample_received_and_tested_date;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_6_to_10_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_between_11_to_15_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_greater_than_15_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_received_date_in_less_or_equal_5_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_6_to_10_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_between_11_to_15_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_greater_than_15_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_authorised_date_in_less_or_equal_5_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_in_less_or_equal_10_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_11_to_14_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_between_15_to_21_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_collected_and_authorised_date_greater_than_21_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_in_less_or_equal_5_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_6_to_10_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_between_11_to_15_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_received_and_tested_date_greater_than_15_days;
    EXEC derived.sp_fact_daily_eid_sample_status_update_days_in_wait_at_the_lab;
    EXEC derived.sp_fact_daily_eid_sample_status_update_days_waited_at_the_lab;
    EXEC derived.sp_fact_daily_eid_sample_status_update_sample_aging;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_daily_eid_sample_status';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_data_processing
--

PRINT 'Creating derived.sp_data_processing'
GO

CREATE OR ALTER PROCEDURE derived.sp_data_processing AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_data_processing';

-- $BEGIN

PRINT 'Dropping Foreign Keys'
EXEC dbo.sp_xf_system_drop_all_foreign_keys_in_schema 'derived'

PRINT 'Dropping tables'
EXEC dbo.sp_xf_system_drop_all_tables_in_schema 'derived'

EXEC derived.sp_dim_facility;
EXEC derived.sp_dim_date;
EXEC derived.sp_dim_commodity;
EXEC derived.sp_dim_device;
EXEC derived.sp_dim_sample;
EXEC derived.sp_fact_daily_commodity_status;
EXEC derived.sp_fact_daily_device_status;
EXEC derived.sp_fact_daily_eid_sample_status;
EXEC derived.sp_fact_daily_hvl_sample_status;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_data_processing';

END
GO
USE lab_visual_analysis
GO
PRINT 'clearing all stored procedures in final'
EXEC dbo.sp_xf_system_drop_all_stored_procedures_in_schema 'final' 
GO

        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_create
--

PRINT 'Creating final.sp_fact_daily_sample_summary_create'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_create';

-- $BEGIN

    CREATE TABLE final.fact_daily_sample_summary(
        daily_sample_summary_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
        report_date DATE NOT NULL,
        hfr_id_for_HUB_sample_is_coming_from NVARCHAR(255) NOT NULL,
        hvl_sample_collected INT NULL DEFAULT 0,
        eid_sample_collected INT NULL DEFAULT 0,
        sample_collected INT NULL DEFAULT 0,
        hvl_sample_plasma_received INT NULL DEFAULT 0,
        hvl_sample_wholeblood_received INT NULL DEFAULT 0,
        hvl_sample_received INT NULL DEFAULT 0,
        eid_sample_dbs_received INT NULL DEFAULT 0,
        hvl_samples_received_by_entry_modality_lab INT NULL DEFAULT 0,
        hvl_samples_received_by_entry_modality_hub INT NULL DEFAULT 0,
        eid_samples_received_by_entry_modality_lab INT NULL DEFAULT 0,
        eid_samples_received_by_entry_modality_hub INT NULL DEFAULT 0,
        sample_received INT NULL DEFAULT 0,
        hvl_sample_accepted INT NULL DEFAULT 0,
        eid_sample_accepted INT NULL DEFAULT 0,
        sample_accepted INT NULL DEFAULT 0,
        hvl_sample_rejected INT NULL DEFAULT 0,
        eid_sample_rejected INT NULL DEFAULT 0,
        sample_rejected INT NULL DEFAULT 0,
        eid_sample_tested INT NULL DEFAULT 0, 
        hvl_sample_tested INT NULL DEFAULT 0,
        sample_tested INT NULL DEFAULT 0,
        hvl_result_pending INT NULL DEFAULT 0,
        eid_result_pending INT NULL DEFAULT 0,
        result_pending INT NULL DEFAULT 0,
        hvl_result_authorized INT NULL DEFAULT 0,
        eid_result_authorized INT NULL DEFAULT 0,
        result_authorized INT NULL DEFAULT 0,
        hvl_result_dispatched INT NULL DEFAULT 0,
        eid_result_dispatched INT NULL DEFAULT 0,
        result_dispatched INT NULL DEFAULT 0,
        hvl_result_rejected INT NULL DEFAULT 0,
        eid_result_rejected INT NULL DEFAULT 0,
        result_rejected INT NULL DEFAULT 0,
        hvl_result_accepted INT NULL DEFAULT 0,
        eid_result_accepted INT NULL DEFAULT 0,
        result_accepted INT NULL DEFAULT 0,
        hvl_result_invalid INT NULL DEFAULT 0,
        eid_result_invalid INT NULL DEFAULT 0,
        result_invalid INT NULL DEFAULT 0,
        hvl_result_failed INT NULL DEFAULT 0,
        eid_result_failed INT NULL DEFAULT 0,
        result_failed INT NULL DEFAULT 0,
        hvl_result_tnd INT NULL DEFAULT 0,
        eid_result_tnd INT NULL DEFAULT 0,
        result_tnd INT NULL DEFAULT 0,
        result_indeterminate INT NULL DEFAULT 0,
        hvl_samples_with_results_equal_or_above_1000 INT NULL DEFAULT 0,
        hvl_samples_with_results_less_than_1000_or_above_50 INT NULL DEFAULT 0,
        hvl_samples_with_results_less_than_50 INT NULL DEFAULT 0,
        eid_sample_tested_positive INT NULL DEFAULT 0,
        eid_sample_tested_negative INT NULL DEFAULT 0,
        eid_sample_tested_result_not_detected INT NULL DEFAULT 0,
        hvl_samples_aging_is_less_than_or_equal_to_7_days INT NULL DEFAULT 0,
        hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days INT NULL DEFAULT 0,
        hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days INT NULL DEFAULT 0,
        hvl_samples_aging_is_greater_than_21_days INT NULL DEFAULT 0,
        eid_samples_aging_less_than_or_equal_to_7_days_aging INT NULL DEFAULT 0,
        eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging INT NULL DEFAULT 0,
        eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging INT NULL DEFAULT 0,
        eid_samples_greater_than_21_days_aging INT NULL DEFAULT 0,
        hvl_sample_collected_and_received_date_in_less_or_equal_5_days INT NULL DEFAULT 0,
        hvl_sample_collected_and_received_date_between_6_to_10_days INT NULL DEFAULT 0,
        hvl_sample_collected_and_received_date_between_11_to_15_days INT NULL DEFAULT 0,
        hvl_sample_collected_and_received_date_greater_than_15_days INT NULL DEFAULT 0,
        eid_sample_collected_and_received_date_in_less_or_equal_5_days INT NULL DEFAULT 0,
        eid_sample_collected_and_received_date_between_6_to_10_days INT NULL DEFAULT 0,
        eid_sample_collected_and_received_date_between_11_to_15_days INT NULL DEFAULT 0,
        eid_sample_collected_and_received_date_greater_than_15_days INT NULL DEFAULT 0,
        hvl_sample_received_and_authorised_date_in_less_or_equal_5_days INT NULL DEFAULT 0,
        hvl_sample_received_and_authorised_date_between_6_to_10_days INT NULL DEFAULT 0,
        hvl_sample_received_and_authorised_date_between_11_to_15_days INT NULL DEFAULT 0,
        hvl_sample_received_and_authorised_date_greater_than_15_days INT NULL DEFAULT 0,
        eid_sample_received_and_authorised_date_in_less_or_equal_5_days INT NULL DEFAULT 0,
        eid_sample_received_and_authorised_date_between_6_to_10_days INT NULL DEFAULT 0,
        eid_sample_received_and_authorised_date_between_11_to_15_days INT NULL DEFAULT 0,
        eid_sample_received_and_authorised_date_greater_than_15_days INT NULL DEFAULT 0,
        hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days INT NULL DEFAULT 0,
        hvl_sample_collected_and_authorised_date_between_11_to_14_days INT NULL DEFAULT 0,
        hvl_sample_collected_and_authorised_date_between_15_to_21_days INT NULL DEFAULT 0,
        hvl_sample_collected_and_authorised_date_greater_than_21_days INT NULL DEFAULT 0,
        eid_sample_collected_and_authorised_date_in_less_or_equal_10_days INT NULL DEFAULT 0,
        eid_sample_collected_and_authorised_date_between_11_to_14_days INT NULL DEFAULT 0,
        eid_sample_collected_and_authorised_date_between_15_to_21_days INT NULL DEFAULT 0,
        eid_sample_collected_and_authorised_date_greater_than_21_days INT NULL DEFAULT 0,
        hvl_sample_received_and_tested_date_in_less_or_equal_5_days INT NULL DEFAULT 0,
        hvl_sample_received_and_tested_date_between_6_to_10_days INT NULL DEFAULT 0,
        hvl_sample_received_and_tested_date_between_11_to_15_days INT NULL DEFAULT 0,
        hvl_sample_received_and_tested_date_greater_than_15_days INT NULL DEFAULT 0,
        eid_sample_received_and_tested_date_in_less_or_equal_5_days INT NULL DEFAULT 0,
        eid_sample_received_and_tested_date_between_6_to_10_days INT NULL DEFAULT 0,
        eid_sample_received_and_tested_date_between_11_to_15_days INT NULL DEFAULT 0,
        eid_sample_received_and_tested_date_greater_than_15_days INT NULL DEFAULT 0,
        hvl_sample_plasma_rejected INT NULL DEFAULT 0,
        hvl_sample_wholeblood_rejected INT NULL DEFAULT 0,
        hvl_sample_plasma_tested INT NULL DEFAULT 0,
        hvl_sample_wholeblood_tested INT NULL DEFAULT 0,
        hvl_sample_plasma_dispatched INT NULL DEFAULT 0,
        hvl_sample_wholeblood_dispatched INT NULL DEFAULT 0
    );

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_insert
--

PRINT 'Creating final.sp_fact_daily_sample_summary_insert'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_insert';

-- $BEGIN

	INSERT INTO [final].fact_daily_sample_summary 
	(
		report_date,
		hfr_id_for_HUB_sample_is_coming_from
	)
	SELECT 
		dd.[date] AS report_date,
		df.hfr_code AS hfr_id_for_HUB_sample_is_coming_from
	FROM 
		[derived].dim_date dd 
	CROSS JOIN
		[derived].dim_facility df;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_eid_samples
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_eid_samples'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_eid_samples AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_eid_samples';

-- $BEGIN

	WITH cte_eid_samples AS
		(
		SELECT 
			eid.report_date AS report_date,
			eid.[_hfr_id] AS hfr_id_for_HUB_sample_is_coming_from,
			SUM(ISNULL(eid.is_collected_on_report_date, 0)) AS eid_sample_collected,
			SUM(ISNULL(eid.eid_sample_received_type_dbs, 0)) AS eid_sample_dbs_received,
			SUM(ISNULL(eid.is_accepted_on_report_date, 0)) AS eid_sample_accepted,
			SUM(ISNULL(eid.is_rejected_at_the_testing_lab_on_report_date, 0)) AS eid_sample_rejected,
			SUM(ISNULL(eid.is_tested_on_report_date, 0)) AS eid_sample_tested,
			SUM(ISNULL(eid.is_result_pending, 0)) AS eid_result_pending,
			SUM(ISNULL(eid.is_authorized_on_report_date, 0)) AS eid_result_authorized,
			SUM(ISNULL(eid.is_dispatched_on_report_date, 0)) AS eid_result_dispatched,
			SUM(ISNULL(eid.is_invalid_result, 0) + ISNULL(eid.is_failed_result, 0)) AS eid_result_rejected,
			SUM(ISNULL(eid.is_authorized_on_report_date, 0)) AS eid_result_accepted,
			SUM(ISNULL(eid.is_invalid_result, 0)) AS eid_result_invalid,
			SUM(ISNULL(eid.is_failed_result, 0)) AS eid_result_failed,
			SUM(ISNULL(eid.is_sample_tested_result_not_detected, 0)) AS eid_result_tnd,
			SUM(ISNULL(eid.is_indeterminate_result, 0)) AS result_indeterminate,
			SUM(ISNULL(eid.is_sample_tested_negative, 0)) AS eid_sample_tested_negative,
			SUM(ISNULL(eid.is_sample_tested_positive, 0)) AS eid_sample_tested_positive,
			SUM(ISNULL(eid.is_received_by_entry_modality_hub, 0)) AS eid_samples_received_by_entry_modality_hub,
			SUM(ISNULL(eid.is_received_by_entry_modality_lab, 0)) AS eid_samples_received_by_entry_modality_lab,
			SUM(ISNULL(eid.is_sample_tested_result_not_detected, 0)) AS eid_sample_tested_result_not_detected,
			SUM(ISNULL(eid.is_less_than_or_equal_to_7_days_aging, 0)) AS eid_samples_aging_less_than_or_equal_to_7_days_aging,
			SUM(ISNULL(eid.is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging, 0)) AS eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging,
			SUM(ISNULL(eid.is_greater_than_21_days_aging, 0)) AS eid_samples_greater_than_21_days_aging,
			SUM(ISNULL(eid.is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging, 0)) AS eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging,
			SUM(ISNULL(eid.sample_collected_and_received_date_between_6_to_10_days, 0)) AS eid_sample_collected_and_received_date_between_6_to_10_days,
			SUM(ISNULL(eid.sample_collected_and_received_date_between_11_to_15_days, 0)) AS eid_sample_collected_and_received_date_between_11_to_15_days,
			SUM(ISNULL(eid.sample_collected_and_received_date_greater_than_15_days, 0)) AS eid_sample_collected_and_received_date_greater_than_15_days,
			SUM(ISNULL(eid.sample_collected_and_received_date_in_less_or_equal_5_days, 0)) AS eid_sample_collected_and_received_date_in_less_or_equal_5_days,
			SUM(ISNULL(eid.sample_received_and_authorised_date_between_6_to_10_days, 0)) AS eid_sample_received_and_authorised_date_between_6_to_10_days,
			SUM(ISNULL(eid.sample_received_and_authorised_date_between_11_to_15_days, 0)) AS eid_sample_received_and_authorised_date_between_11_to_15_days,
			SUM(ISNULL(eid.sample_received_and_authorised_date_greater_than_15_days, 0)) AS eid_sample_received_and_authorised_date_greater_than_15_days,
			SUM(ISNULL(eid.sample_received_and_authorised_date_in_less_or_equal_5_days, 0)) AS eid_sample_received_and_authorised_date_in_less_or_equal_5_days,
			SUM(ISNULL(eid.sample_collected_and_authorised_date_between_11_to_14_days, 0)) AS eid_sample_collected_and_authorised_date_between_11_to_14_days,
			SUM(ISNULL(eid.sample_collected_and_authorised_date_between_15_to_21_days, 0)) AS eid_sample_collected_and_authorised_date_between_15_to_21_days,
			SUM(ISNULL(eid.sample_collected_and_authorised_date_greater_than_21_days, 0)) AS eid_sample_collected_and_authorised_date_greater_than_21_days,
			SUM(ISNULL(eid.sample_collected_and_authorised_date_in_less_or_equal_10_days, 0)) AS eid_sample_collected_and_authorised_date_in_less_or_equal_10_days,
			SUM(ISNULL(eid.sample_received_and_tested_date_in_less_or_equal_5_days, 0)) AS eid_sample_received_and_tested_date_in_less_or_equal_5_days,
			SUM(ISNULL(eid.sample_received_and_tested_date_between_6_to_10_days, 0)) AS eid_sample_received_and_tested_date_between_6_to_10_days,
			SUM(ISNULL(eid.sample_received_and_tested_date_between_11_to_15_days, 0)) AS eid_sample_received_and_tested_date_between_11_to_15_days,
			SUM(ISNULL(eid.sample_received_and_tested_date_greater_than_15_days, 0)) AS eid_sample_received_and_tested_date_greater_than_15_days
		FROM 
			[derived].fact_daily_eid_sample_status eid
		GROUP BY
			eid.report_date, 
			eid.[_hfr_id]
		)
	UPDATE
		fs
	SET
		fs.eid_sample_collected = ISNULL(eid.eid_sample_collected, 0),
		fs.eid_sample_dbs_received = ISNULL(eid.eid_sample_dbs_received, 0),
		fs.eid_sample_accepted = ISNULL(eid.eid_sample_accepted, 0),
		fs.eid_sample_rejected = ISNULL(eid.eid_sample_rejected, 0),
		fs.eid_sample_tested = ISNULL(eid.eid_sample_tested, 0),
		fs.eid_result_pending = ISNULL(eid.eid_result_pending, 0),
		fs.eid_result_authorized = ISNULL(eid.eid_result_authorized, 0),
		fs.eid_result_dispatched = ISNULL(eid.eid_result_dispatched, 0),
		fs.eid_result_rejected = ISNULL(eid.eid_result_rejected, 0),
		fs.eid_result_accepted = ISNULL(eid.eid_result_accepted, 0),
		fs.eid_result_invalid = ISNULL(eid.eid_result_invalid, 0),
		fs.eid_result_failed = ISNULL(eid.eid_result_failed, 0),
		fs.eid_result_tnd = ISNULL(eid.eid_result_tnd, 0),
		fs.result_indeterminate = ISNULL(eid.result_indeterminate, 0),
		fs.eid_sample_tested_negative = ISNULL(eid.eid_sample_tested_negative, 0),
		fs.eid_sample_tested_positive = ISNULL(eid.eid_sample_tested_positive, 0),
		fs.eid_samples_received_by_entry_modality_hub = ISNULL(eid.eid_samples_received_by_entry_modality_hub, 0),
		fs.eid_samples_received_by_entry_modality_lab = ISNULL(eid.eid_samples_received_by_entry_modality_lab, 0),
		fs.eid_sample_tested_result_not_detected = ISNULL(eid.eid_sample_tested_result_not_detected, 0),
		fs.eid_samples_aging_less_than_or_equal_to_7_days_aging = ISNULL(eid.eid_samples_aging_less_than_or_equal_to_7_days_aging, 0),
		fs.eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging = ISNULL(eid.eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging, 0),
		fs.eid_samples_greater_than_21_days_aging = ISNULL(eid.eid_samples_greater_than_21_days_aging, 0),
		fs.eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging = ISNULL(eid.eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging, 0),
		fs.eid_sample_collected_and_received_date_between_6_to_10_days = ISNULL(eid.eid_sample_collected_and_received_date_between_6_to_10_days, 0),
		fs.eid_sample_collected_and_received_date_between_11_to_15_days = ISNULL(eid.eid_sample_collected_and_received_date_between_11_to_15_days, 0),
		fs.eid_sample_collected_and_received_date_greater_than_15_days = ISNULL(eid.eid_sample_collected_and_received_date_greater_than_15_days, 0),
		fs.eid_sample_collected_and_received_date_in_less_or_equal_5_days = ISNULL(eid.eid_sample_collected_and_received_date_in_less_or_equal_5_days, 0),
		fs.eid_sample_received_and_authorised_date_between_6_to_10_days = ISNULL(eid.eid_sample_received_and_authorised_date_between_6_to_10_days, 0),
		fs.eid_sample_received_and_authorised_date_between_11_to_15_days = ISNULL(eid.eid_sample_received_and_authorised_date_between_11_to_15_days, 0),
		fs.eid_sample_received_and_authorised_date_greater_than_15_days = ISNULL(eid.eid_sample_received_and_authorised_date_greater_than_15_days, 0),
		fs.eid_sample_received_and_authorised_date_in_less_or_equal_5_days = ISNULL(eid.eid_sample_received_and_authorised_date_in_less_or_equal_5_days, 0),
		fs.eid_sample_collected_and_authorised_date_between_11_to_14_days = ISNULL(eid.eid_sample_collected_and_authorised_date_between_11_to_14_days, 0),
		fs.eid_sample_collected_and_authorised_date_between_15_to_21_days = ISNULL(eid.eid_sample_collected_and_authorised_date_between_15_to_21_days, 0),
		fs.eid_sample_collected_and_authorised_date_greater_than_21_days = ISNULL(eid.eid_sample_collected_and_authorised_date_greater_than_21_days, 0),
		fs.eid_sample_collected_and_authorised_date_in_less_or_equal_10_days = ISNULL(eid.eid_sample_collected_and_authorised_date_in_less_or_equal_10_days, 0),
		fs.eid_sample_received_and_tested_date_in_less_or_equal_5_days = ISNULL(eid.eid_sample_received_and_tested_date_in_less_or_equal_5_days, 0),
		fs.eid_sample_received_and_tested_date_between_6_to_10_days = ISNULL(eid.eid_sample_received_and_tested_date_between_6_to_10_days, 0),
		fs.eid_sample_received_and_tested_date_between_11_to_15_days = ISNULL(eid.eid_sample_received_and_tested_date_between_11_to_15_days, 0),
		fs.eid_sample_received_and_tested_date_greater_than_15_days = ISNULL(eid.eid_sample_received_and_tested_date_greater_than_15_days, 0)
	FROM
		[final].fact_daily_sample_summary fs
	LEFT JOIN
		cte_eid_samples eid
		ON fs.report_date = eid.report_date
		AND fs.hfr_id_for_HUB_sample_is_coming_from = eid.hfr_id_for_HUB_sample_is_coming_from;
			
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_eid_samples';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_hvl_samples
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_hvl_samples'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_hvl_samples AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_hvl_samples';

-- $BEGIN

	WITH CTE_hvl_samples AS 
		(
			SELECT 
				hvl.report_date,
				hvl.[_hfr_id] AS hfr_id_for_HUB_sample_is_coming_from,
				SUM(ISNULL(hvl.is_collected_on_report_date, 0)) AS hvl_sample_collected,
				SUM(ISNULL(hvl.hvl_sample_received_type_plasma, 0)) AS hvl_sample_plasma_received,
				SUM(ISNULL(hvl.hvl_sample_received_type_wholeblood, 0)) AS hvl_sample_wholeblood_received,
				SUM(ISNULL(hvl.hvl_sample_received_type_wholeblood, 0) + ISNULL(hvl.hvl_sample_received_type_plasma, 0)) AS hvl_sample_received,
				SUM(ISNULL(hvl.is_accepted_on_report_date, 0)) AS hvl_sample_accepted,
				SUM(ISNULL(hvl.hvl_plasma_rejected_at_the_testing_lab, 0)) AS hvl_sample_plasma_rejected,
				SUM(ISNULL(hvl.hvl_wholeblood_rejected_at_the_testing_lab, 0)) AS hvl_sample_wholeblood_rejected,
				SUM(ISNULL(hvl.is_rejected_at_the_testing_lab_on_report_date, 0)) AS hvl_sample_rejected,
				SUM(ISNULL(hvl.hvl_plasma_tested_at_the_testing_lab, 0)) AS hvl_sample_plasma_tested,
				SUM(ISNULL(hvl.hvl_wholeblood_tested_at_the_testing_lab, 0)) AS hvl_sample_wholeblood_tested,
				SUM(ISNULL(hvl.is_tested_on_report_date, 0)) AS hvl_sample_tested,
				SUM(ISNULL(hvl.is_result_pending, 0)) AS hvl_result_pending,
				SUM(ISNULL(hvl.is_authorized_on_report_date, 0)) AS hvl_result_authorized,
				SUM(ISNULL(hvl.hvl_plasma_dispatched, 0)) AS hvl_sample_plasma_dispatched,
				SUM(ISNULL(hvl.hvl_wholeblood_dispatched, 0)) AS hvl_sample_wholeblood_dispatched,
				SUM(ISNULL(hvl.is_dispatched_on_report_date, 0)) AS hvl_result_dispatched,
				SUM(ISNULL(hvl.is_invalid_result, 0) + ISNULL(hvl.is_failed_result, 0)) AS hvl_result_rejected,
				SUM(ISNULL(hvl.is_authorized_on_report_date, 0)) AS hvl_result_accepted,
				SUM(ISNULL(hvl.is_invalid_result, 0)) AS hvl_result_invalid,
				SUM(ISNULL(hvl.is_failed_result, 0)) AS hvl_result_failed,
				SUM(ISNULL(hvl.is_target_not_detected, 0)) AS hvl_result_tnd,
				SUM(ISNULL(hvl.is_received_by_entry_modality_hub, 0)) AS hvl_samples_received_by_entry_modality_hub,
				SUM(ISNULL(hvl.is_received_by_entry_modality_lab, 0)) AS hvl_samples_received_by_entry_modality_lab,
				SUM(ISNULL(hvl.samples_tested_with_results_equal_or_above_1000, 0)) AS hvl_samples_with_results_equal_or_above_1000,
				SUM(ISNULL(hvl.samples_tested_with_results_less_than_50, 0)) AS hvl_samples_with_results_less_than_50,
				SUM(ISNULL(hvl.samples_tested_with_results_less_than_1000_or_above_50, 0)) AS hvl_samples_with_results_less_than_1000_or_above_50,
				SUM(ISNULL(hvl.is_less_than_or_equal_to_7_days_aging, 0)) AS hvl_samples_aging_is_less_than_or_equal_to_7_days,
				SUM(ISNULL(hvl.is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging, 0)) AS hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days,
				SUM(ISNULL(hvl.is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging, 0)) AS hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days,
				SUM(ISNULL(hvl.is_greater_than_21_days_aging, 0)) AS hvl_samples_aging_is_greater_than_21_days,
				SUM(ISNULL(hvl.sample_collected_and_received_date_between_6_to_10_days, 0)) AS hvl_sample_collected_and_received_date_between_6_to_10_days,
				SUM(ISNULL(hvl.sample_collected_and_received_date_between_11_to_15_days, 0)) AS hvl_sample_collected_and_received_date_between_11_to_15_days,
				SUM(ISNULL(hvl.sample_collected_and_received_date_greater_than_15_days, 0)) AS hvl_sample_collected_and_received_date_greater_than_15_days,
				SUM(ISNULL(hvl.sample_collected_and_received_date_in_less_or_equal_5_days, 0)) AS hvl_sample_collected_and_received_date_in_less_or_equal_5_days,
				SUM(ISNULL(hvl.sample_received_and_authorised_date_between_6_to_10_days, 0)) AS hvl_sample_received_and_authorised_date_between_6_to_10_days,
				SUM(ISNULL(hvl.sample_received_and_authorised_date_between_11_to_15_days, 0)) AS hvl_sample_received_and_authorised_date_between_11_to_15_days,
				SUM(ISNULL(hvl.sample_received_and_authorised_date_greater_than_15_days, 0)) AS hvl_sample_received_and_authorised_date_greater_than_15_days,
				SUM(ISNULL(hvl.sample_received_and_authorised_date_in_less_or_equal_5_days, 0)) AS hvl_sample_received_and_authorised_date_in_less_or_equal_5_days,
				SUM(ISNULL(hvl.sample_collected_and_authorised_date_between_11_to_14_days, 0)) AS hvl_sample_collected_and_authorised_date_between_11_to_14_days,
				SUM(ISNULL(hvl.sample_collected_and_authorised_date_between_15_to_21_days, 0)) AS hvl_sample_collected_and_authorised_date_between_15_to_21_days,
				SUM(ISNULL(hvl.sample_collected_and_authorised_date_greater_than_21_days, 0)) AS hvl_sample_collected_and_authorised_date_greater_than_21_days,
				SUM(ISNULL(hvl.sample_collected_and_authorised_date_in_less_or_equal_10_days, 0)) AS hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days,
				SUM(ISNULL(hvl.sample_received_and_tested_date_in_less_or_equal_5_days, 0)) AS hvl_sample_received_and_tested_date_in_less_or_equal_5_days,
				SUM(ISNULL(hvl.sample_received_and_tested_date_between_6_to_10_days, 0)) AS hvl_sample_received_and_tested_date_between_6_to_10_days,
				SUM(ISNULL(hvl.sample_received_and_tested_date_between_11_to_15_days, 0)) AS hvl_sample_received_and_tested_date_between_11_to_15_days,
				SUM(ISNULL(hvl.sample_received_and_tested_date_greater_than_15_days, 0)) AS hvl_sample_received_and_tested_date_greater_than_15_days
			FROM 
				[derived].fact_daily_hvl_sample_status hvl
			GROUP BY
				hvl.report_date, 
				hvl.[_hfr_id]
		)
	UPDATE
		fs
	SET
		fs.hvl_sample_collected = ISNULL(hvl.hvl_sample_collected, 0),
		fs.hvl_sample_plasma_received = ISNULL(hvl.hvl_sample_plasma_received, 0),
		fs.hvl_sample_wholeblood_received = ISNULL(hvl.hvl_sample_wholeblood_received, 0),
		fs.hvl_sample_received = ISNULL(hvl.hvl_sample_received, 0),
		fs.hvl_sample_accepted = ISNULL(hvl.hvl_sample_accepted, 0),
		fs.hvl_sample_plasma_rejected = ISNULL(hvl.hvl_sample_plasma_rejected, 0),
		fs.hvl_sample_wholeblood_rejected = ISNULL(hvl.hvl_sample_wholeblood_rejected, 0),
		fs.hvl_sample_rejected = ISNULL(hvl.hvl_sample_rejected, 0),
		fs.hvl_sample_plasma_tested = ISNULL(hvl.hvl_sample_plasma_tested, 0),
		fs.hvl_sample_wholeblood_tested = ISNULL(hvl.hvl_sample_wholeblood_tested, 0),
		fs.hvl_sample_tested = ISNULL(hvl.hvl_sample_tested, 0),
		fs.hvl_result_pending = ISNULL(hvl.hvl_result_pending, 0),
		fs.hvl_result_authorized = ISNULL(hvl.hvl_result_authorized, 0),
		fs.hvl_sample_plasma_dispatched = ISNULL(hvl.hvl_sample_plasma_dispatched, 0),
		fs.hvl_sample_wholeblood_dispatched = ISNULL(hvl.hvl_sample_wholeblood_dispatched, 0),
		fs.hvl_result_dispatched = ISNULL(hvl.hvl_result_dispatched, 0),
		fs.hvl_result_rejected = ISNULL(hvl.hvl_result_rejected, 0),
		fs.hvl_result_accepted = ISNULL(hvl.hvl_result_accepted, 0),
		fs.hvl_result_invalid = ISNULL(hvl.hvl_result_invalid, 0),
		fs.hvl_result_failed = ISNULL(hvl.hvl_result_failed, 0),
		fs.hvl_result_tnd = ISNULL(hvl.hvl_result_tnd, 0),
		fs.hvl_samples_received_by_entry_modality_hub = ISNULL(hvl.hvl_samples_received_by_entry_modality_hub, 0),
		fs.hvl_samples_received_by_entry_modality_lab = ISNULL(hvl.hvl_samples_received_by_entry_modality_lab, 0),
		fs.hvl_samples_with_results_equal_or_above_1000 = ISNULL(hvl.hvl_samples_with_results_equal_or_above_1000, 0),
		fs.hvl_samples_with_results_less_than_50 = ISNULL(hvl.hvl_samples_with_results_less_than_50, 0),
		fs.hvl_samples_with_results_less_than_1000_or_above_50 = ISNULL(hvl.hvl_samples_with_results_less_than_1000_or_above_50, 0),
		fs.hvl_samples_aging_is_less_than_or_equal_to_7_days = ISNULL(hvl.hvl_samples_aging_is_less_than_or_equal_to_7_days, 0),
		fs.hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days = ISNULL(hvl.hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days, 0),
		fs.hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days = ISNULL(hvl.hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days, 0),
		fs.hvl_samples_aging_is_greater_than_21_days = ISNULL(hvl.hvl_samples_aging_is_greater_than_21_days, 0),
		fs.hvl_sample_collected_and_received_date_between_6_to_10_days = ISNULL(hvl.hvl_sample_collected_and_received_date_between_6_to_10_days, 0),
		fs.hvl_sample_collected_and_received_date_between_11_to_15_days = ISNULL(hvl.hvl_sample_collected_and_received_date_between_11_to_15_days, 0),
		fs.hvl_sample_collected_and_received_date_greater_than_15_days = ISNULL(hvl.hvl_sample_collected_and_received_date_greater_than_15_days, 0),
		fs.hvl_sample_collected_and_received_date_in_less_or_equal_5_days = ISNULL(hvl.hvl_sample_collected_and_received_date_in_less_or_equal_5_days, 0),
		fs.hvl_sample_received_and_authorised_date_between_6_to_10_days = ISNULL(hvl.hvl_sample_received_and_authorised_date_between_6_to_10_days, 0),
		fs.hvl_sample_received_and_authorised_date_between_11_to_15_days = ISNULL(hvl.hvl_sample_received_and_authorised_date_between_11_to_15_days, 0),
		fs.hvl_sample_received_and_authorised_date_greater_than_15_days = ISNULL(hvl.hvl_sample_received_and_authorised_date_greater_than_15_days, 0),
		fs.hvl_sample_received_and_authorised_date_in_less_or_equal_5_days = ISNULL(hvl.hvl_sample_received_and_authorised_date_in_less_or_equal_5_days, 0),
		fs.hvl_sample_collected_and_authorised_date_between_11_to_14_days = ISNULL(hvl.hvl_sample_collected_and_authorised_date_between_11_to_14_days, 0),
		fs.hvl_sample_collected_and_authorised_date_between_15_to_21_days = ISNULL(hvl.hvl_sample_collected_and_authorised_date_between_15_to_21_days, 0),
		fs.hvl_sample_collected_and_authorised_date_greater_than_21_days = ISNULL(hvl.hvl_sample_collected_and_authorised_date_greater_than_21_days, 0),
		fs.hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days = ISNULL(hvl.hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days, 0),
		fs.hvl_sample_received_and_tested_date_in_less_or_equal_5_days = ISNULL(hvl.hvl_sample_received_and_tested_date_in_less_or_equal_5_days, 0),
		fs.hvl_sample_received_and_tested_date_between_6_to_10_days = ISNULL(hvl.hvl_sample_received_and_tested_date_between_6_to_10_days, 0),
		fs.hvl_sample_received_and_tested_date_between_11_to_15_days = ISNULL(hvl.hvl_sample_received_and_tested_date_between_11_to_15_days, 0),
		fs.hvl_sample_received_and_tested_date_greater_than_15_days = ISNULL(hvl.hvl_sample_received_and_tested_date_greater_than_15_days, 0)	
	FROM
		[final].fact_daily_sample_summary fs
	LEFT JOIN
		CTE_hvl_samples hvl
		ON fs.report_date = hvl.report_date 
		AND fs.hfr_id_for_HUB_sample_is_coming_from = hvl.hfr_id_for_HUB_sample_is_coming_from;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_hvl_samples';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_hvl_sample_received
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_hvl_sample_received'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_hvl_sample_received AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_hvl_sample_received';

-- $BEGIN

	UPDATE
        final.fact_daily_sample_summary
    SET 
        hvl_sample_received = hvl_sample_plasma_received + hvl_sample_wholeblood_received
    WHERE 
        hvl_sample_plasma_received + hvl_sample_wholeblood_received  > 0;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_hvl_sample_received';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_total_samples
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_total_samples'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_total_samples AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_total_samples';

-- $BEGIN

	UPDATE
		final.fact_daily_sample_summary
	SET 
		sample_collected = eid_sample_collected + hvl_sample_collected,
        sample_received = eid_sample_dbs_received + hvl_sample_received,
		sample_accepted = eid_sample_accepted + hvl_sample_accepted,
        sample_rejected = hvl_sample_rejected + eid_sample_rejected,
        sample_tested = hvl_sample_tested + eid_sample_tested,
        result_pending = hvl_result_pending + eid_result_pending,
		result_authorized = eid_result_authorized + hvl_result_authorized,
		result_dispatched = eid_result_dispatched + hvl_result_dispatched,
		result_rejected = eid_result_rejected + hvl_result_rejected,
		result_accepted = eid_result_accepted + hvl_result_accepted,
		result_invalid = eid_result_invalid + hvl_result_invalid,
        result_failed = eid_result_failed + hvl_result_failed,
		result_tnd = eid_result_tnd + hvl_result_tnd;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_total_samples';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary
--

PRINT 'Creating final.sp_fact_daily_sample_summary'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary';

-- $BEGIN

    EXEC final.sp_fact_daily_sample_summary_create;
    EXEC final.sp_fact_daily_sample_summary_insert;
    EXEC final.sp_fact_daily_sample_summary_update_eid_samples;
    EXEC final.sp_fact_daily_sample_summary_update_hvl_samples;
    EXEC final.sp_fact_daily_sample_summary_update_total_samples;
    
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_data_processing
--

PRINT 'Creating final.sp_data_processing'
GO

CREATE OR ALTER PROCEDURE final.sp_data_processing AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_data_processing';

-- $BEGIN

PRINT 'Dropping Foreign Keys'
EXEC dbo.sp_xf_system_drop_all_foreign_keys_in_schema 'final'

PRINT 'Dropping tables'
EXEC dbo.sp_xf_system_drop_all_tables_in_schema 'final'

EXEC final.sp_fact_daily_sample_summary;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_data_processing';

END
GO