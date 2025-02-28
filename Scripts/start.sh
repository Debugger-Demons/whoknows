#!/bin/bash
# start.sh - Main entrypoint for Docker container

set -e

echo "Starting container setup..."

# Clone the repository if it doesn't exist
if [ ! -d "/whoknows/.git" ]; then
    echo "Cloning repository..."
    git clone https://github.com/Debugger-Demons/whoknows.git /whoknows
    
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

# Setup automatic updates via cron
echo "Setting up automatic updates..."
echo "*/15 * * * * cd /whoknows && git pull && cd /whoknows/src/Rust_Actix/backend && cargo build --release && kill -HUP \$(pgrep -f 'cargo run --release')" > /etc/cron.d/update-app
chmod 0644 /etc/cron.d/update-app
service cron start

# Function to handle signals
handle_signal() {
    echo "Received signal to restart application"
    if [ -n "$APP_PID" ]; then
        kill -TERM $APP_PID
        wait $APP_PID
    fi
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
