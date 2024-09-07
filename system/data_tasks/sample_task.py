import time
import sys


from api_data_task_executioner.data_task_tools import assert_dte_tools_available, get_resolved_parameters_for_connection, initialise_data_task, find_json_arg, DataTaskEnvironment  # noqa: E402

params = {}
environment: DataTaskEnvironment = None

if __name__ == "__main__":
    
    json_args = find_json_arg(sys.argv)
    environment = initialise_data_task("Sample Data Task", params=json_args)
    
    params["name"] = json_args.get("name", "No parameters given!")
    params["sleep_time"] = json_args.get("sleep_time", 0.2)
    
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
    environment.log_message('Script completed! %s' % environment.current_data_task_name)
        



assert_dte_tools_available()
sample_task()