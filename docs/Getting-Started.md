# Getting Started with WhoKnows

Welcome to the WhoKnows project! This guide will help you get up and running quickly.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Git](https://git-scm.com/)
- [Rust](https://www.rust-lang.org/tools/install) 1.81 or later
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

3. **Start the backend**
   ```bash
   cd backend
   cargo run
   ```

4. **Start the frontend (in a new terminal)**
   ```bash
   cd frontend
   cargo run
   ```

5. **Access the application**
   - Open your browser and go to: http://localhost:8080

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
