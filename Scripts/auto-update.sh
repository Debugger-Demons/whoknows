#!/bin/bash
# whoknows/Scripts/auto-update.sh
set -e

REPO_URL="https://github.com/Debugger-Demons/whoknows.git"
REPO_DIR="/whoknows"
APP_DIR="${REPO_DIR}/src/Rust_Actix/backend"
SCRIPT_PATH="${REPO_DIR}/Scripts/start.sh"

# Function to update and restart
update_and_restart() {
  echo "$(date): Pulling latest changes..."
  
  # If repo doesn't exist, clone it first
  if [ ! -d "${REPO_DIR}/.git" ]; then
    echo "Repository not found, cloning..."
    git clone "${REPO_URL}" "${REPO_DIR}"
  else
    # Pull latest changes
    cd "${REPO_DIR}"
    git pull
  fi
  
  # Run start script if it exists
  if [ -f "${SCRIPT_PATH}" ]; then
    echo "Running start script..."
    chmod +x "${SCRIPT_PATH}"
    "${SCRIPT_PATH}"
  else
    echo "ERROR: Start script not found at ${SCRIPT_PATH}"
    exit 1
  fi
}

# Initial update
update_and_restart

# Setup periodic updates with cron
echo "*/15 * * * * root /auto-update.sh >> /var/log/auto-update.log 2>&1" > /etc/cron.d/auto-update-app
chmod 0644 /etc/cron.d/auto-update-app
