import sys

from services.dte_tools.data_task_tools import (  # noqa: E402
    DataTaskEnvironment,
    find_json_arg,
    initialise_data_task,
)
from services.dte_tools.update_tools import download_github_repo

# To try this out, run
# python update.py '{"repo_url": "https://github.com/UCSF-IGHS/duft-config", "save_path": "weiu34iurer/downloads", "final_repo_name": "duft-config-unittest", "branch": "namibia-3dl"}'


params = {}
environment: DataTaskEnvironment = None

if __name__ == "__main__":
    
    json_args = find_json_arg(sys.argv)
    environment = initialise_data_task("DUFT Config Updater", params=json_args)
    
    params["repo_url"] = json_args.get("repo_url")
    params["save_path"] = json_args.get("save_path")
    params["final_repo_name"] = json_args.get("final_repo_name")
    params["branch"] = json_args.get("branch")
    params["user_dir"] = "user"
    
    if not json_args:
        environment.log_error("No parameters given!")
        
def update_config(repo_url, save_path, final_repo_name, branch, user_dir):
    environment.log_message('Updating DUFT Reports Configuration')
    environment.log_message(f'Updating { final_repo_name } from { repo_url }')
    download_github_repo(repo_url, save_path, final_repo_name=final_repo_name, branch=branch, user_dir=user_dir)
    environment.log_message('Update complete. Please exit and restart DUFT.')



update_config(params["repo_url"], 
              params["save_path"], 
              params["final_repo_name"], 
              params["branch"],
              params["user_dir"])


# {
#   "repo_url": "https://github.com/UCSF-IGHS/duft-config",
#   "save_path": "/current/directory/weiu34iurer/downloads",
#   "final_repo_name": "duft-config-unittest",
#   "branch": "namibia-3dl"
# }

