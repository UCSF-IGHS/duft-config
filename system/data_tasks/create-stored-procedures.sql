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
SET @BeginDate = '2025-04-01';
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
-- sp_fact_sample_testing_create
--

PRINT 'Creating derived.sp_fact_sample_testing_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_create';

-- $BEGIN

    CREATE TABLE derived.fact_sample_testing(
        sample_testing_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
        sample_tracking_id NVARCHAR(255) NOT NULL,
        facility_id UNIQUEIDENTIFIER NULL,
        _hfr_id NVARCHAR(255) NOT NULL,
        device_id UNIQUEIDENTIFIER NULL,
        sample_type NVARCHAR(255) NULL,
        test_name NVARCHAR(255) NULL,
        sample_quality_status NVARCHAR(255) NULL,
        rejection_reason NVARCHAR(255) NULL,
        clean_rejection_reason NVARCHAR(255) NULL,
        entry_modality NVARCHAR(255) NULL,
        collected_date DATE NULL,
        lab_received_date DATE NULL,
        tested_date DATE NULL,
        result_authorized_date DATE NULL,
        result_dispatched_date DATE NULL,
        result NVARCHAR(255) NULL,
        result_numeric INT NULL,
        is_valid_record INT NULL DEFAULT 1,
        is_eid_sample INT NULL,
        is_hvl_sample INT NULL,
        cleaning_comment NVARCHAR(255) NULL,
        is_sample_rejected INT NULL,
        is_hvl_sample_plasma INT NULL,
        is_hvl_sample_wholeblood INT NULL,
        is_collected INT NULL,
        is_accepted INT NULL,
        is_received INT NULL,
        is_tested INT NULL,
        is_dispatched INT NULL,
        is_authorised INT NULL,
        is_received_by_entry_modality_lab INT NULL,
        is_received_by_entry_modality_hub INT NULL,
        is_result_rejected INT NULL,
        is_result_invalid INT NULL,
        is_result_failed INT NULL,
        is_result_tnd INT NULL,
        is_eid_sample_tested_positive INT NULL,
        is_eid_sample_tested_negative INT NULL,
        is_result_indeterminate INT NULL,
        is_hvl_sample_plasma_received INT NULL,
        is_hvl_sample_wholeblood_received INT NULL,
        is_hvl_sample_plasma_rejected INT NULL,
        is_hvl_sample_wholeblood_rejected INT NULL,
        is_hvl_sample_plasma_tested INT NULL,
        is_hvl_sample_wholeblood_tested INT NULL,
        is_hvl_sample_plasma_dispatched INT NULL,
        is_hvl_sample_wholeblood_dispatched INT NULL,
        days_between_collected_and_authorised INT NULL,
        days_between_received_and_authorised INT NULL,
        days_between_collected_and_received INT NULL,
        days_between_received_and_tested INT NULL,
        is_collected_and_received_in_less_or_equal_5_days INT NULL,
        is_collected_and_received_between_6_to_10_days INT NULL,
        is_collected_and_received_between_11_to_15_days INT NULL,
        is_collected_and_received_in_greater_than_15_days INT NULL,
        is_hvl_samples_with_results_equal_or_above_1000 INT NULL,
        is_hvl_samples_with_results_less_than_1000_or_above_50 INT NULL,
        is_hvl_samples_with_results_less_than_50 INT NULL,
        is_received_and_authorised_in_less_or_equal_5_days INT NULL,
        is_received_and_authorised_between_6_to_10_days INT NULL,
        is_received_and_authorised_between_11_to_15_days INT NULL,
        is_received_and_authorised_in_greater_than_15_days INT NULL,
        is_collected_and_authorised_date_in_less_or_equal_10_days INT NULL,
        is_collected_and_authorised_date_between_11_to_14_days INT NULL,
        is_collected_and_authorised_date_between_15_to_21_days INT NULL,
        is_collected_and_authorised_date_greater_than_21_days INT NULL,
        is_received_and_tested_date_in_less_or_equal_5_days INT NULL,
        is_received_and_tested_date_between_6_to_10_days INT NULL,
        is_received_and_tested_date_between_11_to_15_days INT NULL,
        is_received_and_tested_date_greater_than_15_days INT NULL,
        is_less_than_or_equal_to_7_days_aging INT NULL,
        is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging INT NULL,
        is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging INT NULL,
        is_greater_than_21_days_aging INT NULL
    );

    ALTER TABLE derived.fact_sample_testing ADD CONSTRAINT FK_device_id FOREIGN KEY(device_id) REFERENCES derived.dim_device(device_id);
    ALTER TABLE derived.fact_sample_testing ADD CONSTRAINT FK_facility_id FOREIGN KEY(facility_id) REFERENCES derived.dim_facility(facility_id);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_insert
--

PRINT 'Creating derived.sp_fact_sample_testing_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_insert';

-- $BEGIN

    INSERT INTO [derived].fact_sample_testing
    (
        sample_tracking_id,
        sample_type,
        test_name,
        is_eid_sample,
        is_hvl_sample,
        device_id,
        facility_id,
        _hfr_id,
        collected_date,
        lab_received_date,
        tested_date,
        result_authorized_date,
        result_dispatched_date,
        result,
        entry_modality,
        rejection_reason,
        sample_quality_status
    )
    SELECT
        ts.sampletrackingid AS sample_tracking_id,
        ts.sampletype AS sample_type,
        ts.testname AS test_name,
        CASE
            WHEN ts.testname = 'EID' THEN 1
            ELSE 0
        END AS is_eid_sample,
        CASE
            WHEN ts.testname = 'HIVVL' THEN 1
            ELSE 0
        END AS is_hvl_sample,
        dv.device_id,
        df.facility_id,
        ISNULL(df.hfr_code, uf.hfr_code) AS _hfr_id,
        ts.CollectionDate AS collected_date,
        ts.ReceivedDate AS lab_received_date,
        ts.TestDate AS tested_date,
        ts.AuthorisedDate AS result_authorized_date,
        ts.DispatchDate AS result_dispatched_date,
        NULLIF(LTRIM(RTRIM(ts.Results)), ''),
        ts.entrymodality AS entry_modality,
        NULLIF(ts.SampleRejectionReason, '') AS rejection_reason,
        ts.samplequalitystatus AS sample_quality_status
    FROM
        [source].tbl_sample ts
    LEFT JOIN
        [derived].dim_facility df ON ts.HubHfrCode = df.hfr_code COLLATE Latin1_General_100_CS_AS
    LEFT JOIN
        z.z_unique_device ud ON ud.original_device_name = ts.DeviceName COLLATE Latin1_General_100_CS_AS
    LEFT JOIN
        [derived].dim_device dv ON ud.device_name = dv.device_name COLLATE Latin1_General_100_CS_AS
    LEFT JOIN
		[derived].dim_facility uf
		ON uf.facility_name = 'UNKNOWN';

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_collected = 
        CASE
            WHEN fs.collected_date IS NOT NULL THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_accepted
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_accepted'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_accepted AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_accepted';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_accepted = 
        CASE
            WHEN fs.sample_quality_status ='Accepted' THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_accepted';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received';

-- $BEGIN

    UPDATE
        fs
    SET
        is_received = 
        CASE
            WHEN fs.lab_received_date IS NOT NULL THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_tested
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_tested'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_tested AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_tested';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_tested = 
        CASE
            WHEN fs.tested_date IS NOT NULL THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_tested';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_dispatched
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_dispatched'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_dispatched AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_dispatched';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_dispatched = 
        CASE
            WHEN fs.result_dispatched_date IS NOT NULL THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_dispatched';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_authorised
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_authorised'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_authorised AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_authorised';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_authorised = 
        CASE
            WHEN fs.result_authorized_date IS NOT NULL THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_authorised';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_clean_rejection_reason
