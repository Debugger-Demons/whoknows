# Development Environment Setup

This guide provides detailed instructions for setting up a development environment for the WhoKnows project.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Git](https://git-scm.com/)
- [Rust](https://www.rust-lang.org/tools/install) 1.81 or later
- [Cargo Make](https://github.com/sagiegurari/cargo-make) (`cargo install cargo-make`)
- [SQLite](https://www.sqlite.org/download.html)
- [Python](https://www.python.org/downloads/) (for pre-commit hooks)

## Step 1: Clone the Repository

```bash
git clone https://github.com/Debugger-Demons/whoknows.git
cd whoknows
```

## Step 2: Set Up Pre-commit Hooks

We use pre-commit hooks to ensure code quality:

```bash
# Install pre-commit
pip install pre-commit

# Install git hooks
pre-commit install
```

See [Pre-commit Setup](../precommitsetup.md) for more details.

## Step 3: Set Up the Database

Initialize the SQLite database:

```bash
sqlite3 whoknows.db < backend/db-migration/whoknows.tables.sql
```

## Step 4: Environment Configuration

Set up environment variables for both services:

```bash
# For backend
cd backend
cp .env.example .env.local.backend
# Edit .env.local.backend with your configuration

# For frontend
cd ../frontend
cp .env.example .env.local.frontend
# Edit .env.local.frontend with your configuration
```

## Step 5: Running the Application

### Option 1: Using Docker Compose (Recommended for Full Stack)

From the project root:
```bash
make run-compose
```

To stop the services:
```bash
make stop-compose
```

To clean up all containers, images, and volumes:
```bash
make clean-compose
```

### Option 2: Using Individual Services with Cargo Make

#### Running the Backend

```bash
cd backend
cargo make dev
```

The backend will be available at http://localhost:9200.

#### Running the Frontend

In a new terminal:

```bash
cd frontend
cargo make dev
```

The frontend will be available at http://localhost:8080.

### Option 3: Running Individual Docker Containers

```bash
# From project root
# For backend
make build-backend
make run-backend

# For frontend
make build-frontend
make run-frontend

# To stop services
make stop-backend
make stop-frontend
```

## Step 6: Testing

Run tests to ensure everything is working properly:

```bash
# Backend tests
cd backend
cargo test

# Frontend tests
cd frontend
cargo test
```

## GitHub Workflow

### Creating Issues

The project provides make commands for creating issues:

```bash
# Create an enhancement issue
make i-create-enhancement t="New feature description" f="./docs/issues/feature_description.md"

# Create a bug issue
make i-create-bug t="Bug description" f="./docs/issues/bug_description.md"

# Create a documentation issue
make i-create-documentation t="Documentation task" f="./docs/issues/docs_task.md"
```

### Creating Pull Requests

After making changes to environment variables:

```bash
make env-update
make pr-create
```

## IDE Setup

### VS Code

1. Install the [Rust Analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) extension
2. Install the [SQLite Explorer](https://marketplace.visualstudio.com/items?itemName=alexcvzz.vscode-sqlite) extension
3. Optional: Install the [Better TOML](https://marketplace.visualstudio.com/items?itemName=bungcip.better-toml) extension

Recommended settings for VS Code:

```json
{
  "editor.formatOnSave": true,
  "rust-analyzer.checkOnSave.command": "clippy"
}
```

### IntelliJ IDEA / CLion

1. Install the [Rust plugin](https://plugins.jetbrains.com/plugin/8182-rust)
2. Install the [Database Navigator](https://plugins.jetbrains.com/plugin/1800-database-navigator) plugin

## Troubleshooting

### Common Issues

#### Rust Toolchain Issues

If you encounter Rust toolchain problems:

```bash
rustup update
rustup component add clippy rustfmt
```

#### Database Errors

If you have issues with the database:

1. Check that SQLite is installed and available in your PATH
2. Ensure you have write permissions for the database file
3. Try deleting the database file and recreating it:
   ```bash
   rm whoknows.db
   sqlite3 whoknows.db < backend/db-migration/whoknows.tables.sql
   ```

#### Pre-commit Hook Errors

If pre-commit hooks fail:

1. Make sure Python is installed correctly
2. Try reinstalling pre-commit:
   ```bash
   pip uninstall pre-commit
   pip install pre-commit
   pre-commit install
   ```

## Next Steps

Now that your development environment is set up, you can:

1. Review the [Developer Guide](../developer_guide.md)
2. Explore the [Architecture Overview](../architecture/overview.md)
3. Check the [API Documentation](../api_documentation.md)
4. Look at the [Database Schema](../database_schema.md) 