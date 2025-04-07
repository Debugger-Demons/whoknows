#!/bin/bash
# Path: deployment/scripts/deploy.sh
# Description: Deploys the application using Docker Compose, performs health checks,
#              handles rollbacks, and cleans up old Docker images.

# --- Script Setup and Safety --- ##
# ------------------------------- ##
# Exit immediately if a command exits with non-zero status
# Exit on references to unset variables
# Ensure pipelines fail if any command fails (important for CI)
set -e -u -o pipefail

# === Configuration === ##
# --------------------- ##
HEALTH_CHECK_MAX_RETRIES=30       # How many times to check health
HEALTH_CHECK_RETRY_INTERVAL=3     # Seconds to wait between health checks
ROLLBACK_STABILITY_WAIT=5         # Seconds to wait after rollback before checking health

# === Function Definitions === ##
# ---------------------------- ##

# --- Function: log_message --- ##
# Utility for consistent timestamped logging
log_message() {
  echo "[$(date)] $1"
}

# --- Function: load_env_vars --- ##
# Loads required environment variables from the .env file.
load_env_vars() {
  log_message "Loading environment variables from .env file..."
  if [ ! -f .env ]; then
      log_message "FATAL: .env file not found!"
      exit 1
  fi
  # Use set -a/+a to export variables temporarily, primarily for visibility
  # Using --env-file in docker compose commands is the preferred way.
  set -a
  # shellcheck disable=SC1091 # Source file is expected to exist via check above
  source .env
  set +a
  log_message "Environment variables loaded."
  # Verify essential variables loaded (optional but recommended)
  : "${COMPOSE_PROJECT_NAME:?FATAL: COMPOSE_PROJECT_NAME not set in .env}"
  : "${IMAGE_TAG_BACKEND:?FATAL: IMAGE_TAG_BACKEND not set in .env}"
  : "${IMAGE_TAG_FRONTEND:?FATAL: IMAGE_TAG_FRONTEND not set in .env}"
  : "${HOST_PORT_FRONTEND:?FATAL: HOST_PORT_FRONTEND not set in .env}"
}

# --- Function: prepare_rollback --- ##
# Identifies currently running images for this project and saves them to .env.rollback.
prepare_rollback() {
  log_message "Preparing for potential rollback by identifying current running images..."
  local backend_container_name="${COMPOSE_PROJECT_NAME}_backend_dev"
  local frontend_container_name="${COMPOSE_PROJECT_NAME}_frontend_dev"
  local current_backend_image=""
  local current_frontend_image=""

  current_backend_image=$(docker inspect --format='{{.Config.Image}}' "${backend_container_name}" 2>/dev/null || echo "")
  current_frontend_image=$(docker inspect --format='{{.Config.Image}}' "${frontend_container_name}" 2>/dev/null || echo "")

  # Create or clear the rollback file
  rm -f .env.rollback

  if [[ -n "$current_backend_image" ]]; then
    echo "IMAGE_TAG_BACKEND=${current_backend_image}" > .env.rollback
    log_message "  - Saving current backend image for rollback: ${current_backend_image}"
  else
    log_message "  - No running backend container found for project ${COMPOSE_PROJECT_NAME}. Will not include in rollback."
  fi

  if [[ -n "$current_frontend_image" ]]; then
    echo "IMAGE_TAG_FRONTEND=${current_frontend_image}" >> .env.rollback
    log_message "  - Saving current frontend image for rollback: ${current_frontend_image}"
  else
     log_message "  - No running frontend container found for project ${COMPOSE_PROJECT_NAME}. Will not include in rollback."
  fi

  if [ ! -f .env.rollback ]; then
     log_message "  - Warning: No running containers found for this project. Rollback will not be possible."
  fi
}

# --- Function: pull_new_images --- ##
# Pulls the application images specified in the .env file.
pull_new_images() {
  log_message "Pulling new application images (Backend: ${IMAGE_TAG_BACKEND}, Frontend: ${IMAGE_TAG_FRONTEND})..."
  if ! docker compose --env-file .env pull; then
    log_message "FATAL: Failed to pull new Docker images."
    exit 1
  fi
  log_message "Image pulling completed."
}

# --- Function: deploy_new_containers --- ##
# Stops old containers and starts new ones using docker-compose up.
deploy_new_containers() {
  log_message "Stopping old containers (if any) and starting new containers..."
  # Options explained:
  #   --env-file .env     : Explicitly load variables from .env.
  #   up -d               : Create/start containers detached.
  #   --force-recreate    : Ensure containers restart even if only image changed.
  #   --remove-orphans    : Clean up containers for removed services.
  if ! docker compose --env-file .env up -d --force-recreate --remove-orphans; then
    log_message "FATAL: Failed to bring up new containers with docker-compose."
    exit 1
  fi
  log_message "docker-compose up completed successfully."
}

