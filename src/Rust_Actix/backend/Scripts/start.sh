#!/bin/bash
# start.sh - Main entrypoint for Docker container

set -e

echo "Starting Rust application in container..."

# Clone the repository if it doesn't exist
if [ ! -d "/whoknows/.git" ]; then
    echo "Cloning repository..."
    # If /whoknows is not empty but has no .git, we need to handle this carefully
    if [ "$(ls -A /whoknows)" ]; then
        # Move existing files to a temp directory
        mkdir -p /tmp/whoknows-backup
        mv /whoknows/* /whoknows/.* /tmp/whoknows-backup/ 2>/dev/null || true
    fi
    
    # Clone the repository
    git clone https://github.com/Debugger-Demons/whoknows.git /whoknows-temp
    mv /whoknows-temp/.git /whoknows/
    mv /whoknows-temp/* /whoknows/ 2>/dev/null || true
    rm -rf /whoknows-temp
    
    # Set the git config to not require authentication for pulls
    git config --global pull.rebase false
    git config --global user.email "container@example.com"
    git config --global user.name "Container Environment"
fi

# Navigate to the application directory
cd /whoknows/src/Rust_Actix/backend

# Build the application
echo "Building application..."
cargo build --release

# Start the auto-update service in background
echo "Starting auto-update service..."
/whoknows/src/Rust_Actix/backend/Scripts/auto_update.sh &

# Function to handle signals
handle_signal() {
    echo "Received signal to restart application"
    kill -TERM $APP_PID
    wait $APP_PID
    exec cargo run --release
}

# Set up signal handler
trap handle_signal HUP

# Run the application
echo "Starting Rust application..."
RUST_BACKTRACE=1 cargo run --release &
APP_PID=$!

# Wait for the application to exit
wait $APP_PID
