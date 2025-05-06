# Frontend Setup Guide

## Prerequisites
- Rust 1.81 or later
- Cargo package manager
- Docker (optional, for containerized deployment)
- Access to the backend service (for complete functionality)

## Local Development Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/your-repo.git
cd your-repo/frontend
```

### 2. Environment Setup
Create a `.env` file in the frontend directory with the following variables:
```
FRONTEND_INTERNAL_PORT=91
BACKEND_INTERNAL_PORT=92
FRONTEND_URL=http://localhost:8080
```

### 3. Build and Run
```bash
# Build the project
cargo build

# Run the server
cargo run
```

The server will be available at `http://localhost:91`

### 4. Hot Reloading (Optional)
For development with hot reloading:

```bash
# Install cargo-watch if you don't have it
cargo install cargo-watch

# Run with hot reloading
cargo watch -x run
```

## Docker Development Setup

### 1. Build Docker Image
```bash
docker build -t whoknows-frontend .
```

### 2. Run Container
```bash
docker run -p 8080:91 \
  -e FRONTEND_INTERNAL_PORT=91 \
  -e BACKEND_INTERNAL_PORT=92 \
  -e FRONTEND_URL=http://localhost:8080 \
  whoknows-frontend
```

## Docker Compose Setup

### 1. Using docker-compose.dev.yml
```bash
docker-compose -f docker-compose.dev.yml up frontend
```

This setup:
- Builds the frontend container
- Sets environment variables
- Creates network links to the backend service
- Exposes the frontend on port 8080

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `FRONTEND_INTERNAL_PORT` | Port the server listens on | `91` |
| `BACKEND_INTERNAL_PORT` | Port the backend service uses | `92` |
| `FRONTEND_URL` | URL for CORS configuration | `http://localhost:8080` |

## Troubleshooting

### Common Issues

#### Cannot connect to backend
- Ensure the backend service is running
- Verify the `BACKEND_INTERNAL_PORT` is correct
- Check Docker network configuration if using containers

#### Static files not loading
- Check the `static` directory structure
- Verify the server is running with the correct working directory
- Inspect network requests in browser dev tools

## Production Considerations

### Security
- Set appropriate CORS headers for your production domain
- Consider running behind a reverse proxy with HTTPS
- Review and restrict unnecessary HTTP headers

### Performance
- Enable release mode compilation with `cargo build --release`
- Consider using a CDN for static assets in production
- Implement caching headers for static resources 