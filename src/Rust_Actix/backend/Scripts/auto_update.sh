#!/bin/bash
# auto_update_improved.sh - Efficiently pull updates and trigger rebuild if needed

# Project directory
APP_DIR="/whoknows"
GIT_REPO="https://github.com/Debugger-Demons/whoknows.git"
GIT_BRANCH="development"

# Log function
log() {
    echo "[$(date)] $1" | tee -a /var/log/supervisor/auto-update.log
}

log "Auto-update check started"

# Navigate to project directory
cd $APP_DIR

# Fetch the latest changes
git fetch origin $GIT_BRANCH

# Get the hash of the current commit
LOCAL_HASH=$(git rev-parse HEAD)
# Get the hash of the remote commit
REMOTE_HASH=$(git rev-parse origin/$GIT_BRANCH)

# Compare the hashes
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    log "Updates available. Pulling changes..."
    git pull origin $GIT_BRANCH
    
    # Navigate to the application directory
    cd $APP_DIR/src/Rust_Actix/backend
    
    # Rebuild the application
    log "Rebuilding application..."
    cargo build --release
    
    # Signal supervisor to restart the application
    log "Requesting application restart..."
    supervisorctl restart rust-app
    
    log "Update complete"
    exit 0  # Success
else
    log "No updates available"
    exit 0  # Success with no changes
fi
