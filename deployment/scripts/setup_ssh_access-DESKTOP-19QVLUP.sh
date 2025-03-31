#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
DEFAULT_DEPLOY_USER="deployer"
DEFAULT_SSH_KEY_NAME="deploy_key" # Output files will be deploy_key and deploy_key.pub
DEFAULT_SSH_PORT="22" # Default SSH port
# --- End Configuration ---

echo "--- Server SSH Access Setup ---"

# 1. Get Server Info
read -p "Enter your VM's Public IP address: " SERVER_IP
read -p "Enter the SSH port for the VM [${DEFAULT_SSH_PORT}]: " SSH_PORT # <-- ASK FOR PORT
SSH_PORT=${SSH_PORT:-$DEFAULT_SSH_PORT} # Use default if empty
read -p "Enter your *EXISTING* admin/sudo username on the VM (e.g., your google username): " ADMIN_USER
read -p "Enter the desired username for deployments [${DEFAULT_DEPLOY_USER}]: " DEPLOY_USER
DEPLOY_USER=${DEPLOY_USER:-$DEFAULT_DEPLOY_USER}
read -p "Enter the filename for the new SSH key pair [${DEFAULT_SSH_KEY_NAME}]: " SSH_KEY_NAME
SSH_KEY_NAME=${SSH_KEY_NAME:-$DEFAULT_SSH_KEY_NAME}
SSH_PUB_KEY="${SSH_KEY_NAME}.pub"

# Validate input
if [[ -z "$SERVER_IP" ]] || [[ -z "$ADMIN_USER" ]]; then
    echo "Error: Server IP and Admin Username cannot be empty."
    exit 1
fi
# Basic port validation
if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ]; then
    echo "Error: Invalid SSH port number."
    exit 1
fi


echo "---------------------------------"
echo "Configuration Summary:"
echo "Server Host IP:   $SERVER_IP"
echo "SSH Port:         $SSH_PORT" # <-- Show port
echo "Admin User:       $ADMIN_USER"
echo "Deployment User:  $DEPLOY_USER"
echo "SSH Key File:     $SSH_KEY_NAME / $SSH_PUB_KEY"
echo "---------------------------------"
read -p "Proceed? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# 2. Generate SSH Key Pair
# ... (key generation part remains the same) ...
echo "Generating SSH key pair ($SSH_KEY_NAME)..."
# Check if files exist (no change here)
if [ -f "$SSH_KEY_NAME" ] || [ -f "$SSH_PUB_KEY" ]; then
  echo "Warning: SSH key files '$SSH_KEY_NAME' or '$SSH_PUB_KEY' already exist."
  read -p "Overwrite? (y/N): " overwrite && [[ $overwrite == [yY] || $overwrite == [yY][eE][sS] ]] || { echo "Aborting."; exit 1; }
  rm -f "$SSH_KEY_NAME" "$SSH_PUB_KEY"
fi
ssh-keygen -t ed25519 -f "$SSH_KEY_NAME" -N "" # Generate key without passphrase
echo "SSH key pair generated: $SSH_KEY_NAME and $SSH_PUB_KEY"


# 3. Set up Deploy User and Push Public Key to Server
echo "Connecting to $SERVER_IP (Port: $SSH_PORT) as $ADMIN_USER to set up user '$DEPLOY_USER'..."

# Use the specified SSH port!
ssh -o StrictHostKeyChecking=no -p "$SSH_PORT" ${ADMIN_USER}@${SERVER_IP} << EOF
    set -e # Ensure remote commands also exit on error
    echo "--- Running commands on server ---"

    # Check if Docker and Docker Compose are installed (no change here)
    # ... (docker/compose checks remain the same) ...

    # Create the deploy user if it doesn't exist (no change here)
    # ... (user creation logic remains the same) ...

    # Add user to the docker group (no change here)
    # ... (docker group logic remains the same) ...

    # Set up SSH access for the deploy user (no change here)
    # ... (SSH directory/key setup remains the same) ...
    echo "Setting up SSH access for '$DEPLOY_USER'..."
    sudo mkdir -p /home/$DEPLOY_USER/.ssh
    sudo chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
    sudo chmod 700 /home/$DEPLOY_USER/.ssh
    sudo touch /home/$DEPLOY_USER/.ssh/authorized_keys
    # Read public key content securely
    PUB_KEY_CONTENT=\$(cat "$SSH_PUB_KEY")
    sudo bash -c "echo \"\$PUB_KEY_CONTENT\" >> /home/$DEPLOY_USER/.ssh/authorized_keys"
    # Ensure unique keys if run multiple times (optional but good)
    # sudo sort -u /home/$DEPLOY_USER/.ssh/authorized_keys -o /home/$DEPLOY_USER/.ssh/authorized_keys
    sudo chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh/authorized_keys
    sudo chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys
    sudo chmod 755 /home/$DEPLOY_USER # Ensure home dir is accessible

    echo "Public key added to /home/$DEPLOY_USER/.ssh/authorized_keys"
    echo "--- Server setup commands finished ---"
EOF

if [ $? -ne 0 ]; then
    echo "Error during server setup. Please check the output above."
    exit 1
fi

echo "Server setup appears successful."

# 4. Test SSH Connection as Deploy User
echo "Testing SSH connection as '$DEPLOY_USER' using the new key (Port: $SSH_PORT)..."
# Use the specified SSH port and the generated key!
ssh -o StrictHostKeyChecking=no -p "$SSH_PORT" -i "$SSH_KEY_NAME" ${DEPLOY_USER}@${SERVER_IP} "echo 'SSH connection successful! Running docker ps:'; docker ps"

if [ $? -ne 0 ]; then
    echo "Error: Failed to connect as '$DEPLOY_USER' using the new key or run 'docker ps'."
    # ... (error messages remain the same) ...
    exit 1
fi

echo "SSH connection test successful!"
echo "---"
echo "IMPORTANT NEXT STEP:"
echo "You MUST add/verify the following as GitHub Secrets in your repository settings:"
echo "  (Settings -> Secrets and variables -> Actions -> New repository secret)"
echo ""
echo "1.  SERVER_HOST:      ${SERVER_IP}"
echo "2.  SERVER_USER:      ${DEPLOY_USER}"
echo "3.  SSH_PRIVATE_KEY:  Copy the *entire content* of the file named '${SSH_KEY_NAME}' (the private key)"
echo "4.  SERVER_PORT:      ${SSH_PORT}" # <-- Use the port you entered
echo "5.  ENV_FILE:         Copy the *entire content* of your production '.env' file"
echo "6.  GHCR_PAT_OR_TOKEN: A GitHub Personal Access Token (PAT) with 'read:packages' scope."
echo ""
echo "You can use the 'setup_gh_secrets.sh' script (after fixing path issues) or set them manually."
echo "--- Setup Complete ---"