#!/bin/bash
# init_script.sh - located in /src/Rust_Actix/backend/Scripts/

set -e

echo "Starting initialization..."

# Install system dependencies
sudo apt-get update

# Fix array syntax: remove commas and spaces around =
installs=("build-essential" "curl" "pkg-config" "gcc" "libssl-dev")

# Rest of the script is correct
for i in "${installs[@]}"; do 
    if command -v "$i" &> /dev/null; then
        echo "$i is already installed"
    else
        sudo apt-get install -y "$i"
    fi
done

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
