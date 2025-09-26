import sys
import pandas as pd
import pytds
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import SQLAlchemyError 
from pytds import Connection
from data_task_helpers import something
from services.dte_tools.data_task_tools import (
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)

environment: DataTaskEnvironment = initialise_data_task("Todays Analysis Task", params={})
ana_db_params = get_resolved_parameters_for_connection("ANA")
lab_db_params = get_resolved_parameters_for_connection("LAB_DATA_SOURCE")

def log_message(msg: str) -> None:
    environment.log_message(msg)

def connect_mysql() -> Engine:
    url = (
        f"mysql+pymysql://{lab_db_params['username']}:{lab_db_params['password']}"
        f"@{lab_db_params['server']}:{lab_db_params['port']}/{lab_db_params['database']}"
    )
    try:
        engine = create_engine(url)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        log_message("Connection to source (MySQL) database established")
        return engine
    except SQLAlchemyError as e:
        log_message(f"Failed to establish connection to source database: {e}")
        sys.exit(1)


def connect_sql_server() -> Connection:
    """Establish connection to MSSQL analysis database."""
    try:
        conn = pytds.connect(
            server=ana_db_params["server"],
            user=ana_db_params["username"],
            password=ana_db_params["password"],
            database=ana_db_params["database"],
            port=int(ana_db_params.get("port", 1443)),
            autocommit=True,
        )
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1")
        log_message("Connection to analysis (MSSQL) database established")
        return conn
    except pytds.Error as e:
        log_message(f"Failed to establish connection to analysis database: {e}")
        sys.exit(1)


def fetch_source_data(engine: Engine) -> pd.DataFrame:
    log_message("Fetching data from source database...")
    query = """
    SELECT 
        testName AS metric_type, 
        'received' AS metric_name,
        SUM(dateReceivedLab >= CURDATE() AND dateReceivedLab < CURDATE() + INTERVAL 1 DAY) AS metric_value,
        CONCAT('Total ', testName, ' received samples') AS metric_description
    FROM tbl_labtests
    GROUP BY testName
    UNION ALL
    SELECT 
        testName, 
        'rejected',
        SUM(dateReceivedLab >= CURDATE() AND dateReceivedLab < CURDATE() + INTERVAL 1 DAY),
        CONCAT('Total ', testName, ' rejected samples')
    FROM tbl_labtests 
    WHERE orderStatus IN (5, 6)
    GROUP BY testName
    UNION ALL
    SELECT 
        testName, 
        'tested',
        SUM(testedDate >= CURDATE() AND testedDate < CURDATE() + INTERVAL 1 DAY),
        CONCAT('Total ', testName, ' tested samples')
    FROM tbl_labtests
    GROUP BY testName
    UNION ALL
    SELECT 
        testName, 
        'authorised',
        SUM(resultAuthorisedDate >= CURDATE() AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY),
        CONCAT('Total ', testName, ' authorised results')
    FROM tbl_labtests
    GROUP BY testName
    UNION ALL
    SELECT 
        'HIVVL', 
        'total_hvl_target_not_detected', 
        COUNT(trackingID), 
        'HIVVL target not detected'
    FROM tbl_labtests 
    WHERE resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY
        AND LOWER(REPLACE(results, ' ', '')) IN ('tnd', 'targetnotdetected') 
        AND testName = 'HIVVL'
    UNION ALL
     SELECT 
        'HIVVL', 
        'hvl_failed', 
        COUNT(trackingID), 
        'HIVVL failed and invalid'
    FROM tbl_labtests 
    WHERE resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY
        AND LOWER(REPLACE(results, ' ', '')) IN ('failed', 'invalid') 
        AND testName = 'HIVVL'
    UNION ALL
    SELECT 
        'HIVVL', 
        'total_suppressed_lt50', 
        COUNT(trackingID), 
        'Suppressed VL less than 50'
    FROM tbl_labtests 
    WHERE (CAST(results AS UNSIGNED) < 50 OR results LIKE '%%<%%')
        AND resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY 
        AND testName = 'HIVVL'
    UNION ALL
    SELECT 
        'HIVVL', 
        'total_suppressed_lt1000', 
        COUNT(trackingID), 
        'Suppressed VL less than 1000'
    FROM tbl_labtests 
    WHERE (CAST(results AS UNSIGNED) < 1000 OR CAST(results AS UNSIGNED) >= 50)
        AND resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY 
        AND testName = 'HIVVL'
    UNION ALL
    SELECT 
        'HIVVL', 
        'total_unsuppressed', 
        COUNT(trackingID), 
        'Unsuppressed VL'
    FROM tbl_labtests 
    WHERE (CAST(results AS UNSIGNED) >= 1000 OR results LIKE '%%>%%')
        AND resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY
        AND testName = 'HIVVL'
    UNION ALL
    SELECT 
        'EID', 
        'total_eid_positive', 
        COUNT(trackingID), 
        'EID positive results'
    FROM tbl_labtests 
    WHERE testName = 'EID' 
        AND LOWER(REPLACE(results, ' ', '')) = 'positive'
        AND resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY
    UNION ALL
    SELECT 
        'EID', 
        'total_eid_negative', 
        COUNT(trackingID), 
        'EID negative results'
    FROM tbl_labtests 
    WHERE testName = 'EID' 
        AND LOWER(REPLACE(results, ' ', '')) = 'negative'
        AND resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY
    UNION ALL
    SELECT 
        'EID', 
        'total_eid_indeterminate', 
        COUNT(trackingID), 
        'EID indeterminate results'
    FROM tbl_labtests 
    WHERE testName = 'EID' 
        AND LOWER(REPLACE(results, ' ', '')) IN ('indeterminate', 'intermidiate')
        AND resultAuthorisedDate >= CURDATE() 
        AND resultAuthorisedDate < CURDATE() + INTERVAL 1 DAY
    UNION ALL
    SELECT 
        testName,
        CASE WHEN hubCode = testCenter THEN 'LAB' ELSE 'HUB' END AS metric_name,
        COUNT(trackingID) AS metric_value,
        CONCAT('Total ', testName, ' REGISTERED in ', 
            CASE WHEN hubCode = testCenter THEN 'LAB' ELSE 'HUB' END) AS metric_description
    FROM tbl_labtests
    WHERE dateReceivedLab >= CURDATE() 
        AND dateReceivedLab < CURDATE() + INTERVAL 1 DAY
    GROUP BY 
        testName,
        CASE WHEN hubCode = testCenter THEN 'LAB' ELSE 'HUB' END
    UNION ALL
    SELECT 
		testName, 
		'Reffered',
		SUM(referredDate >= CURDATE() AND referredDate < CURDATE() + INTERVAL 1 DAY),
		CONCAT(testName, '- Reffered Samples')
	FROM tbl_labtests tl 
	WHERE 
		orderStatus = 8 
		and referralFacility is not null
	GROUP BY testName
	UNION ALL
	SELECT 
		testName, 
		'Rejected At Other Lab',
		SUM(referredDate >= CURDATE() AND referredDate < CURDATE() + INTERVAL 1 DAY),
		CONCAT(testName, '- Rejected At Other Lab Samples')
	FROM tbl_labtests tl 
	WHERE 
		orderStatus = 6 
		AND referralFacility is not null
	GROUP BY testName
	UNION ALL
	SELECT 
		testName, 
		'Results At Other Lab',
		SUM(referredDate >= CURDATE() AND referredDate < CURDATE() + INTERVAL 1 DAY),
		 CONCAT(testName, '- Results At Other Lab') 
	FROM tbl_labtests tl
	WHERE 
		orderStatus = 4 
		AND referralFacility is not null
	GROUP BY testName
    UNION ALL
    SELECT 
        testName, 
        (CASE WHEN dataFrom = 0 THEN 'ENTRY FROM LAB'
            WHEN dataFrom = 1 THEN 'ENTRY FROM HUB'
            WHEN dataFrom = 2 THEN 'ENTRY FROM CTC' 
        END),
        SUM(dateReceivedLab >= CURDATE() AND dateReceivedLab < CURDATE() + INTERVAL 1 DAY),
        CONCAT(testName, '- ENTRY MODALITY') 
    FROM tbl_labtests tl
    GROUP BY testName, dataFrom;
    """
    return pd.read_sql(query, engine)