--

PRINT 'Creating derived.sp_fact_sample_testing_update_clean_rejection_reason'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_clean_rejection_reason AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_clean_rejection_reason';

-- $BEGIN

    UPDATE
        st
    SET
        st.clean_rejection_reason = 
        CASE
            WHEN 
                st.rejection_reason IS NULL
                OR st.rejection_reason = ''
                THEN NULL
            WHEN
                st.rejection_reason = 'BLOOD'
                OR st.rejection_reason = 'Blood spots in contact each other'
                OR st.rejection_reason = 'Old whole blood specimen with more than 24 hrs reaching the separation point'
                OR st.rejection_reason LIKE '%Hemolysed%'
                THEN  'Hemolysed sample'
            WHEN
                st.rejection_reason = 'Serum separation due to improper drying or collection'
                OR st.rejection_reason = 'Clotted or layered blood spot'
                OR st.rejection_reason = 'Clotted Sample'
                OR st.rejection_reason LIKE '%clot%'
                OR st.rejection_reason LIKE '%blood spot%'
                THEN  'Clotted specimen'
            WHEN
                st.rejection_reason = 'Insufficient specimen as per specific SOP'
                OR st.rejection_reason = 'Low volume'
                OR st.rejection_reason = 'Sample did not fill the cycle in the DBS card'
                OR st.rejection_reason LIKE '%insufficient sample or specimen%'
                OR st.rejection_reason LIKE '%poor quality%'
                THEN  'Insufficient sample (Low volume)'
            WHEN
                st.rejection_reason = 'Unlabelled or mislabelled specimen'
                OR st.rejection_reason = 'Mismatched information on request form and specimen'
                OR st.rejection_reason = 'Mismatched information between DBS card and laboratory test request form'
                OR st.rejection_reason = 'Incompletely filled requisition form'
                OR st.rejection_reason LIKE '%incomplete form or card%'
                THEN  'Incomplete form'
            WHEN
                st.rejection_reason = 'old DBS card with more than 14 days of collection'
                OR st.rejection_reason LIKE '%vacutainer%'
                OR st.rejection_reason LIKE '%expired%'
                OR st.rejection_reason LIKE '%more than days%'
                THEN  'Expired vacutainer/DBS Card'
            WHEN
                st.rejection_reason = 'No humidity indicator'
                OR st.rejection_reason = 'Indicating silica gel in the package'
                THEN  'Improper packaging'
            ELSE
                'Others'
            END
    FROM
        [derived].fact_sample_testing st

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_clean_rejection_reason';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_result_numeric
--

PRINT 'Creating derived.sp_fact_sample_testing_update_result_numeric'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_result_numeric AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_result_numeric';

-- $BEGIN
    UPDATE fs
    SET result_numeric = 
        CASE
            WHEN 
                fs.result IN ('TND', 'Target Not Detected')
                OR (
                    fs.result LIKE '<%' AND
                    TRY_CAST(REPLACE(fs.result, '<', '') AS INT) < 50
                )
                THEN 11
            WHEN
                (
                    (fs.result LIKE '<%' OR fs.result LIKE '>%' OR fs.result LIKE '%<%' OR fs.result LIKE '%>%') AND 
                    TRY_CAST(REPLACE(REPLACE(fs.result, '<', ''), '>', '') AS INT) >= 50
                )
                THEN TRY_CAST(REPLACE(REPLACE(fs.result, '<', ''), '>', '') AS INT)
            ELSE TRY_CAST(fs.result AS INT)
        END
    FROM [derived].fact_sample_testing fs
    WHERE fs.result IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_result_numeric';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_valid_record
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_valid_record'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_valid_record AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_valid_record';

-- $BEGIN

    -------------------------------------------------------
    -- 'Missing HFR code'
    -------------------------------------------------------

    UPDATE
    fs
        SET
            fs.cleaning_comment = 'Missing HFR code',
            fs.is_valid_record = 0
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.facility_id IS NULL;
    
    -------------------------------------------------------
    -- 'Missing Test Name'
    -------------------------------------------------------

    UPDATE
    fs
        SET
            fs.cleaning_comment = 'Missing Test Name',
            fs.is_valid_record = 0
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND (fs.test_name NOT IN ('HIVVL','EID') OR fs.test_name is null);
    
    -------------------------------------------------------
    -- 'Missing Collected Or Received date'
    -------------------------------------------------------

    UPDATE
    fs
        SET
            fs.cleaning_comment = 'Missing Collected Or Received date',
            fs.is_valid_record = 0
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND (
            fs.collected_date IS NULL
            OR fs.lab_received_date IS NULL
        );

    -------------------------------------------------------
    -- 'Earlier Received date than Collected date'
    -------------------------------------------------------

    UPDATE
    fs
        SET
            fs.cleaning_comment = 'Earlier Received date than Collected date',
            fs.is_valid_record = 0
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.collected_date > fs.lab_received_date;
    
    -------------------------------------------------------
    -- 'Earlier Dispatched date than Test date'
    -------------------------------------------------------

    UPDATE
    fs
        SET
            fs.cleaning_comment = 'Earlier Dispatched date than Test date',
            fs.is_valid_record = 0
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.tested_date > fs.result_dispatched_date;

    -------------------------------------------------------
    -- 'Rejected but has Result'
    -------------------------------------------------------

    UPDATE
    fs
        SET
            fs.cleaning_comment = 'Rejected but has Result',
            fs.is_valid_record = 0
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.clean_rejection_reason IS NOT NULL
        AND fs.result IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_valid_record';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_sample_rejected
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_sample_rejected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_sample_rejected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_sample_rejected';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_sample_rejected = 
        CASE
            WHEN
                fs.sample_quality_status = 'RejectedLab'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_sample_rejected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_plasma
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_plasma'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_plasma AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma';

-- $BEGIN

    UPDATE
        fs
    SET
        is_hvl_sample_plasma = 
        CASE
            WHEN
                LOWER(fs.sample_type) = 'plasma'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_wholeblood
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood';

