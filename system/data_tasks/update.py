import os
import sys
import importlib.util
import traceback

# === Globals ===
params = {}
environment = None

# === Helper function for dynamic import ===
def import_module_from_path(name, path):
    """Import a module dynamically from a file path"""
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

# === Locate update_tools module ===
workspace_root = os.path.dirname(os.path.abspath(__file__))
update_tools_path = os.path.join(
    workspace_root,
    "duft-server",
    "services",
    "dte_tools",
    "update_tools.py"
)
data_task_tools_path = os.path.join(
    workspace_root,
    "duft-server",
    "services",
    "dte_tools",
    "data_task_tools.py"
)

# Dynamically import modules
update_tools = import_module_from_path("update_tools", update_tools_path)
data_task_tools = import_module_from_path("data_task_tools", data_task_tools_path)

# Access needed functions/classes
download_github_repo = update_tools.download_github_repo
assert_dte_tools_available = data_task_tools.assert_dte_tools_available
get_resolved_parameters_for_connection = data_task_tools.get_resolved_parameters_for_connection
initialise_data_task = data_task_tools.initialise_data_task
find_json_arg = data_task_tools.find_json_arg
DataTaskEnvironment = data_task_tools.DataTaskEnvironment

# === Helper function for updating config ===
def update_config(repo_url, save_path, final_repo_name, branch, user_dir):
    environment.log_message("Updating DUFT Reports Configuration")
    environment.log_message(f"Updating {final_repo_name} from {repo_url}")
    print(f"[DEBUG] Calling download_github_repo with:\n  repo_url={repo_url}\n  save_path={save_path}\n  final_repo_name={final_repo_name}\n  branch={branch}\n  user_dir={user_dir}")

    download_github_repo(
        repo_url,
        save_path,
        final_repo_name=final_repo_name,
        branch=branch,
        user_dir=user_dir
    )
    environment.log_message("Update complete. Please exit and restart DUFT.")
    print("[DEBUG] Update complete")

# === Main entry point ===
if __name__ == "__main__":
    try:
        # Grab JSON args from command line
        json_args = find_json_arg(sys.argv)
        print(f"[DEBUG] JSON args found: {json_args}")

        # Initialize environment for logging
        environment = initialise_data_task("DUFT Config Updater", params=json_args)
        print("[DEBUG] Environment initialized:", environment)

        if not json_args:
            environment.log_error("No parameters given!")
            sys.exit(1)

        # Fill parameters
        params["repo_url"] = json_args.get("repo_url")
        params["save_path"] = os.path.join(os.path.expanduser("~"), "duft_resources", json_args.get("save_path"))
        params["final_repo_name"] = json_args.get("final_repo_name")
        params["branch"] = json_args.get("branch")
        params["user_dir"] = "user"

        print(f"[DEBUG] Params prepared: {params}")

        # Run update
        update_config(
            params["repo_url"],
            params["save_path"],
            params["final_repo_name"],
            params["branch"],
            params["user_dir"]
        )

    except Exception as e:
        print("[ERROR] Exception during update:", str(e))
        traceback.print_exc()
        if environment:
            environment.log_error(f"Update failed: {e}")
        sys.exit(1)