def ensure_todays_lab_analysis_table_exists(conn: Connection) -> None:
    """Ensure target comparison table exists in MSSQL."""
    with conn.cursor() as cursor:
        cursor.execute("""
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='todays_lab_analysis' AND xtype='U')
        CREATE TABLE todays_lab_analysis (
            metric_id INT IDENTITY(1,1) PRIMARY KEY,  
            metric_type VARCHAR(50) NULL,  
            metric_name VARCHAR(100) NULL,  
            metric_value INT NULL,  
            metric_description VARCHAR(255) NULL, 
            created_datetime DATETIME DEFAULT GETDATE(),
            updated_datetime DATETIME DEFAULT GETDATE()
        );
        """)
        log_message("Ensured table 'todays_lab_analysis' exists")


def refresh_metrics(metrics: pd.DataFrame, conn: Connection) -> None:
    """Delete existing rows and insert fresh metrics into MSSQL."""
    with conn.cursor() as cursor:
        cursor.execute("TRUNCATE TABLE todays_lab_analysis;")
        insert_sql = """
            INSERT INTO todays_lab_analysis (metric_type, metric_name, metric_value, metric_description, created_datetime, updated_datetime)
            VALUES (%s, %s, %s, %s, GETDATE(), GETDATE())
        """
        values = [
                (row.metric_type, row.metric_name, int(row.metric_value or 0), row.metric_description)
                for row in metrics.itertuples(index=False)
            ]
        cursor.executemany(insert_sql, values)
    conn.commit()
    log_message(f"Inserted {len(metrics)} fresh metrics into todays_lab_analysis")

def insert_data() -> None:
    try:
        labdash_engine = connect_mysql()
        sql_conn = connect_sql_server()
        source_df = fetch_source_data(labdash_engine)
        ensure_todays_lab_analysis_table_exists(sql_conn)
        refresh_metrics(source_df, sql_conn)
    except Exception as e:
        log_message(f"An error occurred during data insertion: {e}")
        sys.exit(1)


if __name__ == "__main__":
    insert_data()