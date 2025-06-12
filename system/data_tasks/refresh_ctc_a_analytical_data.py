import asyncio
import pytds
from concurrent.futures import ThreadPoolExecutor

from services.dte_tools.data_task_tools import (
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)

# Optional: use a global thread pool executor
executor = ThreadPoolExecutor(max_workers=2)


# Blocking function to run the stored procedure
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
            cursor.execute("EXEC dbo.sp_data_processing")

            while True:
                try:
                    if cursor.description:
                        cursor.fetchall()
                except Exception as e:
                    environment.log_message(f"Ignored result set error: {e}")
                if not cursor.nextset():
                    break

        conn.commit()
    except Exception as e:
        environment.log_message(f"Stored procedure execution failed: {e}")
    finally:
        if conn:
            conn.close()


# Async wrapper to run the blocking function in a thread
async def run_sp_data_processing_async(db_params, environment):
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(executor, run_sp_data_processing, db_params, environment)


async def refresh_ctc_analytical_data():
    environment: DataTaskEnvironment = initialise_data_task("Data Refresh Task", params={})
    db_params = get_resolved_parameters_for_connection("ANA")

    await run_sp_data_processing_async(db_params, environment)

    environment.log_message("Completed.")


# Start main async function to run the task
asyncio.run(refresh_ctc_analytical_data())