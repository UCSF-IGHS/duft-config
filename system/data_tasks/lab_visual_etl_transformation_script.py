import asyncio
import os
import pyodbc
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import sys
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor
from services.dte_tools.data_task_tools import (
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Optional: use a global thread pool executor
executor = ThreadPoolExecutor(max_workers=4)

environment: DataTaskEnvironment = initialise_data_task("Tille Lab transformation Task", params={})
db_params = get_resolved_parameters_for_connection("ANA")

def log_message(msg):
    return environment.log_message(msg)

log_message(f"Started Tille Lab Transformation {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")

# Connect to tillelab db
def connect_to_tille_lab_db(db_user, db_pword, db_host):
    url = f"mysql+pymysql://{db_user}:{db_pword}@{db_host}:3306/labdashdb"
    try:
        engine = create_engine(url)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        log_message("Connected Successfully to labdashdb")
        return engine
    except SQLAlchemyError as e:
        log_message("Failed to connect to labdashdb")
        sys.stdout.flush()
        sys.exit(1) 
        return None

labdashdb_conn = connect_to_tille_lab_db('root', 'root', 'localhost')


def create_connection_to_sql_server(db_name):
    try:
        conn = pyodbc.connect(
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER=localhost;"
            f"DATABASE={db_name};"
            f"UID=sa;"
            f"PWD=root.R00T;"
            f"TrustServerCertificate=yes;",
            autocommit=True
        )
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        log_message(f"Created Connection successfully to SQLSERVER")
        return conn
    except pyodbc.Error as e:
        log_message(f"Failed to create connection to {db_name}")
        sys.stdout.flush()
        sys.exit(1) 
        return None
    
labvisualDB_conn = create_connection_to_sql_server("master")
if labvisualDB_conn:
    labvisualDB_cursor = labvisualDB_conn.cursor()


def create_schemas():
    try:
        schemas = ['source', 'derived', 'final', 'z', 'dbo']
        
        for schema in schemas:
            labvisualDB_cursor.execute(
                f"""
                    USE lab_visual_analysis;

                    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema}')
                    BEGIN
                        EXEC('CREATE SCHEMA {schema}');
                    END
                """
            )

        labvisualDB_cursor.commit()
    except Exception as e:
        log_message(f"Error creating schemas: {e}")
        labvisualDB_cursor.rollback()


def create_tables():
    table_creation_queries = [
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Facilities' AND schema_id = SCHEMA_ID('source'))
            CREATE TABLE source.tbl_Facilities (
                Id INT IDENTITY(1,1) PRIMARY KEY,
                HfrCode NVARCHAR(50),
                Name NVARCHAR(255),
                Region NVARCHAR(255),
                District NVARCHAR(255),
                Council NVARCHAR(255)
            );
        """,
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Device_Logs' AND schema_id = SCHEMA_ID('source'))
            CREATE TABLE source.tbl_Device_Logs (
                Id INT IDENTITY(1,1) PRIMARY KEY,
                DeviceName NVARCHAR(255),
                DeviceCode NVARCHAR(50),
                DateBrokenDown DATETIME2,
                DateReported DATETIME2,
                DateFixed DATETIME2,
                BreakDownReason NVARCHAR(255)
            );
        """,
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Commodity_Transactions' AND schema_id = SCHEMA_ID('source'))
            CREATE TABLE source.tbl_Commodity_Transactions (
                Id INT IDENTITY(1,1) PRIMARY KEY,
                CommodityName NVARCHAR(255),
                CommodityCode NVARCHAR(50),
                BatchNumber NVARCHAR(50),
                TransactionDate DATETIME2,
                ExpireDate DATETIME2,
                TransactionType NVARCHAR(50),
                TransactionQuantity INT
            );
        """,
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Sample' AND schema_id = SCHEMA_ID('source'))
            CREATE TABLE source.tbl_Sample (
                Id INT IDENTITY(1,1) PRIMARY KEY,
                sampletrackingid NVARCHAR(50),
                LabHfrCode NVARCHAR(50),
                HubHfrCode NVARCHAR(50),
                EntryModality NVARCHAR(50),
                SampleType NVARCHAR(255),
                TestName NVARCHAR(255),   
                SampleQualityStatus NVARCHAR(50),
                Results NVARCHAR(255),
                SampleRejectionReason NVARCHAR(255),
                DeviceName NVARCHAR(255),
                DeviceCode NVARCHAR(50),
                CollectionDate DATETIME2,
                ReceivedDate DATETIME2,
                TestDate DATETIME2,
                AuthorisedDate DATETIME2,
                DispatchDate DATETIME2
            );
        """
    ]

    for query in table_creation_queries:
        try:
            labvisualDB_cursor.execute(query)
        except Exception as e:
            log_message(f"Error creating table: {e}")

    labvisualDB_cursor.commit()
         

def create_lab_visual_analysis_database():
    global labvisualDB_conn, labvisualDB_cursor

    try:
        log_message("Preparing Lab Visual Database")

        # Check if database exists
        labvisualDB_cursor.execute("SELECT name FROM sys.databases WHERE name = 'lab_visual_analysis'")
        labvisualDB_exists = labvisualDB_cursor.fetchone()

        if labvisualDB_exists:
            log_message("Truncating LabVisual database tables")
            tables = ["tbl_Facilities", "tbl_Device_Logs", "tbl_Commodity_Transactions", "tbl_Sample"]

            for table in tables:
                try:
                    labvisualDB_cursor.execute(f"""
                        IF OBJECT_ID('source.{table}', 'U') IS NOT NULL
                            TRUNCATE TABLE source.{table}
                    """)
                except Exception as e:
                    log_message(f"Error truncating table {table}: {e}")
                    labvisualDB_conn.rollback()

            labvisualDB_conn.commit()
            log_message("Lab Visual Database preparation complete")

        else:
            # Create the database using a cursor (not conn directly)
            labvisualDB_cursor.execute("CREATE DATABASE lab_visual_analysis")
            labvisualDB_conn.commit()

            log_message("Database 'lab_visual_analysis' created.")

            # Reconnect to the new database
            labvisualDB_conn.close()
            labvisualDB_conn = create_connection_to_sql_server("lab_visual_analysis")
            labvisualDB_cursor = labvisualDB_conn.cursor()

            log_message("Creating Schemas...")
            create_schemas()

            log_message("Creating Tables...")
            create_tables()

            log_message("Lab Visual Database preparation complete")

    except Exception as e:
        log_message(f"Failed to prepare database: {e}")
        if labvisualDB_conn:
            labvisualDB_conn.rollback()
create_lab_visual_analysis_database()


def extract_and_insert_facility_data():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    health_facilities_masterlist = os.path.join(script_dir, "All_Operating_Health_Facilities_in_Tanzania-Lab-Visual-2021oct22.xlsx")

    if not os.path.exists(health_facilities_masterlist):
        log_message(f"Excel file '{health_facilities_masterlist}' not found.")
        sys.stdout.flush()
        sys.exit(1)
    
    df_excel = pd.read_excel(health_facilities_masterlist)
    df_excel.rename(columns={"Facility Number": "HfrCode", "Facility Name": "Name"}, inplace=True)
    df_excel = df_excel[['HfrCode', 'Name', 'Region', 'District', 'Council']]
    df_excel['Region'] = df_excel['Region'].str.replace("Region", "", regex=True).str.strip()
    
    mysql_query = """
        SELECT
            mohswid AS HfrCode,
            facilityname AS Name,
            regionname AS Region,
            districtname AS District,
            council AS Council
        FROM hubfacilities
    """

    try:
        df_mysql = pd.read_sql(mysql_query, labdashdb_conn)
    except Exception as e:
        log_message(f"Error fetching data from MySQL: {e}")
        sys.stdout.flush()
        sys.exit(1)
    
    # Merge the two datasets
    df_combined = pd.concat([df_excel, df_mysql])
    
    # Remove duplicates based on HfrCode
    df_combined.drop_duplicates(subset=['HfrCode'], keep='first', inplace=True)
    
    # Fetch existing HfrCodes to avoid primary key conflict
    try:
        existing_hfrcodes = pd.read_sql("SELECT HfrCode FROM source.tbl_Facilities", labvisualDB_conn)
        df_combined = df_combined[~df_combined['HfrCode'].isin(existing_hfrcodes['HfrCode'])]
    except Exception as e:
        log_message(f"Error checking existing HfrCodes: {e}")
        sys.stdout.flush()
        sys.exit(1)

    insert_query = """
        INSERT INTO source.tbl_Facilities (HfrCode, Name, Region, District, Council)
        VALUES (?, ?, ?, ?, ?);
    """
    
    try:
        for _, row in df_combined.iterrows():
            labvisualDB_cursor.execute(insert_query, row['HfrCode'], row['Name'], row['Region'], row['District'], row['Council'])
            
        labvisualDB_conn.commit()
        if len(df_combined) > 0:
            log_message(f"{len(df_combined)} rows inserted into tbl_Facilities.")
    except Exception as e:
        log_message(f"Error inserting data: {e}")
        labvisualDB_conn.rollback()
extract_and_insert_facility_data()


def extract_and_insert_sample_data():
    query = """
        SELECT 
            DISTINCT trackingID as sampletrackingid, 
            facilityHfrID, 
            sampleType as SampleType, 
            testName as TestName, 
            sampleQuality as SampleQualityStatus, 
            rejectionReason as SampleRejectionReason, 
            sampleCollectionDate as CollectionDate, 
            dateReceivedLab as ReceivedDate, 
            results as Results, 
            testedDate as TestDate, 
            resultAuthorisedDate as AuthorisedDate, 
            resultAuthorisedDate as DispatchDate,
            testInstrument as DeviceName,
            NULL as DeviceCode,
            IF(SUBSTR(trackingID, 1, 4) = 'BC03', 'lab', 'hub') as EntryModality
        FROM tbl_labtests
        WHERE sampleCollectionDate >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
        OR dateSentLab >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
        OR dateReceivedLab >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
        OR registeredDate >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
        OR testedDate >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
        OR resultAuthorisedDate >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
        OR dateResultSentHub >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
    """
    
    try:
        sample_data = pd.read_sql(query, labdashdb_conn)
        if sample_data.empty:
            log_message("No sample data found.")
            sys.stdout.flush()
            sys.exit(1)

        def extract_hfr_code(row):
            if row['EntryModality'] == 'lab':
                return row['facilityHfrID'], None
            else:
                return None, row['facilityHfrID']

        sample_data[['LabHfrCode', 'HubHfrCode']] = sample_data.apply(extract_hfr_code, axis=1, result_type='expand')

        for _, row in sample_data.iterrows():
            insert_query = """
                INSERT INTO source.tbl_Sample (sampletrackingid, LabHfrCode, HubHfrCode, EntryModality, SampleType, 
                                            TestName, SampleQualityStatus, Results, SampleRejectionReason, DeviceName, 
                                            DeviceCode, CollectionDate, ReceivedDate, TestDate, AuthorisedDate, DispatchDate)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            
            labvisualDB_cursor.execute(insert_query, row['sampletrackingid'], row['LabHfrCode'], row['HubHfrCode'], 
                                row['EntryModality'], row['SampleType'], row['TestName'], row['SampleQualityStatus'], 
                                row['Results'], row['SampleRejectionReason'], row['DeviceName'], row['DeviceCode'], row['CollectionDate'], 
                                row['ReceivedDate'], row['TestDate'], row['AuthorisedDate'], row['DispatchDate'])
        
        labvisualDB_conn.commit()
        if len(sample_data) > 0:
            log_message(f"{len(sample_data)} row inserted into tbl_Sample.")

    except Exception as e:
        labvisualDB_conn.rollback()
        log_message(f"Error inserting data: {e}")
extract_and_insert_sample_data()


def extract_and_insert_device_log_data():
    query = """
        select
            deviceName as DeviceName,
            deviceCode as DeviceCode,
            dateBreakDown as DateBrokenDown,
            dateReported as DateReported,
            dateFixed as DateFixed,
            breakDownReason as BreakDownReason
        from
            instrumentlogs2
    """
    
    try:
        device_logs = pd.read_sql(query, labdashdb_conn)
        
        insert_query = """
        INSERT INTO source.tbl_Device_Logs (DeviceName, DeviceCode, DateBrokenDown, DateReported, DateFixed, BreakDownReason)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        
        for _, row in device_logs.iterrows():
            labvisualDB_cursor.execute(insert_query, row['DeviceName'], row['DeviceCode'], row['DateBrokenDown'], row['DateReported'], row['DateFixed'], row['BreakDownReason'])
        
        labvisualDB_conn.commit()
        if len(device_logs) > 0:
            log_message(f"{len(device_logs)} rows inserted into tbl_Device_Logs.")
    except Exception as e:
        log_message(f"Error fetching or inserting device logs: {e}")
        labvisualDB_conn.rollback()
extract_and_insert_device_log_data()


def extract_and_insert_commodity_transaction_data():
    query = """SELECT commodityName AS CommodityName, commodityCode AS CommodityCode, batchNo AS BatchNumber, transactionDate AS TransactionDate, 
                    expireDate AS ExpireDate, transactionType AS TransactionType, quantity AS TransactionQuantity FROM commoditytransactions"""
    
    try:
        commodity_transactions = pd.read_sql(query, labdashdb_conn)
        
        insert_query = """
            INSERT INTO source.tbl_Commodity_Transactions (CommodityName, CommodityCode, BatchNumber, TransactionDate, ExpireDate, TransactionType, TransactionQuantity)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        
        for _, row in commodity_transactions.iterrows():
            labvisualDB_cursor.execute(insert_query, row['CommodityName'], row['CommodityCode'], row['BatchNumber'], row['TransactionDate'],
                                row['ExpireDate'], row['TransactionType'], row['TransactionQuantity'])
        
        labvisualDB_conn.commit()
        if len(commodity_transactions) > 0:
            log_message(f"{len(commodity_transactions)} rows inserted into tbl_Commodity_Transactions.")
    
    except Exception as e:
        log_message(f"Error fetching or inserting commodity transactions: {e}")
        labvisualDB_conn.rollback()
extract_and_insert_commodity_transaction_data()
        

def extract_stored_procedures_from_file():
    log_message("Running ETL")
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    stored_procedures_file = os.path.join(script_dir, "create-stored-procedures.sql")
    if os.path.exists(stored_procedures_file):
        with open(stored_procedures_file, "r") as file:
            sql_commands = file.read()

        sql_batches = sql_commands.split("GO")
        log_message("Add SP")
        
        for batch in sql_batches:
            batch = batch.strip()

            if not batch or batch.startswith("--") or batch.startswith("/*"):
                continue

            if batch:
                try:
                    labvisualDB_cursor.execute(batch)
                    labvisualDB_conn.commit()
                except Exception as e:
                    log_message(f"Error loading batch: {e}")
                    labvisualDB_conn.rollback()
    else:
        log_message(f"SQL file '{stored_procedures_file}' not found.")
        sys.stdout.flush()
        sys.exit(1)
extract_stored_procedures_from_file()


def execute_stored_procedures():
    try:
        sp = "EXEC dbo.sp_data_processing"
        labvisualDB_cursor.execute(sp)
    
        while True:
            try:
                if labvisualDB_cursor.description:
                    labvisualDB_cursor.fetchall()
            except Exception as e:
                log_message(f"Ignored result set error: {e}")
            if not labvisualDB_cursor.nextset():
                break
        labvisualDB_conn.commit()

    except Exception as e:
        log_message(f"Error executing stored procedure: {e}")
        labvisualDB_conn.rollback()
        
    finally:
        if 'mssql_conn' in locals():
            labvisualDB_cursor.close()
            labvisualDB_conn.close()
            labdashdb_conn.dispose()


async def run_sp_data_processing_async():
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(executor, execute_stored_procedures)

asyncio.run(run_sp_data_processing_async())

log_message("ETL complete")
log_message(f"Completed Tille Lab Transformation {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")

