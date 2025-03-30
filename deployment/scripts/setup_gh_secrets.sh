#!/bin/bash
set -e

echo "--- GitHub Actions Secrets Setup ---"

# Check dependencies
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI ('gh') not found. Please install it first."
    echo "See: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "Error: Not logged into GitHub CLI. Please run 'gh auth login'."
    exit 1
fi

# --- End Configuration ---
BASE_ENV_FILE_PATH="../../"

DEFAULT_ENV_FILE="$BASE_ENV_FILE_PATH.env.production"


# Set environment variables
function select_environment() {
    echo "Choose the environment to set secrets for:"
    echo "1. Production (default)"
    echo "2. Development"
    read -p "Enter your choice [1]: " ENV_CHOICE
    ENV_CHOICE=${ENV_CHOICE:-1}

    if [ "$ENV_CHOICE" == "2" ]; then
        ENV_PREFIX="DEV"
        ENV_NAME="development"
        
    else
        ENV_PREFIX="PROD"
        ENV_NAME="production"
    fi

    DEFAULT_ENV_FILE="$BASE_ENV_FILE_PATH.env.$ENV_NAME"
    ENV_FILE=".env.$ENV_NAME"
    
  

    echo "Setting secrets for $ENV_NAME environment..."
}

DEFAULT_REPO="AlekOmOm/rust-actix-web_CD"
DEFAULT_SSH_USER="deploy"
DEFAULT_SSH_KEY_FILE="~/.ssh/id_rsa"
DEFAULT_SERVER_PORT="22"




# Collect and validate repo info
function get_repo_info() {
    echo "Enter the GitHub repository [${DEFAULT_REPO}]:"
    read GITHUB_REPO
    
    if [[ -z "$GITHUB_REPO" ]]; then
        GITHUB_REPO="$DEFAULT_REPO"
    fi
    
    if ! [[ "$GITHUB_REPO" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]; then
        echo "Error: Invalid repository format. Use 'owner/repo'."
        exit 1
    fi
}

function convert_path() {
    local path="$1"
    # Replace backslashes with forward slashes
    path="${path//\\/\/}"

    # Expand tilde to home directory
    path="${path/#\~/$HOME}"

    echo "$path"
}


# Collect and validate secret values
function get_secret_values() {
    read -p "Enter the Server Host/IP address (SERVER_HOST): " SERVER_HOST
    read -p "Enter the Server Deployment Username (SERVER_USER) [${DEFAULT_SSH_USER}]: " SERVER_USER
    SERVER_USER=${SERVER_USER:-$DEFAULT_SSH_USER}
    read -p "Enter the Server SSH Port [${DEFAULT_SERVER_PORT}]: " SERVER_PORT
    SERVER_PORT=${SERVER_PORT:-$DEFAULT_SERVER_PORT}
    read -p "Enter the path to the PRIVATE SSH key file [${DEFAULT_SSH_KEY_FILE}]: " SSH_KEY_FILE
    SSH_KEY_FILE=${SSH_KEY_FILE:-$DEFAULT_SSH_KEY_FILE}
    read -p "Enter the path to the ${ENV_NAME} .env file from project root [${ENV_FILE}]: " ENV_FILE_PATH
    ENV_FILE_PATH=${ENV_FILE_PATH:-$DEFAULT_ENV_FILE}
    read -s -p "Enter your GitHub PAT with read:packages scope (GHCR_PAT_OR_TOKEN): " GHCR_PAT_OR_TOKEN
    echo # Add newline after hidden input

    SSH_KEY_FILE=$(convert_path "${SSH_KEY_FILE}")
    ENV_FILE_PATH=$(convert_path "${ENV_FILE_PATH}")

    # Validate inputs
    if [[ -z "$SERVER_HOST" ]] || [[ -z "$SERVER_USER" ]] || [[ -z "$GHCR_PAT_OR_TOKEN" ]]; then
        echo "Error: Server Host, Server User, and GHCR PAT cannot be empty."
        exit 1
    fi
    
    if [[ ! -f "$SSH_KEY_FILE" ]]; then
        echo "Error: SSH private key file not found at '$SSH_KEY_FILE'."
        exit 1
    fi
    
    if [[ ! -f "$ENV_FILE_PATH" ]]; then
        echo "Error: .env file not found at '$ENV_FILE_PATH'."
        exit 1
    fi
    
    # Basic SSH key validation
    if ! grep -q "BEGIN .* PRIVATE KEY" "$SSH_KEY_FILE"; then
        echo "Warning: The SSH key file doesn't appear to be a valid private key."
        read -p "Continue anyway? (y/N): " continue_anyway
        [[ $continue_anyway == [yY] || $continue_anyway == [yY][eE][sS] ]] || exit 1
    fi
}

# Set secrets using GitHub CLI
function set_secrets() {
    echo "Setting secrets..."
    
    local prefix="$ENV_PREFIX"
    local status=0
    
    # Function to set a secret and track success
    set_secret() {
        local name="$1"
        local value="$2"
        local from_file="$3"
        
        echo -n "Setting ${prefix}_${name}... "
        
        if [ "$from_file" = true ]; then
            gh secret set "${prefix}_${name}" < "$value" --repo "$GITHUB_REPO" && echo "Done" || { echo "Failed"; status=1; }
        else
            gh secret set "${prefix}_${name}" --body "$value" --repo "$GITHUB_REPO" && echo "Done" || { echo "Failed"; status=1; }
        fi
    }
    
    set_secret "SERVER_HOST" "$SERVER_HOST" false
    set_secret "SERVER_USER" "$SERVER_USER" false
    set_secret "SERVER_PORT" "$SERVER_PORT" false
    set_secret "SSH_PRIVATE_KEY" "$SSH_KEY_FILE" true
    set_secret "ENV_FILE" "$ENV_FILE_PATH" true
    set_secret "GHCR_PAT_OR_TOKEN" "$GHCR_PAT_OR_TOKEN" false
    
    if [ $status -eq 0 ]; then
        echo "--- GitHub Secrets set successfully for $ENV_NAME environment! ---"
    else
        echo "Warning: Some secrets may not have been set properly. Check the output above."
        exit 1
    fi
}

# Display summary and confirm
function confirm_settings() {
    echo "---------------------------------"
    echo "Secrets to be set for repo '$GITHUB_REPO' in environment: $ENV_NAME"
    echo "---------------------------------"
    echo "SERVER_HOST:       $SERVER_HOST"
    echo "SERVER_USER:       $SERVER_USER"
    echo "SERVER_PORT:       $SERVER_PORT"
    echo "SSH_PRIVATE_KEY:   (from file $SSH_KEY_FILE)"
    echo "ENV_FILE:          (from file .env$ENV_NAME)"
    echo "GHCR_PAT_OR_TOKEN: (hidden)"
    echo "---------------------------------"
    read -p "Proceed? (y/N): " confirm
    [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
}

# Main execution
select_environment
get_repo_info
get_secret_values
confirm_settings
set_secrets