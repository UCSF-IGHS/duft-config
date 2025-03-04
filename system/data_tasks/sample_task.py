import time
import sys
import os


from services.dte_tools.data_task_tools import assert_dte_tools_available, get_resolved_parameters_for_connection, initialise_data_task, get_temp_dir, get_data_dir, DataTaskEnvironment, find_json_arg  # noqa: E402

params = {}
environment: DataTaskEnvironment = None

if __name__ == "__main__":
    
    json_args = find_json_arg(sys.argv)
    environment = initialise_data_task("Sample Data Task", params=json_args)
    
    params["name"] = json_args.get("name", "No parameters given!")
    params["sleep_time"] = json_args.get("sleep_time", 0.2)
    params["simulate_error"] = json_args.get("simulate_error", False)
    
    if not json_args:
        environment.log_error("No parameters given!")
        

def sample_task():
    resolved_parameters = get_resolved_parameters_for_connection("ANA")
    environment.log_message('Script starting!')
    environment.log_message("Using Data Connection Parameters: %s" % resolved_parameters)
    

    
    for i in range(10):
        # Simulate a long-running task
        time.sleep(params["sleep_time"])
        # Send intermediate update to the client
        
        environment.log_message(f'Progress for %s: {i+1}/10' % params["name"])
        
        if (params["simulate_error"]) and i == 5:
            environment.log_error('A simulated error occurred!')
            environment.log_message('Could not complete SAMPLE as it raised an error. You may want to try again.')
            try:
                sys.stdout.flush()
                sys.exit(1)  # Exiting with error code
            except SystemExit as e:
                print(f"SystemExit with code: {e.code}")
                os._exit(1)
        
    environment.log_message('Script completed! %s' % environment.current_data_task_name)
        



assert_dte_tools_available()
sample_task()