-- $BEGIN

    UPDATE
        fs
    SET
        is_hvl_sample_wholeblood = 
        CASE
            WHEN
                LOWER(fs.sample_type) = 'wholeblood'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_by_entry_modality_lab
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_by_entry_modality_lab'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_by_entry_modality_lab AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_by_entry_modality_lab';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_by_entry_modality_lab =
        CASE
            WHEN
                fs.is_received = 1
                AND fs.entry_modality = 'lab'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_by_entry_modality_lab';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_by_entry_modality_hub
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_by_entry_modality_hub'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_by_entry_modality_hub AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_by_entry_modality_hub';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_by_entry_modality_hub =
        CASE
            WHEN
                fs.is_received = 1
                AND fs.entry_modality = 'hub'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_by_entry_modality_hub';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_result_rejected
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_result_rejected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_result_rejected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_rejected';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_result_rejected =
        CASE
            WHEN
                LOWER(fs.result) = 'rejectedlab'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.result IS NOT NULL
        AND fs.is_tested = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_rejected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_result_invalid
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_result_invalid'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_result_invalid AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_invalid';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_result_invalid = 
        CASE
            WHEN
                LOWER(fs.result) = 'invalid'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.result IS NOT NULL
        AND fs.is_tested = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_invalid';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_result_failed
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_result_failed'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_result_failed AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_failed';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_result_failed = 
            CASE
                WHEN
                    LOWER(fs.result) = 'failed'
                    THEN 1
                ELSE 0
            END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.result IS NOT NULL
        AND fs.is_tested = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_failed';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_result_tnd
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_result_tnd'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_result_tnd AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_tnd';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_result_tnd = 
        CASE
            WHEN
                LOWER(REPLACE(fs.result, ' ', '')) = 'targetnotdetected'
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.result IS NOT NULL
        AND fs.is_tested = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_tnd';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_eid_sample_tested_positive
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_eid_sample_tested_positive'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_eid_sample_tested_positive AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_eid_sample_tested_positive';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_eid_sample_tested_positive =
        CASE
            WHEN
                LOWER(fs.result) LIKE '%positive%'
            THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_eid_sample = 1
        AND fs.result IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_eid_sample_tested_positive';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_eid_sample_tested_negative
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_eid_sample_tested_negative'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_eid_sample_tested_negative AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_eid_sample_tested_negative';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_eid_sample_tested_positive =
        CASE
            WHEN
                LOWER(fs.result) LIKE '%negative%'
            THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_eid_sample = 1
        AND fs.result IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_eid_sample_tested_negative';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_result_indeterminate
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_result_indeterminate'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_result_indeterminate AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_indeterminate';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_result_indeterminate = 
            CASE
                WHEN
                    fs.is_tested = 1
                    AND (
                        ISNULL(fs.is_eid_sample_tested_positive,0) != 1
                        OR ISNULL(fs.is_eid_sample_tested_negative,0) != 1
                        OR ISNULL(fs.is_result_tnd,0) != 1
                        OR ISNULL(fs.is_result_failed,0) != 1
                    )
                    THEN 1
                ELSE 0
            END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_result_indeterminate';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_plasma_received
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_received'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_received AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_received';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_sample_plasma_received =
        CASE
            WHEN
                fs.is_received = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_plasma = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_received';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_wholeblood_received
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_received'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_received AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_received';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_sample_wholeblood_received =
        CASE
            WHEN
                fs.is_received = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_wholeblood = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_received';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_plasma_rejected
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_rejected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_rejected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_rejected';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_sample_plasma_rejected =
        CASE
            WHEN
                fs.is_sample_rejected = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_plasma = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_rejected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_wholeblood_rejected
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_rejected'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_rejected AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_rejected';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_sample_wholeblood_rejected =
        CASE
            WHEN
                fs.is_sample_rejected = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_wholeblood = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_rejected';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_plasma_tested
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_tested'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_tested AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_tested';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_sample_plasma_tested =
        CASE
            WHEN
                fs.is_tested = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_plasma = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_tested';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_wholeblood_tested
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_tested'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_tested AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_tested';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_Sample_wholeblood_tested =
        CASE
            WHEN
                fs.is_tested = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_wholeblood = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_tested';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_plasma_dispatched
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_dispatched'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_dispatched AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_dispatched';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_sample_plasma_dispatched = 
        CASE
            WHEN
                fs.is_dispatched = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_plasma = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_dispatched';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_sample_wholeblood_dispatched
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_dispatched'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_dispatched AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_dispatched';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_sample_wholeblood_dispatched = 
        CASE
            WHEN
                fs.is_dispatched = 1
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_hvl_sample_wholeblood = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_dispatched';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_days_between_collected_and_received
--

PRINT 'Creating derived.sp_fact_sample_testing_update_days_between_collected_and_received'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_days_between_collected_and_received AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_collected_and_received';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.days_between_collected_and_received = 
            DATEDIFF(DAY, fs.collected_date, fs.lab_received_date)
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.collected_date <= fs.lab_received_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_collected_and_received';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_days_between_received_and_authorised
--

PRINT 'Creating derived.sp_fact_sample_testing_update_days_between_received_and_authorised'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_days_between_received_and_authorised AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_received_and_authorised';

-- $BEGIN

    UPDATE
        fs
    SET
        days_between_received_and_authorised = 
            DATEDIFF(DAY, fs.lab_received_date, fs.result_authorized_date)
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.lab_received_date <= fs.result_authorized_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_received_and_authorised';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_days_between_collected_and_authorised
--

PRINT 'Creating derived.sp_fact_sample_testing_update_days_between_collected_and_authorised'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_days_between_collected_and_authorised AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_collected_and_authorised';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.days_between_collected_and_authorised =
        DATEDIFF(DAY, fs.collected_date, fs.result_authorized_date)
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.collected_date <= fs.result_authorized_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_collected_and_authorised';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_days_between_received_and_tested
--

PRINT 'Creating derived.sp_fact_sample_testing_update_days_between_received_and_tested'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_days_between_received_and_tested AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_received_and_tested';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.days_between_received_and_tested = 
            DATEDIFF(DAY, fs.lab_received_date, fs.tested_date)
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_valid_record = 1
        AND fs.lab_received_date <= fs.tested_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_days_between_received_and_tested';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_less_than_or_equal_to_7_days_aging
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_less_than_or_equal_to_7_days_aging'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_less_than_or_equal_to_7_days_aging AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_less_than_or_equal_to_7_days_aging';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_less_than_or_equal_to_7_days_aging = 
            CASE
                WHEN
                    fs.days_between_received_and_tested <= 7
                    THEN 1
                ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_less_than_or_equal_to_7_days_aging';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging = 
            CASE
                WHEN
                    fs.days_between_received_and_tested > 7
                    AND days_between_received_and_tested <=14
                    THEN 1
                ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging = 
            CASE
                WHEN
                    fs.days_between_received_and_tested > 14
                    AND fs.days_between_received_and_tested <= 21
                    THEN 1
                ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_greater_than_21_days_aging
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_greater_than_21_days_aging'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_greater_than_21_days_aging AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_greater_than_21_days_aging';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_greater_than_21_days_aging = 
            CASE
                WHEN
                    fs.days_between_received_and_tested > 21
                    THEN 1
                ELSE 0
        END
    FROM
        derived.fact_sample_testing fs;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_greater_than_21_days_aging';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_received_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_received_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_received_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_in_less_or_equal_5_days';

-- $BEGIN

    UPDATE
        fs
    SET

        fs.is_collected_and_received_in_less_or_equal_5_days = 
        CASE
            WHEN
                fs.days_between_collected_and_received <= 5
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_received IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_received_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_received_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_received_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_between_6_to_10_days';

-- $BEGIN

    UPDATE
        fs
    SET

        fs.is_collected_and_received_between_6_to_10_days =
        CASE
            WHEN
                fs.days_between_collected_and_received >= 6
                AND fs.days_between_collected_and_received <= 10
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_received IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_received_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_received_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_received_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_between_11_to_15_days';

-- $BEGIN

    UPDATE
        fs
    SET

        fs.is_collected_and_received_between_11_to_15_days = 
        CASE
            WHEN
                fs.days_between_collected_and_received >= 11
                AND fs.days_between_collected_and_received <= 15
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_received IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_received_in_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_received_in_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_received_in_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_in_greater_than_15_days';

-- $BEGIN

    UPDATE
        fs
    SET

        fs.is_collected_and_received_in_greater_than_15_days =
        CASE
            WHEN
                fs.days_between_collected_and_received > 15
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_received IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_received_in_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_samples_with_results_equal_or_above_1000
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_equal_or_above_1000'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_equal_or_above_1000 AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_equal_or_above_1000';

-- $BEGIN

    UPDATE
    fs
    SET
        fs.is_hvl_samples_with_results_equal_or_above_1000 =
        CASE
            WHEN
                fs.result_numeric >= 1000
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_tested = 1
        AND fs.is_hvl_sample = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_equal_or_above_1000';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_1000_or_above_50
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_1000_or_above_50'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_1000_or_above_50 AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_1000_or_above_50';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_hvl_samples_with_results_less_than_1000_or_above_50 = 
        CASE
            WHEN fs.result_numeric >= 50
                AND fs.result_numeric < 1000 
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.is_tested = 1
        AND fs.is_hvl_sample = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_1000_or_above_50';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_50
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_50'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_50 AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_50';

