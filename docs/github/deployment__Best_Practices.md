Best Practice Considerations:

Atomicity: Deployment steps should ideally be atomic or have clean rollback.

Simplicity: Less complex scripts are easier to maintain.

Safety: Never try to remove an image that a container relies on.

Leverage Docker Tools: Use built-in Docker commands like prune where appropriate.

Source of Truth: GHCR is your image source of truth; the server only needs the currently required images and potentially the immediate previous one for rollback.

Key Changes and Structure:

Functions: All major logical blocks are now encapsulated in functions (e.g., load_env_vars, prepare_rollback, pull_new_images, deploy_new_containers, perform_health_check, handle_rollback, log_success_confirmation, cleanup_docker_images).

Main Execution Flow: The bottom section (=== Main Execution ===) clearly shows the sequence of steps by calling these functions.

Error Handling: Functions that perform critical steps (pull_new_images, deploy_new_containers) check the exit status of their core command and call exit 1 if it fails. The perform_health_check function returns 0 or 1, and the main flow checks this using if ! perform_health_check; then handle_rollback; fi. The handle_rollback function itself calls exit 1.

Readability: The main execution flow is now much shorter and reads like a high-level description of the deployment process. Details are hidden within the functions.

Cleanup Fix: The cleanup_docker_images function explicitly uses docker image prune -af and includes comments explaining why the targeted reference filter cannot be used with your Docker version. It also includes basic error checking for the prune command itself, logging a warning instead of failing the whole script if prune fails for some reason.

Logging: A simple log_message function is added for consistent timestamped output.

Configuration: Constants like retry counts are grouped at the top.

Variable Verification: Added checks in load_env_vars to ensure critical variables are actually set in the .env file, causing an early exit if they are missing.
