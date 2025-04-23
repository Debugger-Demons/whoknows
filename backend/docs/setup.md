# Backend Setup Guide

## Prerequisites
- Rust 1.81 or later
- Cargo package manager
- Docker (optional, for containerized deployment)
- SQLite (included in Rust dependencies)

## Local Development Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/your-repo.git
cd your-repo/backend
```

### 2. Environment Setup
Create a `.env` file in the backend directory with the following variables:
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
cargo build
cargo run
```

The server will be available at `http://localhost:8080`

## Docker Development Setup

### 1. Build Docker Image
```bash
docker build -t whoknows-backend .
```

### 2. Run Container
```bash
docker run -p 8080:8080 \
  -e DATABASE_URL=sqlite:/app/data/whoknows.db \
  -e BACKEND_INTERNAL_PORT=8080 \
  -e RUST_LOG=debug \
  -e SESSION_SECRET_KEY=your_secure_random_key_here \
  -v $(pwd)/data:/app/data \
  whoknows-backend
```

## Docker Compose Setup

### 1. Using docker-compose.dev.yml
```bash
docker-compose -f docker-compose.dev.yml up backend
```

This will:
- Build the backend container
- Set up all necessary environment variables
- Create a volume mount for persistent data
- Expose the service on the configured port

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