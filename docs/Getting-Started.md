# Getting Started with WhoKnows

Welcome to the WhoKnows project! This guide will help you get up and running quickly.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Git](https://git-scm.com/)
- [Rust](https://www.rust-lang.org/tools/install) 1.81 or later
- [Cargo Make](https://github.com/sagiegurari/cargo-make) (`cargo install cargo-make`)
- [SQLite](https://www.sqlite.org/download.html)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/Debugger-Demons/whoknows.git
   cd whoknows
   ```

2. **Set up the database**
   ```bash
   # Initialize the SQLite database with schema
   sqlite3 whoknows.db < backend/db-migration/whoknows.tables.sql
   ```

3. **Option 1: Run with Docker Compose**
   ```bash
   # Run both frontend and backend containers
   make run-compose
   ```

4. **Option 2: Run services individually**

   For the backend:
   ```bash
   cd backend
   cp .env.example .env.local.backend
   # Edit .env.local.backend as needed
   cargo make dev
   ```

   For the frontend (in a new terminal):
   ```bash
   cd frontend
   cp .env.example .env.local.frontend
   # Edit .env.local.frontend as needed
   cargo make dev
   ```

   Or use Docker for individual services:
   ```bash
   # Run just the backend
   make build-backend
   make run-backend
   
   # Run just the frontend
   make build-frontend
   make run-frontend
   ```

5. **Access the application**
   - Open your browser and go to: http://localhost:8080

6. **Stopping the services**
   ```bash
   # If using Docker Compose
   make stop-compose
   
   # If running individual containers
   make stop-frontend
   make stop-backend
   
   # To clean up all containers and images
   make clean-compose
   ```

## Core Functionality

### User Authentication

- **Register**: Create a new account with username, email, and password
- **Login**: Access your account with username/email and password
- **Logout**: Securely end your session

### Search

- Search for content across all pages in the database
- Filter results by language (English or Danish)
- View detailed page information by clicking on search results

## Development Workflow

We recommend setting up pre-commit hooks to ensure code quality:

```bash
# Install pre-commit
pip install pre-commit

# Set up hooks
pre-commit install
```

See the [Pre-commit Setup](./precommitsetup.md) documentation for more details.

## Getting Help

If you encounter any issues, please create a new issue on our GitHub repository with a detailed description of the problem.
