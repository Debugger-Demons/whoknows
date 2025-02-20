#!/bin/bash
# auto_update.sh - modified for container environment

# Exit on errors
set -e

# Log function
log() {
    echo "[$(date)] $1"
}

# Initial sleep to let the Rust app start
sleep 10

log "Starting update check"

# Skip git operations in container for now
# We'll implement proper git handling later

# Simple health check
if curl -s http://localhost:8080 > /dev/null; then
    log "Service is healthy"
else
    log "Service is not responding"
fi

# Sleep to prevent rapid restarts
sleep 300  # 5 minutes
