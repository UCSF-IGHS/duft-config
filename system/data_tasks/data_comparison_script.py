import sys
import pandas as pd  # type: ignore
import pytds  # type: ignore
from sqlalchemy import create_engine, text  # type: ignore
from sqlalchemy.engine import Engine  # type: ignore
from sqlalchemy.exc import SQLAlchemyError  # type: ignore
from pytds import Connection  # type: ignore

from services.dte_tools.data_task_tools import (  # type: ignore
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)


# Initialize environment and DB parameters
environment: DataTaskEnvironment = initialise_data_task("Data Comparison Task", params={})
ana_db_params = get_resolved_parameters_for_connection("ANA")
lab_db_params = get_resolved_parameters_for_connection("LAB_DATA_SOURCE")


def log_message(msg: str) -> None:
    """Log messages to the data task environment."""
    environment.log_message(msg)


def connect_mysql() -> Engine:
    """Establish connection to MySQL lab database."""
    url = (
        f"mysql+pymysql://{lab_db_params['username']}:{lab_db_params['password']}"
        f"@{lab_db_params['server']}:{lab_db_params['port']}/{lab_db_params['database']}"
    )
    try:
        engine = create_engine(url)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        log_message("Connected successfully to labdashdb.")
        return engine
    except SQLAlchemyError as e:
        log_message(f"Failed to connect to labdashdb: {e}")
        sys.exit(1)


def connect_sql_server() -> Connection:
    """Establish connection to MSSQL analysis database."""
    try:
        conn = pytds.connect(
            server=ana_db_params["server"],
            user=ana_db_params["username"],
            password=ana_db_params["password"],
            database=ana_db_params["database"],
            port=int(ana_db_params.get("port", 1433)),
            autocommit=True,
        )
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1")
        log_message(f"Connected successfully to {ana_db_params['database']}.")
        return conn
    except pytds.Error as e:
        log_message(f"Failed to connect to {ana_db_params['database']}: {e}")
        sys.exit(1)


def fetch_source_data(engine: Engine) -> pd.DataFrame:
    """Fetch aggregated sample data from MySQL source."""
    
    query = """
        SELECT
            date,
            SUM(samples_collected) AS samples_collected,
            SUM(samples_received) AS samples_received,
            SUM(samples_tested) AS samples_tested,
            SUM(samples_dispatched) AS samples_dispatched
        FROM (
            SELECT DATE(sampleCollectionDate) AS date,
                COUNT(trackingId) AS samples_collected,
                0 AS samples_received,
                0 AS samples_tested,
                0 AS samples_dispatched
            FROM tbl_labtests
            WHERE sampleCollectionDate IS NOT NULL
            GROUP BY DATE(sampleCollectionDate)
        UNION ALL
            SELECT DATE(dateReceivedLab) AS date,
                0 AS samples_collected,
                COUNT(trackingId) AS samples_received,
                0 AS samples_tested,
                0 AS samples_dispatched
            FROM tbl_labtests
            WHERE dateReceivedLab IS NOT NULL
            GROUP BY DATE(dateReceivedLab)
        UNION ALL
            SELECT DATE(testedDate) AS date,
                0 AS samples_collected,
                0 AS samples_received,
                COUNT(trackingId) AS samples_tested,
                0 AS samples_dispatched
            FROM tbl_labtests
            WHERE testedDate IS NOT NULL
            GROUP BY DATE(testedDate)
        UNION ALL
            SELECT DATE(resultAuthorisedDate) AS date,
                0 AS samples_collected,
                0 AS samples_received,
                0 AS samples_tested,
                COUNT(trackingId) AS samples_dispatched
            FROM tbl_labtests
            WHERE resultAuthorisedDate IS NOT NULL
            GROUP BY DATE(resultAuthorisedDate)
        ) AS combined
        GROUP BY date
        ORDER BY date DESC;
    """
    return pd.read_sql(query, engine)


def fetch_analysis_data(conn: Connection) -> pd.DataFrame:
    """Fetch aggregated sample data from MSSQL analysis DB using UNPIVOT."""
    query = """
        SELECT
            report_date,
            SUM(CASE WHEN metric = 'sample_collected' THEN value ELSE 0 END) AS samples_collected,
            SUM(CASE WHEN metric = 'sample_received' THEN value ELSE 0 END) AS samples_received,
            SUM(CASE WHEN metric = 'sample_tested' THEN value ELSE 0 END) AS samples_tested,
            SUM(CASE WHEN metric = 'result_authorized' THEN value ELSE 0 END) AS samples_dispatched
        FROM (
            SELECT report_date, metric, value
            FROM [final].fact_daily_sample_summary
            UNPIVOT (
                value FOR metric IN (
                    sample_collected,
                    sample_received,
                    sample_tested,
                    result_authorized
                )
            ) AS unpvt
        ) AS pivoted
        GROUP BY report_date
        ORDER BY report_date;
    """
    return pd.read_sql(query, conn)


def ensure_data_comparison_table(conn: Connection) -> None:
    """Ensure target comparison table exists."""
    
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = 'final' AND TABLE_NAME = 'data_comparison';
        """)
        if cursor.fetchone()[0] == 0:
            cursor.execute("""
                CREATE TABLE final.data_comparison (
                    report_date DATE,
                    category NVARCHAR(64),
                    source_value INT,
                    analysis_value INT,
                    difference INT
                );
            """)
            log_message("Created table final.data_comparison.")


def compare_data() -> None:
    """Compare lab and analysis data, then insert differences into SQL Server."""
    
    try:
        labdash_engine = connect_mysql()
        sql_conn = connect_sql_server()

        source_df = fetch_source_data(labdash_engine)
        analysis_df = fetch_analysis_data(sql_conn)

        labels = [
            "Collected Samples",
            "Received Samples",
            "Tested Samples",
            "Authorized/dispatched samples"
        ]

        ensure_data_comparison_table(sql_conn)

        insert_query = """
            INSERT INTO final.data_comparison (
                report_date, category, source_value, analysis_value, difference
            ) VALUES (%s, %s, %s, %s, %s)
        """

        all_rows_to_insert = []

        for _, source_row in source_df.iterrows():
            report_date = pd.to_datetime(source_row["date"]).date()
            analysis_row = analysis_df[analysis_df["report_date"] == report_date]

            if analysis_row.empty:
                continue

            analysis_row = analysis_row.iloc[0]

            source_values = [
                source_row["samples_collected"],
                source_row["samples_received"],
                source_row["samples_tested"],
                source_row["samples_dispatched"],
            ]
            analysis_values = [
                analysis_row["samples_collected"],
                analysis_row["samples_received"],
                analysis_row["samples_tested"],
                analysis_row["samples_dispatched"],
            ]
            differences = [s - a for s, a in zip(source_values, analysis_values)]

            all_rows_to_insert.extend([
                (
                    report_date,
                    labels[i],
                    int(source_values[i]),
                    int(analysis_values[i]),
                    int(differences[i]),
                ) for i in range(4)
            ])

            with sql_conn.cursor() as cursor:
                cursor.execute(
                    "DELETE FROM final.data_comparison WHERE report_date = %s",
                    (report_date,),
                )

        with sql_conn.cursor() as cursor:
            for row in all_rows_to_insert:
                cursor.execute(insert_query, row)

        log_message("Inserted all comparison data into final.data_comparison.")

    except Exception as e:
        log_message(f"An error occurred during data comparison: {e}")
        sys.exit(1)


if __name__ == "__main__":
    compare_data()
