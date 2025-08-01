import asyncio
import pytds
import threading
from concurrent.futures import ThreadPoolExecutor

from services.dte_tools.data_task_tools import (
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)

executor = ThreadPoolExecutor(max_workers=2)


def run_stored_procedure_only(db_params, environment, sp_done_event):
    try:
        with pytds.connect(
            server=db_params["server"],
            user=db_params["username"],
            password=db_params["password"],
            database=db_params["database"],
            port=int(db_params.get("port", 1433)),
            autocommit=True
        ) as conn:
            with conn.cursor() as cursor:
                environment.log_message("Starting SP...")
                cursor.execute("EXEC dbo.sp_data_processing") 

                # Wait until polling sets the event
                environment.log_message("Waiting for polling to complete...")
                sp_done_event.wait()
                conn.commit()

            
    except Exception as e:
        environment.log_message(f"SP failed: {e}")


async def poll_etl_tracking(db_params, environment, sp_done_event):
    try:
        await asyncio.sleep(10)
        with pytds.connect(
            server=db_params["server"],
            user=db_params["username"],
            password=db_params["password"],
            database=db_params["database"],
            port=int(db_params.get("port", 1433)),
            autocommit=True
        ) as conn:
            while True:
                with conn.cursor() as cursor:
                    cursor.execute("""
                        SELECT TOP 1 sp_name, status, start_time 
                        FROM dbo.etl_tracking 
                        WHERE status != 'COMPLETED' 
                        ORDER BY start_time DESC
                    """)
                    rows = cursor.fetchall()

                    if not rows:
                        environment.log_message("All processes completed.")
                        sp_done_event.set() 
                        break


                await asyncio.sleep(5)
    except Exception as e:
        environment.log_message(f"Polling failed: {e}")


async def refresh_ctc_analytical_data():
    environment: DataTaskEnvironment = initialise_data_task("Data Refresh Task", params={})
    db_params = get_resolved_parameters_for_connection("ANA")

    # Use per-run event instead of global
    sp_done_event = threading.Event()

    loop = asyncio.get_event_loop()
    sp_future = loop.run_in_executor(
        executor, 
        run_stored_procedure_only, 
        db_params, environment, sp_done_event
    )
    
    polling_task = asyncio.create_task(
        poll_etl_tracking(db_params, environment, sp_done_event)
    )

    await asyncio.gather(sp_future, polling_task)
    environment.log_message("Task completed.")



# Run the task
asyncio.run(refresh_ctc_analytical_data())
