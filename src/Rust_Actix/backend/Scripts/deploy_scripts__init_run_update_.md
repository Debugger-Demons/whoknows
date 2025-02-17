# Deployment Scripts Documentation

## Quick Start
```bash
./init_script.sh
```
This single script initializes everything:
1. Sets up auto_update.sh (5min cron job for git pulls)
2. Configures run_forever_fixed.sh (keeps app running)
3. Installs rust-app.service (systemd manager for the above)

## Scripts Overview

### init_script.sh
* **Use Case**: Initial system setup and service configuration
* **Running**: Direct execution
  ```bash
  ./init_script.sh
  ```

### auto_update.sh
* **Use Case**: Continuous deployment and update management
* **Running**: Automatically via cron (every 5 minutes)

### run_forever_fixed.sh
* **Use Case**: Service resilience and crash recovery
* **Running**: Automatically via systemd

### rust-app.service
* **Use Case**: SystemD service configuration
* **Running**: Managed by systemd

## Detailed Analysis

### 1. Core Capabilities

#### Automated System Setup (init_script.sh)
- Installs required dependencies
- Sets up Rust environment
- Configures systemd service
- Establishes auto-update cron job

#### Continuous Deployment (auto_update.sh)
- Polls git repository for changes
- Automatically pulls and deploys updates
- Includes health checking
- Handles service restarts
- Maintains deployment logs

#### Service Resilience (run_forever_fixed.sh + rust-app.service)
- Ensures continuous operation
- Automatic crash recovery
- Proper cargo target directory management

### 2. Workflow Usage

#### Initial Setup
1. Copy scripts to server
2. Run init_script.sh to bootstrap environment
3. Service auto-starts via systemd

#### Ongoing Development
1. Develop locally
2. Push to git repository
3. auto_update.sh detects changes (every 5 min)
4. Changes automatically deploy
5. Service restarts if needed
6. Health check confirms deployment

#### Monitoring
- Check `/var/log/deploy.log` for deployment status
- Check `/var/log/whoknows-update.log` for update attempts
- Use `systemctl status rust-app` for service status

### 3. Key Benefits

#### Zero-Touch Deployments
- No manual intervention needed for updates
- Automatic health verification
- Built-in failure handling

#### Operational Resilience
- Automatic crash recovery
- Logged operations
- Systematic dependency management

#### Development Workflow Integration
- Git-based deployment
- Separation of development and operations
- Automated environment setup

### Important Note
The rust-app.service file needs its paths updated to match the actual installation directory before use:
```ini
WorkingDirectory=/path/to/whoknows/src/Rust_Actix/backend
ExecStart=/path/to/whoknows/src/Rust_Actix/backend/Scripts/run_forever_fixed.sh
```

This setup enables a DevOps workflow where developers can focus on pushing code while the operational aspects are handled automatically through these scripts.