-- $BEGIN

    UPDATE 
        fs
    SET
        fs.is_hvl_samples_with_results_less_than_50 =
        CASE
            WHEN fs.result_numeric < 50 THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE 
		fs.is_tested = 1
        AND fs.is_hvl_sample = 1;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_50';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_authorised_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_authorised_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_authorised_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_in_less_or_equal_5_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_authorised_in_less_or_equal_5_days =
        CASE
            WHEN
                fs.days_between_received_and_authorised <= 5
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_authorised_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_authorised_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_authorised_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_between_6_to_10_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_authorised_between_6_to_10_days = 
        CASE
            WHEN
                fs.days_between_received_and_authorised >= 6
                AND fs.days_between_received_and_authorised <= 10
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_authorised_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_authorised_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_authorised_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_between_11_to_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_authorised_between_11_to_15_days =
        CASE
            WHEN
                fs.days_between_received_and_authorised >= 11 
                AND fs.days_between_received_and_authorised <= 15
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_authorised_in_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_authorised_in_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_authorised_in_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_in_greater_than_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_authorised_in_greater_than_15_days =
        CASE
            WHEN
                fs.days_between_received_and_authorised > 15
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_authorised_in_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_authorised_date_in_less_or_equal_10_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_in_less_or_equal_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_in_less_or_equal_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_in_less_or_equal_10_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_collected_and_authorised_date_in_less_or_equal_10_days =
        CASE
            WHEN
                fs.days_between_collected_and_authorised <= 10
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_in_less_or_equal_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_authorised_date_between_11_to_14_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_11_to_14_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_11_to_14_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_11_to_14_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_collected_and_authorised_date_between_11_to_14_days =
        CASE
            WHEN
                fs.days_between_collected_and_authorised >= 11
                AND fs.days_between_collected_and_authorised <= 14
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_11_to_14_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_authorised_date_between_15_to_21_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_15_to_21_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_15_to_21_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_15_to_21_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_collected_and_authorised_date_between_15_to_21_days =
        CASE
            WHEN
                fs.days_between_collected_and_authorised >= 15
                AND fs.days_between_collected_and_authorised <= 21
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_15_to_21_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_collected_and_authorised_date_greater_than_21_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_greater_than_21_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_greater_than_21_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_greater_than_21_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_collected_and_authorised_date_greater_than_21_days =
        CASE
            WHEN
                fs.days_between_collected_and_authorised > 21
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_collected_and_authorised IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_greater_than_21_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_tested_date_in_less_or_equal_5_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_tested_date_in_less_or_equal_5_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_tested_date_in_less_or_equal_5_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_in_less_or_equal_5_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_tested_date_in_less_or_equal_5_days =
        CASE
            WHEN
                fs.days_between_received_and_tested <= 5
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_tested IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_in_less_or_equal_5_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_tested_date_between_6_to_10_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_6_to_10_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_6_to_10_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_6_to_10_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_tested_date_between_6_to_10_days = 
        CASE
            WHEN
                fs.days_between_received_and_tested >= 6
                AND fs.days_between_received_and_tested <= 10
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_tested IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_6_to_10_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_tested_date_between_11_to_15_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_11_to_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_11_to_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_11_to_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_tested_date_between_11_to_15_days =
        CASE
            WHEN
                fs.days_between_received_and_tested >= 11
                AND fs.days_between_received_and_tested <= 15
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_tested IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_11_to_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing_update_is_received_and_tested_date_greater_than_15_days
--

PRINT 'Creating derived.sp_fact_sample_testing_update_is_received_and_tested_date_greater_than_15_days'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing_update_is_received_and_tested_date_greater_than_15_days AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_greater_than_15_days';

-- $BEGIN

    UPDATE
        fs
    SET
        fs.is_received_and_tested_date_greater_than_15_days = 
        CASE
            WHEN
                fs.days_between_received_and_tested > 15
                THEN 1
            ELSE 0
        END
    FROM
        derived.fact_sample_testing fs
    WHERE
        fs.days_between_received_and_tested IS NOT NULL;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing_update_is_received_and_tested_date_greater_than_15_days';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_testing
--

PRINT 'Creating derived.sp_fact_sample_testing'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_testing AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_testing';

-- $BEGIN

    EXEC derived.sp_fact_sample_testing_create;
    EXEC derived.sp_fact_sample_testing_insert;
    EXEC derived.sp_fact_sample_testing_update_is_collected;
    EXEC derived.sp_fact_sample_testing_update_is_accepted;
    EXEC derived.sp_fact_sample_testing_update_is_received;
    EXEC derived.sp_fact_sample_testing_update_is_tested;
    EXEC derived.sp_fact_sample_testing_update_is_dispatched;
    EXEC derived.sp_fact_sample_testing_update_is_authorised;
    EXEC derived.sp_fact_sample_testing_update_clean_rejection_reason;
    EXEC derived.sp_fact_sample_testing_update_result_numeric;
    EXEC derived.sp_fact_sample_testing_update_is_valid_record;
    EXEC derived.sp_fact_sample_testing_update_is_sample_rejected;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_plasma;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood;
    EXEC derived.sp_fact_sample_testing_update_is_received_by_entry_modality_lab;
    EXEC derived.sp_fact_sample_testing_update_is_received_by_entry_modality_hub;
    EXEC derived.sp_fact_sample_testing_update_is_result_rejected;
    EXEC derived.sp_fact_sample_testing_update_is_result_invalid;
    EXEC derived.sp_fact_sample_testing_update_is_result_failed;
    EXEC derived.sp_fact_sample_testing_update_is_result_tnd;
    EXEC derived.sp_fact_sample_testing_update_is_eid_sample_tested_positive;
    EXEC derived.sp_fact_sample_testing_update_is_eid_sample_tested_negative;
    EXEC derived.sp_fact_sample_testing_update_is_result_indeterminate;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_rejected;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_rejected;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_received;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_received;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_tested;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_tested;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_plasma_dispatched;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_sample_wholeblood_dispatched;
    EXEC derived.sp_fact_sample_testing_update_days_between_collected_and_received;
    EXEC derived.sp_fact_sample_testing_update_days_between_received_and_authorised;
    EXEC derived.sp_fact_sample_testing_update_days_between_collected_and_authorised;
    EXEC derived.sp_fact_sample_testing_update_days_between_received_and_tested;
    EXEC derived.sp_fact_sample_testing_update_is_less_than_or_equal_to_7_days_aging;
    EXEC derived.sp_fact_sample_testing_update_is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging;
    EXEC derived.sp_fact_sample_testing_update_is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging;
    EXEC derived.sp_fact_sample_testing_update_is_greater_than_21_days_aging;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_received_in_less_or_equal_5_days;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_received_between_6_to_10_days;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_received_between_11_to_15_days;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_received_in_greater_than_15_days;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_equal_or_above_1000;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_1000_or_above_50;
    EXEC derived.sp_fact_sample_testing_update_is_hvl_samples_with_results_less_than_50;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_authorised_in_less_or_equal_5_days;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_authorised_between_6_to_10_days;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_authorised_between_11_to_15_days;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_authorised_in_greater_than_15_days;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_in_less_or_equal_10_days;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_11_to_14_days;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_between_15_to_21_days;
    EXEC derived.sp_fact_sample_testing_update_is_collected_and_authorised_date_greater_than_21_days;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_tested_date_in_less_or_equal_5_days;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_6_to_10_days;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_tested_date_between_11_to_15_days;
    EXEC derived.sp_fact_sample_testing_update_is_received_and_tested_date_greater_than_15_days;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_testing';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_daily_status_create
--

PRINT 'Creating derived.sp_fact_sample_daily_status_create'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_daily_status_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_daily_status_create';

