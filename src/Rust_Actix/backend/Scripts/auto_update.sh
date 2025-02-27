#!/bin/bash
# auto_update.sh - Pull updates from git repo and restart if needed

# Project directory
APP_DIR="/whoknows"
GIT_REPO="https://github.com/Debugger-Demons/whoknows.git"
GIT_BRANCH="main"

# Log function
log() {
    echo "[$(date)] $1"
}

log "Auto-update service started"

while true; do
    # Navigate to project directory
    cd $APP_DIR
    
    # Fetch the latest changes
    log "Checking for updates from $GIT_REPO branch $GIT_BRANCH"
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
        
        # Signal the main process to restart
        # Using the HUP signal which is often used for configuration reloads
        log "Restarting application..."
        pkill -HUP -f "cargo run --release"
        
        log "Update complete"
    else
        log "No updates available"
    fi
    
    # Health check
    if curl -s http://localhost:8080 > /dev/null; then
        log "Service is healthy"
    else
        log "Service is not responding, attempting to restart..."
        cd $APP_DIR/src/Rust_Actix/backend
        pkill -9 -f "cargo run --release"
    fi
    
    # Sleep before next check
    log "Sleeping for 15 minutes before next check"
    sleep 900  # 15 minutes
done
