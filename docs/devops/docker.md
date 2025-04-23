# Docker

## Overview

Docker is used to containerize the WhoKnows application, making it easier to develop, test, and deploy in consistent environments. This document covers the Docker setup and usage for the project.

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) for running multi-container applications

## Project Structure

The Docker setup for WhoKnows consists of the following files:

- `Dockerfile` - Defines the container image for the application
- `docker-compose.yml` - Defines the services, networks, and volumes for the application
- `.dockerignore` - Lists files that should be excluded from the Docker context

## Docker Images

The project uses a single Docker image that contains both the backend and frontend components:

```dockerfile
FROM rust:1.81 as builder
WORKDIR /usr/src/app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
WORKDIR /usr/local/bin
COPY --from=builder /usr/src/app/target/release/whoknows .
COPY --from=builder /usr/src/app/backend/db-migration/whoknows.tables.sql /usr/local/bin/
EXPOSE 8080
CMD ["./whoknows"]
```

## Docker Compose

The `docker-compose.yml` file defines the services needed to run the application:

```yaml
version: '3.8'
services:
  whoknows:
    build: .
    ports:
      - "8080:8080"
    volumes:
      - ./data:/data
    environment:
      - DATABASE_URL=sqlite:/data/whoknows.db
      - RUST_LOG=info
```

## Common Commands

### Building and Running

```bash
# Build the Docker image
docker build -t whoknows .

# Run the Docker container
docker run -p 8080:8080 whoknows

# Build and run with Docker Compose
docker-compose up --build

# Run in detached mode
docker-compose up -d
```

### Management

```bash
# View running containers
docker ps

# Stop running containers
docker-compose down

# View logs
docker-compose logs -f

# Execute commands inside the container
docker-compose exec whoknows /bin/bash
```

## Development with Docker

For development, you can mount your local source code into the container:

```bash
# Run with local source code mounted
docker run -p 8080:8080 -v $(pwd):/usr/src/app whoknows
```

This allows you to edit code on your local machine and see changes immediately without rebuilding the container.

## Troubleshooting

### Common Issues

1. **Port already in use**: If port 8080 is already in use, change the port mapping in `docker-compose.yml`:
   ```yaml
   ports:
     - "8081:8080"  # Maps container port 8080 to host port 8081
   ```

2. **Database file permissions**: If you encounter database file permission issues, ensure the volume directory is writable:
   ```bash
   chmod 777 ./data
   ```

3. **Container won't start**: Check the logs for detailed error messages:
   ```bash
   docker-compose logs
   ``` 