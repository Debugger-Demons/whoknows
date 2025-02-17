#!/bin/bash
# auto_update.sh - located in /src/Rust_Actix/backend/Scripts/

set -e

# Navigate up to git root directory
cd ../../../

# Log function
log() {
    echo "[$(date)] $1"
}

echo "$(date) - deploying version $(git rev-parse HEAD)" >> /var/log/deploy.log

# Health check for: checking if the service is running

health_check() {
    for i in {1..5}; do
        if curl -s http://localhost:8080/health; then
            return 0
        fi
        sleep 2
    done
    return 1
}


# Fetch and check for updates
git fetch
UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")

if [ $LOCAL != $REMOTE ]; then
    log "Updates found, pulling changes..."
    git pull
    
    log "Restarting service..."
    sudo systemctl restart rust-app
    
    if systemctl is-active --quiet rust-app; then
        log "Service successfully restarted"
    else
        log "ERROR: Service failed to restart"
        systemctl status rust-app
        exit 1
    fi
else
    log "No updates found"
fi
