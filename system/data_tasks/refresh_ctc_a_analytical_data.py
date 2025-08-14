import asyncio
import os
import pandas as pd
import pytds
from concurrent.futures import ThreadPoolExecutor

from services.dte_tools.data_task_tools import (
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)

# Optional: use a global thread pool executor
executor = ThreadPoolExecutor(max_workers=2)


def write_to_database(environment, cursor, statement):
    cursor.execute(statement)
    while True:
        try:
            if cursor.description:
                cursor.fetchall()
        except Exception as e:
            environment.log_message(f"Ignored result set error: {e}")
        if not cursor.nextset():
            break


def read_facility_details(conn, environment):
    try:
        csv_path = os.path.expandvars(r"%USERPROFILE%\Documents\FacilityMasterList.csv")
        df = pd.read_csv(csv_path)

        environment.log_message(f"Loaded {len(df)} rows from FacilityMasterList.csv")

        with conn.cursor() as cursor:
            cursor.execute("SELECT hfr_code FROM derived.dim_facility")
            result = cursor.fetchone()

        if not result:
            environment.log_message("No hfr_code found in dim_facility.")
            return

        hfr_code = str(result[0]).strip()

        match = df[df["Facility Number"].astype(str).str.strip() == hfr_code]

        if match.empty:
            environment.log_message(f"No match found in CSV for HFR Code: {hfr_code}")
            return

        row = match.iloc[0]
        facility_name = str(row.get("Facility Name", "")).strip()
        district = str(row.get("District", "")).strip()
        region = str(row.get("Region", "")).strip()
        facility_type = str(row.get("Facility Type", "")).strip()

        update_query = """
            UPDATE derived.dim_facility
            SET
                facility_name = %s,
                district = %s,
                region = %s,
                facility_type = %s
            WHERE hfr_code = %s
        """

        with conn.cursor() as cursor:
            cursor.execute(update_query, (
                facility_name,
                district,
                region,
                facility_type,
                hfr_code
            ))

        conn.commit()
        environment.log_message(f"Facility updated for HFR Code: {hfr_code}")

    except Exception as e:
        environment.log_message(f"Failed to update dim_facility from CSV: {e}")


def run_sp_data_processing(db_params, environment):
    conn = None
    try:
        conn = pytds.connect(
            server=db_params["server"],
            user=db_params["username"],
            password=db_params["password"],
            database=db_params["database"],
            port=int(db_params.get("port", 1433)),
            autocommit=False
        )
        with conn.cursor() as cursor:
            environment.log_message("Started...")

            # Step 1: Run Stored Procedure
            statement = "EXEC import.sp_data_processing"
            write_to_database(environment, cursor, statement)

            conn.commit()
            environment.log_message("Stored procedure completed.")

        # Step 2: Update facility record from CSV
        read_facility_details(conn, environment)

    except Exception as e:
        environment.log_message(f"Stored procedure execution failed: {e}")
    finally:
        if conn:
            conn.close()


# Async wrapper
async def run_sp_data_processing_async(db_params, environment):
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(executor, run_sp_data_processing, db_params, environment)


# Main function
async def refresh_ctc_analytical_data():
    environment: DataTaskEnvironment = initialise_data_task("Data Refresh Task", params={})
    db_params = get_resolved_parameters_for_connection("ANA")

    await run_sp_data_processing_async(db_params, environment)

    environment.log_message("Completed.")


# Run the task
asyncio.run(refresh_ctc_analytical_data())
