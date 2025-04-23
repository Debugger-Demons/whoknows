# Development Environment Setup

This guide provides detailed instructions for setting up a development environment for the WhoKnows project.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Git](https://git-scm.com/)
- [Rust](https://www.rust-lang.org/tools/install) 1.81 or later
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

## Step 4: Build the Backend

```bash
cd backend
cargo build
```

## Step 5: Build the Frontend

```bash
cd frontend
cargo build
```

## Step 6: Running the Application

### Running the Backend

```bash
cd backend
cargo run
```

The backend will be available at http://localhost:9200.

### Running the Frontend

In a new terminal:

```bash
cd frontend
cargo run
```

The frontend will be available at http://localhost:8080.

## Step 7: Testing

Run tests to ensure everything is working properly:

```bash
# Backend tests
cd backend
cargo test

# Frontend tests
cd frontend
cargo test
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