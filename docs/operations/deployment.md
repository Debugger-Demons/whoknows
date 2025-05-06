# Deployment Guide

This document outlines the process for deploying the WhoKnows application to production environments.

## Deployment Methods

WhoKnows can be deployed using:

1. **Docker (Recommended)**: Container-based deployment
2. **Manual Deployment**: Direct installation on server

## Docker Deployment

### Prerequisites

- Docker installed on the server
- Access to the git repository

### Deployment Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Debugger-Demons/whoknows.git
   cd whoknows
   ```

2. **Build the Docker image**
   ```bash
   docker build -t whoknows:latest .
   ```

3. **Run the container**
   ```bash
   docker run -d --name whoknows-app \
     -p 8080:8080 \
     -v ./data:/data \
     -e DATABASE_URL=sqlite:/data/whoknows.db \
     -e RUST_LOG=info \
     whoknows:latest
   ```

4. **Verify deployment**
   ```bash
   curl http://localhost:8080/api/health
   ```

## Manual Deployment

### Prerequisites

- Rust installed on the server
- SQLite installed
- Git access

### Deployment Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Debugger-Demons/whoknows.git
   cd whoknows
   ```

2. **Set up the database**
   ```bash
   sqlite3 whoknows.db < backend/db-migration/whoknows.tables.sql
   ```

3. **Build the application**
   ```bash
   cargo build --release
   ```

4. **Run the application**
   ```bash
   ./target/release/whoknows
   ```

## Environment Configuration

The following environment variables can be set to configure the application:

| Variable | Description | Default |
|----------|-------------|---------|
| DATABASE_URL | SQLite database URL | sqlite:./whoknows.db |
| RUST_LOG | Logging level | info |
| PORT | Server port | 8080 |

## Updating the Application

To update the deployed application:

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Rebuild and restart**
   
   For Docker:
   ```bash
   docker build -t whoknows:latest .
   docker stop whoknows-app
   docker rm whoknows-app
   docker run -d --name whoknows-app -p 8080:8080 whoknows:latest
   ```
   
   For manual deployment:
   ```bash
   cargo build --release
   # Stop the existing process
   # Start the new process
   ./target/release/whoknows
   ```

## Backup and Restore

Since WhoKnows uses SQLite, backup is straightforward:

1. **Backup**
   ```bash
   cp whoknows.db whoknows.db.backup
   ```

2. **Restore**
   ```bash
   cp whoknows.db.backup whoknows.db
   ```

## Troubleshooting

- **Application won't start**: Check logs with `docker logs whoknows-app` or review console output
- **Database issues**: Ensure SQLite file has proper permissions
- **Connection refused**: Verify the correct port is exposed and not blocked by firewall