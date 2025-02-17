#!/bin/bash
# init_script.sh - located in /src/Rust_Actix/backend/Scripts/

set -e

echo "Starting initialization..."

# Install system dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    curl \
    pkg-config \
    libssl-dev

# Install Rust if not present
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

# Setup systemd service
sudo cp ./rust-app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable rust-app
sudo systemctl start rust-app

# Setup auto-update cron from current directory
SCRIPT_DIR=$(pwd)
(crontab -l 2>/dev/null; echo "*/5 * * * * $SCRIPT_DIR/auto_update.sh >> /var/log/whoknows-update.log 2>&1") | crontab -

echo "Initialization complete!"
