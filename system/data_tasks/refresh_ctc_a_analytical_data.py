import asyncio
import threading
from concurrent.futures import ThreadPoolExecutor

import pytds

from services.dte_tools.data_task_tools import (
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)

executor = ThreadPoolExecutor(max_workers=2)

INITIAL_POLL_DELAY_SECONDS = 10
POLL_INTERVAL_SECONDS = 5
PROGRESS_LOG_INTERVAL_SECONDS = 30

STATE_RUNNING = "RUNNING"
STATE_SUCCESS = "SUCCESS"
STATE_FAILURE = "FAILURE"


def set_terminal_state(result, state, message=None):
    with result["lock"]:
        if result["state"] != STATE_RUNNING:
            return False

        result["state"] = state
        result["message"] = message
        result["done_event"].set()
        return True


def get_database_time(db_params):
    with pytds.connect(
        server=db_params["server"],
        user=db_params["username"],
        password=db_params["password"],
        database=db_params["database"],
        port=int(db_params.get("port", 1433)),
        autocommit=True,
    ) as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT GETDATE()")
            return cursor.fetchone()[0]


def run_stored_procedure_only(db_params, environment, result):
    try:
        environment.log_message("Starting data refresh...")

        with pytds.connect(
            server=db_params["server"],
            user=db_params["username"],
            password=db_params["password"],
            database=db_params["database"],
            port=int(db_params.get("port", 1433)),
            autocommit=True,
        ) as conn:
            with conn.cursor() as cursor:
                cursor.execute("SET NOCOUNT ON; EXEC dbo.sp_data_processing")

        environment.log_message("Data refresh is finalizing...")

        result["done_event"].wait()

        with result["lock"]:
            final_message = result["message"]

        if final_message:
            environment.log_message(final_message)

    except Exception:
        if set_terminal_state(
            result,
            STATE_FAILURE,
            "The data refresh could not be completed.",
        ):
            environment.log_message(result["message"])


async def poll_etl_tracking(db_params, environment, result):
    try:
        await asyncio.sleep(INITIAL_POLL_DELAY_SECONDS)

        elapsed_since_progress_log = 0

        with pytds.connect(
            server=db_params["server"],
            user=db_params["username"],
            password=db_params["password"],
            database=db_params["database"],
            port=int(db_params.get("port", 1433)),
            autocommit=True,
        ) as conn:
            while not result["done_event"].is_set():
                with conn.cursor() as cursor:
                    cursor.execute(
                        """
                        SELECT COUNT(*)
                        FROM dbo.etl_tracking
                        WHERE start_time >= %s
                          AND status != 'COMPLETED'
                        """,
                        (result["run_anchor_time"],),
                    )
                    pending_count = cursor.fetchone()[0]

                    if pending_count == 0:
                        set_terminal_state(
                            result,
                            STATE_SUCCESS,
                            "Data refresh completed successfully.",
                        )
                        break

                await asyncio.sleep(POLL_INTERVAL_SECONDS)
                elapsed_since_progress_log += POLL_INTERVAL_SECONDS

                if (
                    not result["done_event"].is_set()
                    and elapsed_since_progress_log >= PROGRESS_LOG_INTERVAL_SECONDS
                ):
                    environment.log_message("Data refresh is still in progress...")
                    elapsed_since_progress_log = 0

    except Exception:
        set_terminal_state(
            result,
            STATE_FAILURE,
            "Unable to confirm completion status.",
        )


async def refresh_ctc_analytical_data():
    environment: DataTaskEnvironment = initialise_data_task(
        "Data Refresh Task",
        params={},
    )
    db_params = get_resolved_parameters_for_connection("ANA")

    run_anchor_time = get_database_time(db_params)

    result = {
        "state": STATE_RUNNING,
        "message": None,
        "done_event": threading.Event(),
        "lock": threading.Lock(),
        "run_anchor_time": run_anchor_time,
    }

    loop = asyncio.get_running_loop()

    sp_future = loop.run_in_executor(
        executor,
        run_stored_procedure_only,
        db_params,
        environment,
        result,
    )

    polling_task = asyncio.create_task(
        poll_etl_tracking(db_params, environment, result)
    )

    await asyncio.gather(sp_future, polling_task)


asyncio.run(refresh_ctc_analytical_data())