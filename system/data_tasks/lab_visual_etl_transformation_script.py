import asyncio
import os
import pytds
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

executor = ThreadPoolExecutor(max_workers=4)
environment: DataTaskEnvironment = initialise_data_task("Tille Lab transformation Task", params={})
db_params = get_resolved_parameters_for_connection("ANA")

# Function to log messages
def log_message(msg):
    return environment.log_message(msg)

# Function to format datetime values (pytds requirements)
def format_datetime(value):
    if pd.isna(value):
        return None
    if isinstance(value, datetime):
        return value
    if hasattr(value, 'to_pydatetime'):
        return value.to_pydatetime()
    if isinstance(value, str):
        try:
            return datetime.strptime(value, '%Y-%m-%d %H:%M:%S')
        except ValueError:
            return None
    return None

log_message(f"Started Tille Lab Transformation {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")


# Function to connect to the Tille Lab database
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

labdashdb_conn = connect_to_tille_lab_db('root', 'root', 'localhost')

# Function to create a connection to SQL Server
def create_connection_to_sql_server(db_name):
    try:
        conn = pytds.connect(
            server=db_params["server"],
            user=db_params["username"],
            password=db_params["password"],
            database=db_name,
            port=int(db_params.get("port", 1433)),
            autocommit=True
        )
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        log_message(f"Created Connection successfully to SQLSERVER")
        return conn
    except pytds.Error as e:
        log_message(f"Failed to create connection to {db_name}")
        sys.stdout.flush()
        sys.exit(1)
    
labvisualDB_conn = create_connection_to_sql_server("master")
if labvisualDB_conn:
    labvisualDB_cursor = labvisualDB_conn.cursor()


# Function to create schemas in the Lab Visual Analysis database
def create_schemas():
    try:
        schemas = ['source', 'derived', 'final', 'z', 'dbo']
        
        for schema in schemas:
            labvisualDB_cursor.execute(
                f"""
                    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema}')
                    BEGIN
                        EXEC('CREATE SCHEMA {schema}');
                    END
                """
            )

        labvisualDB_conn.commit()
    except Exception as e:
        log_message(f"Error creating schemas: {e}")
        labvisualDB_conn.rollback()
        sys.stdout.flush()
        sys.exit(1) 


