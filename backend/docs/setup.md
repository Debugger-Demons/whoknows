# Backend Setup Guide

## Prerequisites
- Rust 1.81 or later
- Cargo package manager
- Cargo Make (`cargo install cargo-make`)
- Docker (optional, for containerized deployment)
- SQLite (included in Rust dependencies)

## Local Development Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/your-repo.git
cd your-repo/backend
```

### 2. Environment Setup
Create a `.env.local.backend` file in the backend directory with the following variables:
```
DATABASE_URL=sqlite:./whoknows.db
BACKEND_INTERNAL_PORT=8080
RUST_LOG=debug
SESSION_SECRET_KEY=your_secure_random_key_here
```

Generate a secure random key for your sessions:
```bash
openssl rand -hex 32
```

### 3. Database Setup
The database will be created automatically on first run. For development, you can use the provided migration:
```bash
cargo install sqlx-cli
sqlx database create
sqlx migrate run
```

### 4. Build and Run
```bash
# Install cargo-make if not already installed
cargo install cargo-make

# Run with hot-reloading
cargo make dev
```

The server will be available at `http://localhost:8080`

## Docker Development Setup

### 1. Using Cargo Make (from backend directory)
```bash
cargo make dev-docker
```

### 2. Using Root Makefile (from project root)
```bash
make build-backend
make run-backend
```

The backend will be available at `http://localhost:92`

## Docker Compose Setup

### Using docker-compose with Makefile
```bash
# From project root
make run-compose
```

This will:
- Build both frontend and backend containers
- Set up all necessary environment variables
- Create volume mounts for persistent data
- Expose the services on the configured ports

## Stopping Services

### Stop Docker Containers
```bash
# Stop only backend (from project root)
make stop-backend

# Stop all services (from project root)
make stop-compose

# Clean up all containers, images and volumes (from project root)
make clean-compose
```

## Troubleshooting

### Common Issues

#### Cannot connect to database
- Ensure the `DATABASE_URL` environment variable is correct
- Check that the data directory is writable
- For Docker: ensure volume mount is correctly configured

#### Server not accessible
- Verify the `BACKEND_INTERNAL_PORT` matches your configuration
- For Docker: ensure port mapping is correctly set
- Check firewall settings

#### Authentication issues
- Validate that `SESSION_SECRET_KEY` is set
- For production, ensure secure cookies are enabled

## Production Considerations

### Security
- Use a properly secured `SESSION_SECRET_KEY`
- Enable secure and HttpOnly flags for cookies
- Configure CORS appropriately for your production domain
- Set up a reverse proxy (like Nginx) with HTTPS

### Performance
- Adjust database connection pool size for production load
- Consider using a proper database server for high traffic
- Enable release mode compilation with `cargo build --release` 