-- $BEGIN

    CREATE TABLE derived.fact_sample_daily_status(
        sample_testing_id UNIQUEIDENTIFIER NOT NULL,
        report_date DATE NOT NULL,
        is_result_pending INT NOT NULL DEFAULT 0
    );

    ALTER TABLE derived.fact_sample_daily_status ADD CONSTRAINT fk_derived_fact_sample_daily_status FOREIGN KEY (sample_testing_id) REFERENCES derived.fact_sample_testing(sample_testing_id);

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_daily_status_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_daily_status_insert
--

PRINT 'Creating derived.sp_fact_sample_daily_status_insert'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_daily_status_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_daily_status_insert';

-- $BEGIN

    INSERT INTO derived.fact_sample_daily_status
    (
        sample_testing_id,
		report_date
    )
	SELECT
		fs.sample_testing_id,
		ISNULL(dd.[date], fs.collected_date) report_date
	FROM
		[derived].fact_sample_testing fs
	INNER JOIN
		[derived].dim_date dd 
		ON dd.[date] >= fs.collected_date 
		AND dd.[date] <= COALESCE(fs.result_dispatched_date, fs.result_authorized_date, fs.tested_date, fs.lab_received_date, fs.collected_date)
 

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_daily_status_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_daily_status_update_is_result_pending
--

PRINT 'Creating derived.sp_fact_sample_daily_status_update_is_result_pending'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_daily_status_update_is_result_pending AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_daily_status_update_is_result_pending';

-- $BEGIN

    UPDATE 
        fd
    SET 
        fd.is_result_pending = 1
    FROM
        derived.fact_sample_daily_status fd
    INNER JOIN
        derived.fact_sample_testing ft 
        ON fd.sample_testing_id = ft.sample_testing_id
        AND fd.report_date >= ft.tested_date
        AND (
            ft.result_authorized_date IS NULL 
            OR fd.report_date < ft.result_authorized_date
        );

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_daily_status_update_is_result_pending';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_sample_daily_status
--

PRINT 'Creating derived.sp_fact_sample_daily_status'
GO

CREATE OR ALTER PROCEDURE derived.sp_fact_sample_daily_status AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'derived.sp_fact_sample_daily_status';

-- $BEGIN

    EXEC derived.sp_fact_sample_daily_status_create;
    EXEC derived.sp_fact_sample_daily_status_insert;
    EXEC derived.sp_fact_sample_daily_status_update_is_result_pending;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'derived.sp_fact_sample_daily_status';

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
EXEC derived.sp_fact_daily_commodity_status;
EXEC derived.sp_fact_daily_device_status;
EXEC derived.sp_fact_sample_testing;
EXEC derived.sp_fact_sample_daily_status;

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
-- sp_dim_week_create
--

PRINT 'Creating final.sp_dim_week_create'
GO

CREATE OR ALTER PROCEDURE final.sp_dim_week_create AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_dim_week_create';

-- $BEGIN

  CREATE TABLE final.dim_week  (
    week_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    start_date DATE NULL,
    end_date DATE NULL,
    weekly_start_monday_period NVARCHAR (255),
    weekly_start_monday_day_dates NVARCHAR (255)
  );

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_dim_week_create';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_week_insert
--

PRINT 'Creating final.sp_dim_week_insert'
GO

CREATE OR ALTER PROCEDURE final.sp_dim_week_insert AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_dim_week_insert';

-- $BEGIN

    INSERT INTO final.dim_week (
      start_date,
      end_date,
      weekly_start_monday_period,
      weekly_start_monday_day_dates
    )
    SELECT
        MIN(date) AS start_date,
        MAX(date) AS end_date,
        weekly_start_monday_period,
        weekly_start_monday_day_dates
    FROM
      derived.dim_date
    GROUP BY
        weekly_start_monday_period,
        weekly_start_monday_day_dates;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_dim_week_insert';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_dim_week
--

PRINT 'Creating final.sp_dim_week'
GO

CREATE OR ALTER PROCEDURE final.sp_dim_week AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_dim_week';

-- $BEGIN

    EXEC final.sp_dim_week_create;
    EXEC final.sp_dim_week_insert;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_dim_week';

END
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
        hfr_id_for_HUB_sample_is_coming_from NVARCHAR(255) NOT NULL,
        report_date DATE NOT NULL,
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
        hvl_sample_referred INT NULL DEFAULT 0,
        eid_sample_referred INT NULL DEFAULT 0,
        sample_referred INT NULL DEFAULT 0,
        hvl_referral_result_received INT NULL DEFAULT 0,
        eid_referral_result_received INT NULL DEFAULT 0,
        referral_result_received INT NULL DEFAULT 0,
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
-- sp_fact_daily_sample_summary_update_columns_group_by_collected_date
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_columns_group_by_collected_date'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_columns_group_by_collected_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_collected_date';

-- $BEGIN

    WITH cte_samples AS
    (
        SELECT 
            fst.[_hfr_id] AS hfr_id_for_HUB_sample_is_coming_from,
            fst.collected_date AS report_date,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected ELSE 0 END) AS hvl_sample_collected,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected ELSE 0 END) AS eid_sample_collected
        FROM 
            [derived].fact_sample_testing fst
        WHERE
            fst.collected_date IS NOT NULL
            AND fst.is_valid_record = 1
        GROUP BY
            fst.[_hfr_id], 
            fst.collected_date
    )
    UPDATE
        target
    SET
        target.hvl_sample_collected = ISNULL(source.hvl_sample_collected, 0),
        target.eid_sample_collected = ISNULL(source.eid_sample_collected, 0)
    FROM        
        [final].fact_daily_sample_summary AS target
    INNER JOIN
        cte_samples AS source
    ON
        target.hfr_id_for_HUB_sample_is_coming_from = source.hfr_id_for_HUB_sample_is_coming_from
        AND target.report_date = source.report_date;
-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_collected_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_columns_group_by_tested_date
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_columns_group_by_tested_date'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_columns_group_by_tested_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_tested_date';