# --- Function: perform_health_check --- ##
# Checks the application's health endpoint multiple times.
# Returns 0 on success, 1 on failure.
perform_health_check() {
  local health_endpoint="http://localhost:${HOST_PORT_FRONTEND}/api/health"
  log_message "Waiting for application health check at ${health_endpoint}..."

  local i
  for i in $(seq 1 $HEALTH_CHECK_MAX_RETRIES); do
    local curl_exit_code=0
    # Use curl options: -s silent, -f fail fast, -L follow redirects, -o discard output
    if curl -s -f -L -o /dev/null "${health_endpoint}"; then
      log_message "Health check PASSED!"
      return 0 # Success
    else
      curl_exit_code=$?
      log_message "Health check attempt $i/$HEALTH_CHECK_MAX_RETRIES FAILED (curl exit code: ${curl_exit_code}). Retrying in ${HEALTH_CHECK_RETRY_INTERVAL}s..."
      sleep "$HEALTH_CHECK_RETRY_INTERVAL"
    fi
  done

  log_message "FATAL: Application health check failed after $HEALTH_CHECK_MAX_RETRIES attempts."
  return 1 # Failure
}

# --- Function: handle_rollback --- ##
# Attempts to roll back to the previously saved state if .env.rollback exists.
# Exits script with error code 1 if rollback is triggered.
handle_rollback() {
  log_message "Handling failed health check..."
  if [ ! -f .env.rollback ]; then
    log_message "FATAL: Health check failed, and no previous deployment state found in .env.rollback. Cannot roll back automatically."
    exit 1
  fi

  log_message "Initiating rollback to previously saved container images..."
  log_message "Rolling back using images defined in .env.rollback..."
  # Use compose to bring up the previous version, applying the rollback env file
  # Use set -a/+a here to make sure vars are available if compose file references them directly (though --env-file is better)
  set -a
  # shellcheck disable=SC1091 # File existence checked above
  source .env.rollback
  set +a
  if ! docker compose --env-file .env.rollback up -d --force-recreate --remove-orphans; then
      log_message "FATAL: Rollback command (docker-compose up) itself failed! Manual intervention likely required."
      exit 1
  fi

  # Optional: Brief health check for the rollback itself
  log_message "Waiting ${ROLLBACK_STABILITY_WAIT}s briefly for rollback stability check..."
  sleep "$ROLLBACK_STABILITY_WAIT"
  local health_endpoint="http://localhost:${HOST_PORT_FRONTEND}/api/health" # Re-evaluate endpoint based on potentially different rollback port? Assume same for now.
  if curl -s -f -L -o /dev/null "${health_endpoint}"; then
      log_message "Rollback appears successful. System is running previous version."
  else
      log_message "WARNING: Rollback command executed, but health check on rolled-back version failed. Manual inspection needed."
  fi

  # Exit with a non-zero code to signal deployment failure to the CI/CD system
  log_message "Exiting script with error code 1 due to failed deployment requiring rollback."
  exit 1
}

# --- Function: log_success_confirmation --- ##
# Logs the final running image versions after a successful deployment.
log_success_confirmation() {
    log_message "Deployment successful!"
    local backend_container_name="${COMPOSE_PROJECT_NAME}_backend_dev"
    local frontend_container_name="${COMPOSE_PROJECT_NAME}_frontend_dev"
    local final_backend_image=""
    local final_frontend_image=""

    final_backend_image=$(docker inspect --format='{{.Config.Image}}' "${backend_container_name}" 2>/dev/null || echo "Not running")
    final_frontend_image=$(docker inspect --format='{{.Config.Image}}' "${frontend_container_name}" 2>/dev/null || echo "Not running")

    log_message "Final running images:"
    log_message "  - Backend : ${final_backend_image}"
    log_message "  - Frontend: ${final_frontend_image}"
}

# --- Function: cleanup_docker_images --- ##
# Cleans up unused Docker images using the appropriate method based on Docker version.
cleanup_docker_images() {
  log_message "Cleaning up unused Docker images..."

  # --- Docker Version Check and Cleanup Strategy ---
  # Docker version 20.10.x (API 1.41) does NOT reliably support filtering prune by 'reference'.
  # Therefore, we MUST fall back to the general prune command.
  log_message "Note: Using 'docker image prune -af' as Docker version does not support 'reference' filter reliably."
  log_message "This will remove ALL unused images on the system, not just for this application."

  # Prune command options:
  # -a : Prune ALL unused images (not just dangling/untagged ones).
  # -f : Force prune without interactive confirmation.
  # IMPORTANT: This command is SAFE regarding running containers. It will NOT remove
  #            images used by ANY running container.
  if ! docker image prune -af; then
      # Log a warning, but don't fail the deployment just because prune failed
      log_message "Warning: 'docker image prune -af' command failed. Continuing deployment."
  else
      log_message "General image pruning completed."
  fi
}

# === Main Execution === ##
# ---------------------- ##

log_message "=== Starting Deployment Script ==="

# --- Step 1: Load Environment --- ##
load_env_vars

# --- Step 2: Prepare for Rollback --- ##
prepare_rollback

# --- Step 3: Pull New Code/Images --- ##
pull_new_images

# --- Step 4: Deploy New Version --- ##
deploy_new_containers

# --- Step 5: Verify Deployment Health --- ##
if ! perform_health_check; then
  # If health check fails, attempt rollback (handle_rollback exits on failure/completion)
  handle_rollback
fi

# --- Step 6: Confirm Success --- ##
# Only reached if health check passed
log_success_confirmation

# --- Step 7: Clean Up --- ##
cleanup_docker_images

# --- Step 8: Final Touches --- ##
log_message "Cleaning up temporary rollback file..."
rm -f .env.rollback

log_message "=== Deployment Script Completed Successfully ==="
# Exit with 0 to signal success to the CI/CD system
exit 0