# Function to create tables in the Lab Visual Analysis database
def create_tables():
    table_creation_queries = [
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Facilities' AND schema_id = SCHEMA_ID('source'))
            BEGIN
                CREATE TABLE source.tbl_Facilities (
                    Id INT IDENTITY(1,1) PRIMARY KEY,
                    HfrCode NVARCHAR(50),
                    Name NVARCHAR(255),
                    Region NVARCHAR(255),
                    District NVARCHAR(255),
                    Council NVARCHAR(255)
                );
            END
        """,
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Device_Logs' AND schema_id = SCHEMA_ID('source'))
            BEGIN
                CREATE TABLE source.tbl_Device_Logs (
                    Id INT IDENTITY(1,1) PRIMARY KEY,
                    DeviceName NVARCHAR(255),
                    DeviceCode NVARCHAR(50),
                    DateBrokenDown DATETIME2,
                    DateReported DATETIME2,
                    DateFixed DATETIME2,
                    BreakDownReason NVARCHAR(255)
                );
            END
        """,
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Commodity_Transactions' AND schema_id = SCHEMA_ID('source'))
            BEGIN
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
            END
        """,
        """
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Sample' AND schema_id = SCHEMA_ID('source'))
            BEGIN
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
            END
        """
    ]

    for query in table_creation_queries:
        try:
            labvisualDB_cursor.execute(query)
        except Exception as e:
            log_message(f"Error creating table: {e}")
            sys.stdout.flush()
            sys.exit(1) 
    labvisualDB_conn.commit()
         

# Function to create the Lab Visual Analysis database
def create_lab_visual_analysis_database():
    global labvisualDB_conn, labvisualDB_cursor

    try:
        log_message(f"Preparing {db_params['database']} Database")

        # Check if database exists
        labvisualDB_cursor.execute("SELECT name FROM sys.databases WHERE name = %s", (db_params['database'],))
        labvisualDB_exists = labvisualDB_cursor.fetchone()

        if labvisualDB_exists:
            log_message(f"Truncating {db_params['database']} database tables")
            labvisualDB_cursor.execute(f"USE {db_params['database']};")

            try:
                labvisualDB_cursor.execute("""
                    DECLARE @sql NVARCHAR(MAX) = '';
                    SELECT @sql += 'DELETE FROM [' + s.name + '].[' + t.name + '];' + CHAR(13)
                    FROM sys.tables t
                    JOIN sys.schemas s ON t.schema_id = s.schema_id
                    WHERE t.is_ms_shipped = 0;
                    EXEC sp_executesql @sql;
                """)
                create_schemas()
                create_tables()
            except Exception as e:
                log_message(f"Error truncating tables: {e}")
                labvisualDB_conn.rollback()
                sys.stdout.flush()
                sys.exit(1) 
            labvisualDB_conn.commit()
            log_message("Lab Visual Analysis Database preparation complete")
        else:
            labvisualDB_cursor.execute(f"CREATE DATABASE [{db_params['database']}]")
            labvisualDB_conn.commit()
            log_message(f"Database {db_params['database']} created.")
            labvisualDB_conn.close()
            labvisualDB_conn = create_connection_to_sql_server(db_params['database'])
            labvisualDB_cursor = labvisualDB_conn.cursor()

            log_message("Creating Schemas...")
            create_schemas()

            log_message("Creating Tables...")
            create_tables()

            log_message("Lab Visual Database preparation complete")
    except Exception as e:
        log_message(f"Failed to prepare database: {e}")
        labvisualDB_conn.rollback()
        sys.stdout.flush()
        sys.exit(1) 
create_lab_visual_analysis_database()


# Function to extract and insert facility data
def extract_and_insert_facility_data():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    health_facilities_masterlist = os.path.join(script_dir, "All_Operating_Health_Facilities_in_Tanzania-Lab-Visual-2021oct22.xlsx")

    if not os.path.exists(health_facilities_masterlist):
        log_message(f"Excel file '{health_facilities_masterlist}' not found.")
        
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
    
    df_combined = pd.concat([df_excel, df_mysql], ignore_index=True)
    df_combined.drop_duplicates(subset=['HfrCode'], keep='first', inplace=True)
    df_combined = df_combined.where(pd.notnull(df_combined), None)
    
    if len(df_combined) > 0:
        log_message(f"{len(df_combined)} rows fetched from tbl_Facilities.")

    insert_query = """
        INSERT INTO source.tbl_Facilities (HfrCode, Name, Region, District, Council)
        VALUES (%s, %s, %s, %s, %s);
    """
    insert_count = 0
    
    try:
        for _, row in df_combined.iterrows():
            labvisualDB_cursor.execute(
                insert_query, 
                (
                    row['HfrCode'], 
                    row['Name'], 
                    row['Region'], 
                    row['District'], 
                    row['Council']
                )
            )
            insert_count += 1
        labvisualDB_conn.commit()
        if insert_count > 0:
            log_message(f"{insert_count} rows inserted into tbl_Facilities.")
    except Exception as e:
        log_message(f"Error inserting data: {e}")
        labvisualDB_conn.rollback()
        sys.stdout.flush()
        sys.exit(1) 
extract_and_insert_facility_data()


# Function to extract and insert samples data
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
        if len(sample_data) > 0:
            log_message(f"{len(sample_data)} sample data fetched.")

        def extract_hfr_code(row):
            if row['EntryModality'] == 'lab':
                return row['facilityHfrID'], None
            else:
                return None, row['facilityHfrID']

        sample_data[['LabHfrCode', 'HubHfrCode']] = sample_data.apply(extract_hfr_code, axis=1, result_type='expand')
        
        insert_query = """
            INSERT INTO source.tbl_Sample (sampletrackingid, LabHfrCode, HubHfrCode, EntryModality, SampleType, 
                                        TestName, SampleQualityStatus, Results, SampleRejectionReason, DeviceName, 
                                        DeviceCode, CollectionDate, ReceivedDate, TestDate, AuthorisedDate, DispatchDate)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        insert_count = 0
        for _, row in sample_data.iterrows():
            try:
                labvisualDB_cursor.execute(
                    insert_query, 
                    (
                        row['sampletrackingid'], 
                        row['LabHfrCode'], 
                        row['HubHfrCode'], 
                        row['EntryModality'], 
                        row['SampleType'], 
                        row['TestName'], 
                        row['SampleQualityStatus'], 
                        row['Results'], 
                        row['SampleRejectionReason'], 
                        row['DeviceName'], 
                        row['DeviceCode'], 
                        format_datetime(row['CollectionDate']), 
                        format_datetime(row['ReceivedDate']), 
                        format_datetime(row['TestDate']), 
                        format_datetime(row['AuthorisedDate']), 
                        format_datetime(row['DispatchDate'])
                    )
                )
                insert_count += 1
            except Exception as row_err:
                log_message(f"Error inserting row: {row_err} - Row: {row.to_dict()}")
                sys.stdout.flush()
                sys.exit(1) 
        labvisualDB_conn.commit()
        if insert_count > 0:
            log_message(f"{len(sample_data)} row inserted into tbl_Sample.")
    except Exception as e:
        labvisualDB_conn.rollback()
        log_message(f"Error inserting data: {e}")
        sys.stdout.flush()
        sys.exit(1) 
extract_and_insert_sample_data()


# Function to extract and insert device log data
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
        if len(device_logs) > 0:
            log_message(f"{len(device_logs)} device logs fetched.")
        
        insert_query = """
        INSERT INTO source.tbl_Device_Logs (DeviceName, DeviceCode, DateBrokenDown, DateReported, DateFixed, BreakDownReason)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        insert_count = 0
        
        for _, row in device_logs.iterrows():
            try:
                labvisualDB_cursor.execute(
                    insert_query, 
                    (
                        row['DeviceName'],
                        row['DeviceCode'],
                        format_datetime(row['DateBrokenDown']),
                        format_datetime(row['DateReported']),
                        format_datetime(row['DateFixed']),
                        row['BreakDownReason']
                    )
                )
                insert_count += 1
            except Exception as row_err:
                log_message(f"Error inserting row: {row_err} - Row: {row.to_dict()}")
                sys.stdout.flush()
                sys.exit(1) 
        labvisualDB_conn.commit()
        if insert_count > 0:
            log_message(f"{insert_count} rows inserted into tbl_Device_Logs.")
    except Exception as e:
        log_message(f"Error fetching or inserting device logs: {e}")
        labvisualDB_conn.rollback()
        sys.stdout.flush()
        sys.exit(1) 
extract_and_insert_device_log_data()


# Function to extract and insert commodity transaction data
def extract_and_insert_commodity_transaction_data():
    query = """
        SELECT 
            commodityName AS CommodityName, 
            commodityCode AS CommodityCode, 
            batchNo AS BatchNumber, 
            transactionDate AS TransactionDate, 
            expireDate AS ExpireDate, 
            transactionType AS TransactionType, 
            quantity AS TransactionQuantity 
        FROM commoditytransactions
    """
    
    try:
        commodity_transactions = pd.read_sql(query, labdashdb_conn)
        if len(commodity_transactions) > 0:
            log_message(f"{len(commodity_transactions)} commodity transactions fetched.")
        
        insert_query = """
            INSERT INTO source.tbl_Commodity_Transactions (CommodityName, CommodityCode, BatchNumber, TransactionDate, ExpireDate, TransactionType, TransactionQuantity)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        insert_count = 0
        for _, row in commodity_transactions.iterrows():
            try:
                labvisualDB_cursor.execute(
                    insert_query, 
                    (
                        row['CommodityName'], 
                        row['CommodityCode'], 
                        row['BatchNumber'], 
                        format_datetime(row['TransactionDate']),
                        format_datetime(row['ExpireDate']), 
                        row['TransactionType'], 
                        row['TransactionQuantity']
                    )
                )
                insert_count += 1
            except Exception as row_err:
                log_message(f"Error inserting row: {row_err} - Row: {row.to_dict()}")
                sys.stdout.flush()
                sys.exit(1) 
        labvisualDB_conn.commit()
        if insert_count > 0:
            log_message(f"{insert_count} rows inserted into tbl_Commodity_Transactions.")
    except Exception as e:
        log_message(f"Error fetching or inserting commodity transactions: {e}")
        labvisualDB_conn.rollback()
        sys.stdout.flush()
        sys.exit(1) 
extract_and_insert_commodity_transaction_data()
        

# Function to extract and insert data from the Stored Procedures file
def extract_stored_procedures_from_file():
    log_message("Running ETL")

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


# Function to execute stored procedures
def execute_stored_procedures():
    try:
        labvisualDB_cursor.execute("EXEC dbo.sp_data_processing")
    
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
        sys.stdout.flush()
        sys.exit(1)  
    finally:
        if 'mssql_conn' in locals():
            labvisualDB_cursor.close()
            labvisualDB_conn.close()
            labdashdb_conn.close()


async def run_sp_data_processing_async():
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(executor, execute_stored_procedures)

asyncio.run(run_sp_data_processing_async())

log_message("ETL complete")
log_message(f"Completed Tille Lab Transformation {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