-- $BEGIN

    WITH cte_samples AS
    (
        SELECT 
            fst.[_hfr_id] AS hfr_id_for_HUB_sample_is_coming_from,
            fst.tested_date AS report_date,
            SUM(is_hvl_sample_plasma_tested) AS hvl_sample_plasma_tested,
            SUM(is_hvl_sample_wholeblood_tested) AS hvl_sample_wholeblood_tested,
            SUM(is_eid_sample_tested_positive) AS eid_sample_tested_positive,
            SUM(is_eid_sample_tested_negative)AS eid_sample_tested_negative,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_tested ELSE 0 END) AS hvl_sample_tested,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_tested ELSE 0 END) AS eid_sample_tested,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_result_rejected ELSE 0 END) AS hvl_result_rejected,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_result_rejected ELSE 0 END) AS eid_result_rejected,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_result_invalid ELSE 0 END) AS hvl_result_invalid,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_result_invalid ELSE 0 END) AS eid_result_invalid,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_result_failed ELSE 0 END) AS hvl_result_failed,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_result_failed ELSE 0 END) AS eid_result_failed,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_result_tnd ELSE 0 END) AS hvl_result_tnd,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_result_tnd ELSE 0 END) AS eid_result_tnd,
            SUM(is_result_indeterminate) AS result_indeterminate,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_tested_date_in_less_or_equal_5_days ELSE 0 END) AS eid_sample_received_and_tested_date_in_less_or_equal_5_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_tested_date_between_6_to_10_days ELSE 0 END) AS eid_sample_received_and_tested_date_between_6_to_10_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_tested_date_between_11_to_15_days ELSE 0 END) AS eid_sample_received_and_tested_date_between_11_to_15_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_tested_date_greater_than_15_days ELSE 0 END) AS eid_sample_received_and_tested_date_greater_than_15_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_tested_date_in_less_or_equal_5_days ELSE 0 END) AS hvl_sample_received_and_tested_date_in_less_or_equal_5_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_tested_date_between_6_to_10_days ELSE 0 END) AS hvl_sample_received_and_tested_date_between_6_to_10_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_tested_date_between_11_to_15_days ELSE 0 END) AS hvl_sample_received_and_tested_date_between_11_to_15_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_tested_date_greater_than_15_days ELSE 0 END) AS hvl_sample_received_and_tested_date_greater_than_15_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging ELSE 0 END) AS hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging ELSE 0 END) AS hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_greater_than_21_days_aging ELSE 0 END) AS hvl_samples_aging_is_greater_than_21_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_greater_than_7_days_and_less_than_or_equal_to_14_days_aging ELSE 0 END) AS eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_greater_than_14_days_and_less_than_or_equal_to_21_days_aging ELSE 0 END) AS eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_greater_than_21_days_aging ELSE 0 END) AS eid_samples_greater_than_21_days_aging,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_less_than_or_equal_to_7_days_aging ELSE 0 END) AS hvl_samples_aging_is_less_than_or_equal_to_7_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_less_than_or_equal_to_7_days_aging ELSE 0 END) AS eid_samples_aging_less_than_or_equal_to_7_days_aging,
            SUM(is_hvl_samples_with_results_equal_or_above_1000) AS hvl_samples_with_results_equal_or_above_1000,
            SUM(is_hvl_samples_with_results_less_than_1000_or_above_50) AS hvl_samples_with_results_less_than_1000_or_above_50,
            SUM(is_hvl_samples_with_results_less_than_50) AS hvl_samples_with_results_less_than_50
        FROM 
            [derived].fact_sample_testing fst
        WHERE
            fst.tested_date IS NOT NULL
            AND fst.is_valid_record = 1
        GROUP BY
            fst.[_hfr_id], 
            fst.tested_date
    )
        UPDATE
            target
        SET
            target.hvl_sample_plasma_tested = ISNULL(source.hvl_sample_plasma_tested, 0),
            target.hvl_sample_wholeblood_tested = ISNULL(source.hvl_sample_wholeblood_tested, 0),
            target.eid_sample_tested_positive = ISNULL(source.eid_sample_tested_positive, 0),
            target.eid_sample_tested_negative = ISNULL(source.eid_sample_tested_negative, 0),
            target.hvl_sample_tested = ISNULL(source.hvl_sample_tested, 0),
            target.eid_sample_tested = ISNULL(source.eid_sample_tested, 0),
            target.hvl_result_rejected = ISNULL(source.hvl_result_rejected, 0),
            target.eid_result_rejected = ISNULL(source.eid_result_rejected, 0),
            target.hvl_result_invalid = ISNULL(source.hvl_result_invalid, 0),
            target.eid_result_invalid = ISNULL(source.eid_result_invalid, 0),
            target.hvl_result_failed = ISNULL(source.hvl_result_failed, 0),
            target.eid_result_failed = ISNULL(source.eid_result_failed, 0),
            target.hvl_result_tnd = ISNULL(source.hvl_result_tnd, 0),
            target.eid_result_tnd = ISNULL(source.eid_result_tnd, 0),
            target.result_indeterminate = ISNULL(source.result_indeterminate, 0),
            target.eid_sample_received_and_tested_date_in_less_or_equal_5_days = ISNULL(source.eid_sample_received_and_tested_date_in_less_or_equal_5_days, 0),
            target.eid_sample_received_and_tested_date_between_6_to_10_days = ISNULL(source.eid_sample_received_and_tested_date_between_6_to_10_days, 0),
            target.eid_sample_received_and_tested_date_between_11_to_15_days = ISNULL(source.eid_sample_received_and_tested_date_between_11_to_15_days, 0),
            target.eid_sample_received_and_tested_date_greater_than_15_days = ISNULL(source.eid_sample_received_and_tested_date_greater_than_15_days, 0),
            target.hvl_sample_received_and_tested_date_in_less_or_equal_5_days = ISNULL(source.hvl_sample_received_and_tested_date_in_less_or_equal_5_days, 0),
            target.hvl_sample_received_and_tested_date_between_6_to_10_days = ISNULL(source.hvl_sample_received_and_tested_date_between_6_to_10_days, 0),
            target.hvl_sample_received_and_tested_date_between_11_to_15_days = ISNULL(source.hvl_sample_received_and_tested_date_between_11_to_15_days, 0),
            target.hvl_sample_received_and_tested_date_greater_than_15_days = ISNULL(source.hvl_sample_received_and_tested_date_greater_than_15_days, 0),
            target.hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days = ISNULL(source.hvl_samples_aging_is_greater_than_7_days_and_less_than_or_equal_to_14_days, 0),
            target.hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days = ISNULL(source.hvl_samples_aging_is_greater_than_14_days_and_less_than_or_equal_to_21_days, 0),
            target.hvl_samples_aging_is_greater_than_21_days = ISNULL(source.hvl_samples_aging_is_greater_than_21_days, 0),
            target.eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging = ISNULL(source.eid_samples_aging_greater_than_7_days_and_less_than_or_equal_to_14_days_aging, 0),
            target.eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging = ISNULL(source.eid_samples_aging_greater_than_14_days_and_less_than_or_equal_to_21_days_aging, 0),
            target.eid_samples_greater_than_21_days_aging = ISNULL(source.eid_samples_greater_than_21_days_aging, 0),
            target.hvl_samples_aging_is_less_than_or_equal_to_7_days = ISNULL(source.hvl_samples_aging_is_less_than_or_equal_to_7_days, 0),
            target.eid_samples_aging_less_than_or_equal_to_7_days_aging = ISNULL(source.eid_samples_aging_less_than_or_equal_to_7_days_aging, 0),
            target.hvl_samples_with_results_equal_or_above_1000 = ISNULL(source.hvl_samples_with_results_equal_or_above_1000, 0),
            target.hvl_samples_with_results_less_than_1000_or_above_50 = ISNULL(source.hvl_samples_with_results_less_than_1000_or_above_50, 0),
            target.hvl_samples_with_results_less_than_50 = ISNULL(source.hvl_samples_with_results_less_than_50, 0)
        FROM
            final.fact_daily_sample_summary AS target
        INNER JOIN
            cte_samples AS source
            ON target.hfr_id_for_HUB_sample_is_coming_from = source.hfr_id_for_HUB_sample_is_coming_from
            AND target.report_date = source.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_tested_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_columns_group_by_lab_received_date
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_columns_group_by_lab_received_date'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_columns_group_by_lab_received_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_lab_received_date';

