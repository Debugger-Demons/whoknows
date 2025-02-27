# Deployment Instructions for Efficient Auto-Updates

## Overview of Solution

This solution uses cron instead of supervisor for scheduling auto-updates. This is more efficient because:

1. Cron is purpose-built for scheduling tasks at intervals
2. It prevents the repeated spawn/exit cycles in the logs
3. It provides cleaner, more focused logging

## Quick Deployment Steps

1. **Update your Dockerfile**:
   - Replace with the new version that includes cron setup
   - This adds cron and configures the scheduler

2. **Update supervisord.conf**:
   - Remove the auto-update program entry
   - Add cron program entry instead

3. **Improve the auto_update.sh script**:
   - Replace with the enhanced version
   - Make sure it's executable: `chmod +x auto_update.sh`

4. **Rebuild and restart your container**:
   ```bash
   docker-compose down
   docker-compose build
   docker-compose up -d
   ```

## Monitoring the Updates

With the new setup, update attempts will be logged to:
- `/var/log/supervisor/git-updates.log` (detailed git operations)
- `/var/log/supervisor/cron-auto-update.log` (cron execution)

You can view these logs with:
```bash
docker exec rust-app cat /var/log/supervisor/git-updates.log
```

## How It Works

1. **Scheduling**: 
   - Cron runs the update script every 5 minutes
   - This interval can be adjusted in the Dockerfile

2. **Execution**:
   - The script uses file locking to prevent concurrent runs
   - Each run has a unique ID for tracking in logs
   - Detailed git information is recorded

3. **Update Process**:
   - Fetches latest changes from repository
   - Compares local and remote commit hashes
   - Pulls and rebuilds if changes detected
   - Restarts the application via supervisorctl

4. **Logging**:
   - Run ID and timestamps for each operation
   - Commit hashes and messages recorded
   - List of changed files captured
   - Build and restart status logged
