import os
import sys
import time

# Find the duft-server directory
# This file is designed to be run outside the duft-config directory

current_dir = os.path.dirname(os.path.abspath(__file__))
duft_server_dir = None

while current_dir != "/":
    if "duft-server" in os.listdir(current_dir):
        duft_server_dir = os.path.join(current_dir, "duft-server")
        break
    current_dir = os.path.dirname(current_dir)

if duft_server_dir is None:
    print("duft-server directory not found!")
    sys.exit(1)

os.chdir(duft_server_dir)
print(os.getcwd())
sys.path.insert(0, os.getcwd())

from services.dte_tools.data_task_tools import (  # noqa: E402
    DataTaskEnvironment,
    assert_dte_tools_available,
    find_json_arg,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)

params = {}
environment: DataTaskEnvironment = None

if __name__ == "__main__":
    
    json_args = find_json_arg(sys.argv)
    environment = initialise_data_task("Sample Data Task Executing from the Root", params=json_args)
    
    params["name"] = json_args.get("name", "No parameters given!")
    params["repo"] = json_args.get("repo", "No repo given!")
    params["sleep_time"] = json_args.get("sleep_time", 0.2)
    
    if not json_args:
        environment.log_error("No parameters given!")
        

def sample_task():
    resolved_parameters = get_resolved_parameters_for_connection("ANA")
    environment.log_message('Script starting!')
    environment.log_message("Using Data Connection Parameters: %s" % resolved_parameters)
    environment.log_message("Repo: %s" % params["repo"])
    
    for i in range(10):
        # Simulate a long-running task
        time.sleep(params["sleep_time"])
        # Send intermediate update to the client
        
        environment.log_message(f'Progress for %s: {i+1}/10' % params["name"])
    environment.log_message('Script completed! %s' % environment.current_data_task_name)
        

assert_dte_tools_available()
sample_task()