-- $BEGIN

    WITH cte_samples AS
    (
        SELECT 
            fst.[_hfr_id] AS hfr_id_for_HUB_sample_is_coming_from,
            fst.lab_received_date AS report_date,
            SUM(is_hvl_sample_plasma_received) AS hvl_sample_plasma_received,
            SUM(is_hvl_sample_wholeblood_received) AS hvl_sample_wholeblood_received,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_by_entry_modality_lab ELSE 0 END) AS hvl_samples_received_by_entry_modality_lab,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_by_entry_modality_hub ELSE 0 END) AS hvl_samples_received_by_entry_modality_hub,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received ELSE 0 END) AS hvl_sample_received,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_by_entry_modality_lab ELSE 0 END) AS eid_samples_received_by_entry_modality_lab,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_by_entry_modality_hub ELSE 0 END) AS eid_samples_received_by_entry_modality_hub,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received ELSE 0 END) AS eid_sample_dbs_received,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_accepted ELSE 0 END) AS hvl_sample_accepted,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_accepted ELSE 0 END) AS eid_sample_accepted,
            SUM(is_hvl_sample_plasma_rejected) AS hvl_sample_plasma_rejected,
            SUM(is_hvl_sample_wholeblood_rejected) AS hvl_sample_wholeblood_rejected,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_received_in_less_or_equal_5_days ELSE 0 END) AS hvl_sample_collected_and_received_date_in_less_or_equal_5_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_received_between_6_to_10_days ELSE 0 END) AS hvl_sample_collected_and_received_date_between_6_to_10_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_received_between_11_to_15_days ELSE 0 END) AS hvl_sample_collected_and_received_date_between_11_to_15_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_received_in_greater_than_15_days ELSE 0 END) AS hvl_sample_collected_and_received_date_greater_than_15_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_received_in_less_or_equal_5_days ELSE 0 END) AS eid_sample_collected_and_received_date_in_less_or_equal_5_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_received_between_6_to_10_days ELSE 0 END) AS eid_sample_collected_and_received_date_between_6_to_10_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_received_between_11_to_15_days ELSE 0 END) AS eid_sample_collected_and_received_date_between_11_to_15_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_received_in_greater_than_15_days ELSE 0 END) AS eid_sample_collected_and_received_date_greater_than_15_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_sample_rejected ELSE 0 END) AS hvl_sample_rejected,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_sample_rejected ELSE 0 END) AS eid_sample_rejected
        FROM 
            [derived].fact_sample_testing fst
        WHERE
            fst.lab_received_date IS NOT NULL
            AND fst.is_valid_record = 1
        GROUP BY
            fst.[_hfr_id], 
            fst.lab_received_date
    )
    UPDATE
        target
    SET
        target.hvl_sample_plasma_received = ISNULL(source.hvl_sample_plasma_received, 0),
        target.hvl_sample_wholeblood_received = ISNULL(source.hvl_sample_wholeblood_received, 0),
        target.hvl_samples_received_by_entry_modality_lab = ISNULL(source.hvl_samples_received_by_entry_modality_lab, 0),
        target.hvl_samples_received_by_entry_modality_hub = ISNULL(source.hvl_samples_received_by_entry_modality_hub, 0),
        target.hvl_sample_received = ISNULL(source.hvl_sample_received, 0),
        target.eid_samples_received_by_entry_modality_lab = ISNULL(source.eid_samples_received_by_entry_modality_lab, 0),
        target.eid_samples_received_by_entry_modality_hub = ISNULL(source.eid_samples_received_by_entry_modality_hub, 0),
        target.eid_sample_dbs_received = ISNULL(source.eid_sample_dbs_received, 0),
        target.hvl_sample_accepted = ISNULL(source.hvl_sample_accepted, 0),
        target.eid_sample_accepted = ISNULL(source.eid_sample_accepted, 0),
        target.hvl_sample_plasma_rejected = ISNULL(source.hvl_sample_plasma_rejected, 0),
        target.hvl_sample_wholeblood_rejected = ISNULL(source.hvl_sample_wholeblood_rejected, 0),
        target.hvl_sample_rejected = ISNULL(source.hvl_sample_rejected, 0),
        target.eid_sample_rejected = ISNULL(source.eid_sample_rejected, 0),
        target.hvl_sample_collected_and_received_date_in_less_or_equal_5_days = ISNULL(source.hvl_sample_collected_and_received_date_in_less_or_equal_5_days, 0),
        target.hvl_sample_collected_and_received_date_between_6_to_10_days = ISNULL(source.hvl_sample_collected_and_received_date_between_6_to_10_days, 0),
        target.hvl_sample_collected_and_received_date_between_11_to_15_days = ISNULL(source.hvl_sample_collected_and_received_date_between_11_to_15_days, 0),
        target.hvl_sample_collected_and_received_date_greater_than_15_days = ISNULL(source.hvl_sample_collected_and_received_date_greater_than_15_days, 0),
        target.eid_sample_collected_and_received_date_in_less_or_equal_5_days = ISNULL(source.eid_sample_collected_and_received_date_in_less_or_equal_5_days, 0),
        target.eid_sample_collected_and_received_date_between_6_to_10_days = ISNULL(source.eid_sample_collected_and_received_date_between_6_to_10_days, 0),
        target.eid_sample_collected_and_received_date_between_11_to_15_days = ISNULL(source.eid_sample_collected_and_received_date_between_11_to_15_days, 0),
        target.eid_sample_collected_and_received_date_greater_than_15_days = ISNULL(source.eid_sample_collected_and_received_date_greater_than_15_days, 0)
    FROM
        [final].fact_daily_sample_summary AS target
    INNER JOIN
        cte_samples AS source
        ON target.hfr_id_for_HUB_sample_is_coming_from = source.hfr_id_for_HUB_sample_is_coming_from
        AND target.report_date = source.report_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_lab_received_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_pending_result
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_pending_result'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_pending_result AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_pending_result';

-- $BEGIN

    WITH cte_samples AS
    (
        SELECT 
            ft._hfr_id AS hfr_id_for_HUB_sample_is_coming_from,
            report_date,
            SUM(CASE WHEN is_hvl_sample = 1 THEN fd.is_result_pending ELSE 0 END) AS hvl_result_pending,
            SUM(CASE WHEN is_eid_sample = 1 THEN fd.is_result_pending ELSE 0 END) AS eid_result_pending
        FROM 
            derived.fact_sample_daily_status fd
        INNER JOIN
            derived.fact_sample_testing ft 
            ON fd.sample_testing_id = ft.sample_testing_id
        GROUP BY
            ft._hfr_id, 
            report_date
    )
        UPDATE 
            target
        SET
            target.hvl_result_pending = ISNULL(source.hvl_result_pending, 0),
            target.eid_result_pending = ISNULL(source.eid_result_pending, 0)
        FROM
            final.fact_daily_sample_summary AS target
        INNER JOIN
            cte_samples AS source
        ON target.hfr_id_for_HUB_sample_is_coming_from = source.hfr_id_for_HUB_sample_is_coming_from
        AND target.report_date = source.report_date;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_pending_result';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_columns_group_by_result_authorised_date
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_columns_group_by_result_authorised_date'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_columns_group_by_result_authorised_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_result_authorised_date';

