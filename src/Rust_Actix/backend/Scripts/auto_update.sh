#!/bin/bash
# auto_update.sh - Git-based automatic updates with detailed logging

set -e

# Project directory
APP_DIR="/whoknows"
GIT_REPO="https://github.com/Debugger-Demons/whoknows.git"
GIT_BRANCH="test2/updating_mechanism"
LOG_FILE="/var/log/supervisor/git-updates.log"

# Create a unique run ID for this update check
RUN_ID=$(date +"%Y%m%d-%H%M%S")-$$

# Log function
log() {
    echo "[${RUN_ID}] $(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

# Acquire lock to prevent multiple instances running
LOCK_FILE="/tmp/auto_update.lock"
if [ -e ${LOCK_FILE} ] && kill -0 $(cat ${LOCK_FILE}) 2>/dev/null; then
    log "Another update process is running, exiting"
    exit 0
fi
echo $$ > ${LOCK_FILE}

# Make sure to remove lock file on exit
trap "rm -f ${LOCK_FILE}" EXIT

log "=== Starting update check ==="

# Navigate to project directory
cd $APP_DIR

# Fetch the latest changes
log "Fetching from $GIT_REPO branch $GIT_BRANCH"
git fetch origin $GIT_BRANCH

# Get the hash of the current commit
LOCAL_HASH=$(git rev-parse HEAD)
LOCAL_MSG=$(git log -1 --pretty=%B)
log "Current commit: ${LOCAL_HASH:0:8} - ${LOCAL_MSG:0:50}"

# Get the hash of the remote commit
REMOTE_HASH=$(git rev-parse origin/$GIT_BRANCH)
REMOTE_MSG=$(git log -1 origin/$GIT_BRANCH --pretty=%B)
log "Remote commit: ${REMOTE_HASH:0:8} - ${REMOTE_MSG:0:50}"

# Compare the hashes
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    log "Updates available. Pulling changes..."
    git pull origin $GIT_BRANCH
    
    # Get list of changed files
    CHANGED_FILES=$(git diff --name-only ${LOCAL_HASH} ${REMOTE_HASH})
    log "Changed files: $(echo $CHANGED_FILES | tr '\n' ' ')"
    
    # Navigate to the application directory
    cd $APP_DIR/src/Rust_Actix/backend
    
    # Rebuild the application
    log "Rebuilding application..."
    cargo build --release
    BUILD_RESULT=$?
    
    if [ $BUILD_RESULT -eq 0 ]; then
        # Signal supervisor to restart the application
        log "Build successful. Requesting application restart..."
        supervisorctl restart rust-app
        log "Update complete - app restarted with new version ${REMOTE_HASH:0:8}"
    else
        log "ERROR: Build failed with status $BUILD_RESULT"
    fi
else
    log "No updates available"
fi

log "=== Update check complete ==="
