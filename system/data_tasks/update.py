import os
import sys
import traceback
from services.dte_tools.update_tools import download_github_repo
from services.dte_tools.data_task_tools import initialise_data_task, find_json_arg, DataTaskEnvironment

if __name__ == "__main__":
    json_args = find_json_arg(sys.argv)
    environment = initialise_data_task("DUFT Config Updater", params=json_args)

    if not json_args:
        environment.log_error("No parameters given!")
        sys.exit(1)

    # Extract parameters with defaults
    params = {
        "repo_url": json_args.get("repo_url"),
        "save_path": os.path.join(os.path.expanduser("~"), "duft_resources", json_args.get("save_path")),
        "final_repo_name": json_args.get("final_repo_name"),
        "branch": json_args.get("branch", "main"),
        "user_dir": json_args.get("user_dir", "user"),
    }

    # Validate required params
    required = ["repo_url", "save_path", "final_repo_name"]
    missing = [p for p in required if not params[p]]
    if missing:
        environment.log_error(f"Missing parameters: {missing}")
        sys.exit(1)

    try:
        environment.log_message(f"Updating {params['final_repo_name']} from {params['repo_url']}")

        download_github_repo(
            params["repo_url"],
            params["save_path"],
            final_repo_name=params["final_repo_name"],
            branch=params["branch"],
            user_dir=params["user_dir"],
            environment=environment  # Pass for logging
        )

        environment.log_message("Update complete. Please exit and restart DUFT.")

    except Exception as e:
        environment.log_error(f"Update failed: {e}")
        environment.log_error(traceback.format_exc())

        # Save detailed error log
        log_file = os.path.join(params["save_path"], f"update_error_{os.path.basename(params['final_repo_name'])}_{int(sys.time())}.log")
        try:
            with open(log_file, "w") as f:
                f.write(f"Error: {e}\n\n")
                f.write(traceback.format_exc())
            environment.log_error(f"Details saved to: {log_file}")
        except:
            pass

        sys.exit(1)