-- $BEGIN

    WITH cte_samples AS
    (
        SELECT 
            fst.[_hfr_id] AS hfr_id_for_HUB_sample_is_coming_from,
            fst.result_authorized_date AS report_date,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_authorised ELSE 0 END) AS hvl_result_authorized,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_authorised ELSE 0 END) AS eid_result_authorized,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_accepted ELSE 0 END) AS hvl_result_accepted,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_accepted ELSE 0 END) AS eid_result_accepted,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_authorised_date_in_less_or_equal_10_days ELSE 0 END) AS hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_authorised_date_between_11_to_14_days ELSE 0 END) AS hvl_sample_collected_and_authorised_date_between_11_to_14_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_authorised_date_between_15_to_21_days ELSE 0 END) AS hvl_sample_collected_and_authorised_date_between_15_to_21_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_collected_and_authorised_date_greater_than_21_days ELSE 0 END) AS hvl_sample_collected_and_authorised_date_greater_than_21_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_authorised_date_in_less_or_equal_10_days ELSE 0 END) AS eid_sample_collected_and_authorised_date_in_less_or_equal_10_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_authorised_date_between_11_to_14_days ELSE 0 END) AS eid_sample_collected_and_authorised_date_between_11_to_14_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_authorised_date_between_15_to_21_days ELSE 0 END) AS eid_sample_collected_and_authorised_date_between_15_to_21_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_collected_and_authorised_date_greater_than_21_days ELSE 0 END) AS eid_sample_collected_and_authorised_date_greater_than_21_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_authorised_in_less_or_equal_5_days ELSE 0 END) AS hvl_sample_received_and_authorised_date_in_less_or_equal_5_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_authorised_between_6_to_10_days ELSE 0 END) AS hvl_sample_received_and_authorised_date_between_6_to_10_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_authorised_between_11_to_15_days ELSE 0 END) AS hvl_sample_received_and_authorised_date_between_11_to_15_days,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_received_and_authorised_in_greater_than_15_days ELSE 0 END) AS hvl_sample_received_and_authorised_date_greater_than_15_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_authorised_in_less_or_equal_5_days ELSE 0 END) AS eid_sample_received_and_authorised_date_in_less_or_equal_5_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_authorised_between_6_to_10_days ELSE 0 END) AS eid_sample_received_and_authorised_date_between_6_to_10_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_authorised_between_11_to_15_days ELSE 0 END) AS eid_sample_received_and_authorised_date_between_11_to_15_days,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_received_and_authorised_in_greater_than_15_days ELSE 0 END) AS eid_sample_received_and_authorised_date_greater_than_15_days
        FROM 
            [derived].fact_sample_testing fst
        WHERE
            fst.result_authorized_date IS NOT NULL
            AND fst.is_valid_record = 1
        GROUP BY
            fst.[_hfr_id], 
            fst.result_authorized_date
    )
    UPDATE 
        target
    SET
        target.hvl_result_authorized = ISNULL(source.hvl_result_authorized, 0),
        target.eid_result_authorized = ISNULL(source.eid_result_authorized, 0),
        target.hvl_result_accepted = ISNULL(source.hvl_result_accepted, 0),
        target.eid_result_accepted = ISNULL(source.eid_result_accepted, 0),
        target.hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days = ISNULL(source.hvl_sample_collected_and_authorised_date_in_less_or_equal_10_days, 0),
        target.hvl_sample_collected_and_authorised_date_between_11_to_14_days = ISNULL(source.hvl_sample_collected_and_authorised_date_between_11_to_14_days, 0),
        target.hvl_sample_collected_and_authorised_date_between_15_to_21_days = ISNULL(source.hvl_sample_collected_and_authorised_date_between_15_to_21_days, 0),
        target.hvl_sample_collected_and_authorised_date_greater_than_21_days = ISNULL(source.hvl_sample_collected_and_authorised_date_greater_than_21_days, 0),
        target.eid_sample_collected_and_authorised_date_in_less_or_equal_10_days = ISNULL(source.eid_sample_collected_and_authorised_date_in_less_or_equal_10_days, 0),
        target.eid_sample_collected_and_authorised_date_between_11_to_14_days = ISNULL(source.eid_sample_collected_and_authorised_date_between_11_to_14_days, 0),
        target.eid_sample_collected_and_authorised_date_between_15_to_21_days = ISNULL(source.eid_sample_collected_and_authorised_date_between_15_to_21_days, 0),
        target.eid_sample_collected_and_authorised_date_greater_than_21_days = ISNULL(source.eid_sample_collected_and_authorised_date_greater_than_21_days, 0),
        target.hvl_sample_received_and_authorised_date_in_less_or_equal_5_days = ISNULL(source.hvl_sample_received_and_authorised_date_in_less_or_equal_5_days, 0),
        target.hvl_sample_received_and_authorised_date_between_6_to_10_days = ISNULL(source.hvl_sample_received_and_authorised_date_between_6_to_10_days, 0),
        target.hvl_sample_received_and_authorised_date_between_11_to_15_days = ISNULL(source.hvl_sample_received_and_authorised_date_between_11_to_15_days, 0),
        target.hvl_sample_received_and_authorised_date_greater_than_15_days = ISNULL(source.hvl_sample_received_and_authorised_date_greater_than_15_days, 0),
        target.eid_sample_received_and_authorised_date_in_less_or_equal_5_days = ISNULL(source.eid_sample_received_and_authorised_date_in_less_or_equal_5_days, 0),
        target.eid_sample_received_and_authorised_date_between_6_to_10_days = ISNULL(source.eid_sample_received_and_authorised_date_between_6_to_10_days, 0),
        target.eid_sample_received_and_authorised_date_between_11_to_15_days = ISNULL(source.eid_sample_received_and_authorised_date_between_11_to_15_days, 0),
        target.eid_sample_received_and_authorised_date_greater_than_15_days = ISNULL(source.eid_sample_received_and_authorised_date_greater_than_15_days, 0)
    FROM
        [final].fact_daily_sample_summary AS target
    INNER JOIN
        cte_samples AS source
        ON target.hfr_id_for_HUB_sample_is_coming_from = source.hfr_id_for_HUB_sample_is_coming_from
        AND target.report_date = source.report_date

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_result_authorised_date';

END
GO
        

-----------------------------------------------------------------------------------------------
-- sp_fact_daily_sample_summary_update_columns_group_by_result_dispatched_date
--

PRINT 'Creating final.sp_fact_daily_sample_summary_update_columns_group_by_result_dispatched_date'
GO

CREATE OR ALTER PROCEDURE final.sp_fact_daily_sample_summary_update_columns_group_by_result_dispatched_date AS
BEGIN

EXEC dbo.sp_etl_tracking_insert_start_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_result_dispatched_date';

-- $BEGIN

    WITH cte_samples AS
    (
        SELECT 
            fst.[_hfr_id] AS hfr_id_for_HUB_sample_is_coming_from,
            fst.result_dispatched_date AS report_date,
            SUM(is_hvl_sample_plasma_dispatched) AS hvl_sample_plasma_dispatched,
            SUM(is_hvl_sample_wholeblood_dispatched) AS hvl_sample_wholeblood_dispatched,
            SUM(CASE WHEN is_hvl_sample = 1 THEN is_dispatched ELSE 0 END) AS hvl_result_dispatched,
            SUM(CASE WHEN is_eid_sample = 1 THEN is_dispatched ELSE 0 END) AS eid_result_dispatched
        FROM 
            [derived].fact_sample_testing fst
        WHERE
            fst.result_dispatched_date IS NOT NULL
            AND fst.is_valid_record = 1
        GROUP BY
            fst.[_hfr_id], 
            fst.result_dispatched_date
    )
    UPDATE
        target
    SET
        target.hvl_sample_plasma_dispatched = ISNULL(source.hvl_sample_plasma_dispatched, 0),
        target.hvl_sample_wholeblood_dispatched = ISNULL(source.hvl_sample_wholeblood_dispatched, 0),
        target.hvl_result_dispatched = ISNULL(source.hvl_result_dispatched, 0),
        target.eid_result_dispatched = ISNULL(source.eid_result_dispatched, 0)
    FROM
        [final].fact_daily_sample_summary AS target
    INNER JOIN
        cte_samples AS source
        ON target.hfr_id_for_HUB_sample_is_coming_from = source.hfr_id_for_HUB_sample_is_coming_from
        AND target.report_date = source.report_date

   

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_fact_daily_sample_summary_update_columns_group_by_result_dispatched_date';

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
		result_tnd = eid_result_tnd + hvl_result_tnd,
		sample_referred = eid_sample_referred + hvl_sample_referred,
		referral_result_received = eid_referral_result_received + hvl_referral_result_received;

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
    EXEC final.sp_fact_daily_sample_summary_update_columns_group_by_lab_received_date;
    EXEC final.sp_fact_daily_sample_summary_update_columns_group_by_tested_date;
    EXEC final.sp_fact_daily_sample_summary_update_columns_group_by_collected_date;
    EXEC final.sp_fact_daily_sample_summary_update_pending_result;
    EXEC final.sp_fact_daily_sample_summary_update_columns_group_by_result_authorised_date;
    EXEC final.sp_fact_daily_sample_summary_update_columns_group_by_result_dispatched_date;
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

    EXEC final.sp_dim_week;
    EXEC final.sp_fact_daily_sample_summary;

-- $END

EXEC dbo.sp_etl_tracking_update_end_of_sp_execution 'final.sp_data_processing';

END
GO
