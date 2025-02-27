#!/bin/bash
set -e
echo "Starting the application"
echo "Current directory: $(pwd)"
echo "Checking /app directory:"
ls -l /app
echo "Attempting to create logs directory:"
mkdir -p /app/logs
chmod 755 /app/logs
ls -l /app/logs
echo "Running backend and logging:"
/app/backend > /app/logs/backend.log 2>&1
