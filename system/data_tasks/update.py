import os
import sys
import traceback

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

    # Validate required params
    required = ["repo_url", "save_path", "final_repo_name"]
    missing = [p for p in required if not params[p]]
    if missing:
        environment.log_error(f"Missing parameters: {missing}")


def update_config(repo_url, save_path, final_repo_name, branch, user_dir):
    try:
        environment.log_message('Updating Reports Configuration')
        download_github_repo(repo_url, save_path, final_repo_name=final_repo_name, branch=branch, user_dir=user_dir)
        environment.log_message('Update complete. Click "Close" to refresh the app.')
    except Exception as e:
        environment.log_error(f"Update failed: {e}")
        environment.log_error(traceback.format_exc())

        # Save detailed error log
        log_file = os.path.join(params["save_path"],
                                f"update_error_{os.path.basename(params['final_repo_name'])}_{int(sys.time())}.log")
        try:
            with open(log_file, "w") as f:
                f.write(f"Error: {e}\n\n")
                f.write(traceback.format_exc())
        except:
            pass


update_config(params["repo_url"],
              params["save_path"],
              params["final_repo_name"],
              params["branch"],
              params["user_dir"])
