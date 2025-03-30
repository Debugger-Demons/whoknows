#!/bin/bash
# Path: deployment/scripts/deploy.sh

set -e  # Exit immediately if a command exits with non-zero status
source .env  # Load environment variables from .env file

# Log deployment start with timestamp
echo "[$(date)] Deployment started"

# Store previous image tags for potential rollback
if [ -f .env.previous ]; then
  cp .env.previous .env.rollback
fi

# Save current environment variables for potential rollbacks

set | grep "^IMAGE_TAG_" > .env.previous || true

# ---------------- pull images ---------------- ##

# Pull the specific tagged images defined by the env vars
echo "[$(date)] Pulling images: $IMAGE_TAG_BACKEND and $IMAGE_TAG_FRONTEND"
docker compose pull || { echo "Failed to pull images"; exit 1; }

# Stop (if running), remove old containers, and start new ones
echo "[$(date)] Starting containers"
docker compose -f docker-compose.yml --env-file .env up -d --remove-orphans

# ------------- health check ------------- ##

# Wait for backend to become healthy
echo "[$(date)] Waiting for backend health check..."
MAX_RETRIES=30
RETRY_INTERVAL=2
HEALTH_ENDPOINT="http://localhost:${HOST_PORT_FRONTEND}/api/health" 

cleanupRollback() {
  # Rename rollback file
  mv .env.rollback .env.previous 2>/dev/null || echo "No rollback file to rename"
  mv .env .env.failed 2>/dev/null || echo "No current env file to rename"
  
  # Remove files, don't error if they don't exist
  rm -f .env.previous 2>/dev/null
  rm -f .env 2>/dev/null
  
  echo "[$(date)] Cleanup completed"
}

for i in $(seq 1 $MAX_RETRIES); do
  if curl -s -f "${HEALTH_ENDPOINT}" > /dev/null; then
    echo "[$(date)] Backend is healthy!"
    break
  fi
  
  if [ $i -eq $MAX_RETRIES ]; then
    echo "[$(date)] Health check failed after $MAX_RETRIES attempts. Rolling back."
    # Rollback to previous deployment if health check fails
    if [ -f .env.rollback ]; then
      echo "[$(date)] Rolling back to previous deployment"
      set -a  
      source .env.rollback
      set +a
      docker compose --env-file .env.rollback up -d --remove-orphans || { echo "Rollback failed"; exit 1; }
      
      # Wait for the rollback to become healthy
      echo "[$(date)] Waiting for rollback health check..."

      for j in $(seq 1 $MAX_RETRIES); do
        if curl -s -f "${HEALTH_ENDPOINT}" > /dev/null; then
          echo "[$(date)] Rollback successful!"
          cleanupRollback
          break
        fi
        
        if [ $j -eq $MAX_RETRIES ]; then
          echo "[$(date)] Rollback health check failed after $MAX_RETRIES attempts. Exiting."
          exit 1
        fi
        
        echo "[$(date)] Rollback attempt $j/$MAX_RETRIES: Backend not ready yet. Retrying in ${RETRY_INTERVAL}s..."
        sleep $RETRY_INTERVAL
      done
      echo "[$(date)] Rollback complete"
    else
      echo "[$(date)] No previous deployment found for rollback"
    fi
    exit 1
  fi
  
  echo "Attempt $i/$MAX_RETRIES: Backend not ready yet. Retrying in ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

# --------------- logging --------------- ##

# Log version information for auditing
echo "[$(date)] Deployment successful with:"
echo "Backend: $IMAGE_TAG_BACKEND"
echo "Frontend: $IMAGE_TAG_FRONTEND"

## ----------- clean up ---------- ##

echo "[$(date)] Cleaning up previous application images"

# Remove older images of this application while keeping the currently used ones
docker images --format "{{.Repository}}:{{.Tag}}" | grep "${IMAGE_TAG_BACKEND%:*}" | grep -v "${IMAGE_TAG_BACKEND##*:}" | xargs -r docker rmi
docker images --format "{{.Repository}}:{{.Tag}}" | grep "${IMAGE_TAG_FRONTEND%:*}" | grep -v "${IMAGE_TAG_FRONTEND##*:}" | xargs -r docker rmi

# ------------ success message ------------- ##
echo "[$(date)] Deployment completed successfully"