# Docker

## Overview

Docker is used to containerize the WhoKnows application, making it easier to develop, test, and deploy in consistent environments. This document covers the Docker setup for our simple application with user authentication and search functionality.

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

The `docker-compose.yml` file defines the services needed to run the application. It uses environment variables from the `.env` file:

```yaml
services:
  backend:
    container_name: whoknows.local.backend
    env_file:
      - .env
    image: ${IMAGE_TAG_BACKEND_LOCAL}
    build:
      context: ./backend
      args:
        - APP_NAME=whoknows_local_compose
        - RUST_LOG=${RUST_LOG}
        - COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
        - BACKEND_INTERNAL_PORT=${BACKEND_INTERNAL_PORT}
    restart: unless-stopped
    environment:
      - COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
      - BACKEND_INTERNAL_PORT=${BACKEND_INTERNAL_PORT}
      - RUST_LOG=${RUST_LOG}
      - DATABASE_URL=${DATABASE_URL}
      - SESSION_SECRET_KEY=${SESSION_SECRET_KEY}
    volumes:
      - ./database:/app/data
    expose:
      - "${BACKEND_INTERNAL_PORT}"
    networks:
      - app-network

  frontend:
    container_name: whoknows.local.frontend
    image: ${IMAGE_TAG_FRONTEND_LOCAL}
    build:
      context: ./frontend
    ports:
      - "${HOST_PORT_FRONTEND:-8080}:${FRONTEND_INTERNAL_PORT:-91}"
    networks:
      - app-network
    depends_on:
      - backend
```

## Environment Variables

The Docker Compose setup uses a `.env` file to configure the application. Here's a template for the required environment variables:

```dotenv
# Project Configuration
COMPOSE_PROJECT_NAME=whoknows

# Port Configuration
HOST_PORT_FRONTEND=8080
FRONTEND_INTERNAL_PORT=91
BACKEND_INTERNAL_PORT=92

# Database Configuration
DATABASE_URL=sqlite:/app/data/whoknows.db

# Docker Image Tags
IMAGE_TAG_BACKEND_LOCAL=whoknows.local.backend
IMAGE_TAG_FRONTEND_LOCAL=whoknows.local.frontend

# Backend Configuration
RUST_LOG=info
SESSION_SECRET_KEY=your_secret_key_here
```

To set up your environment:

1. Copy the above template to a file named `.env` in the project root
2. Adjust the values as needed for your environment

Alternatively, you can run the provided setup script that will create the file for you:

```bash
python scripts/check_env.py
```

## Running with Docker Compose

You can use the Makefile commands to manage the Docker Compose setup:

```bash
# Start the application
make run-compose

# Stop the application
make stop-compose

# Clean up containers and images
make clean-compose
```

## Running Individual Containers

You can also run the frontend or backend containers separately using their respective Makefiles:

### Backend Container

```bash
cd backend
make dev-docker
```

### Frontend Container

```bash
cd frontend
make dev-docker
```

To stop the individual containers:

```bash
# For frontend
cd frontend
make stop-docker

# For backend (manually stop with docker commands)
docker stop whoknows_backend_test
```

## Common Commands

### Building and Running

```bash
make run-compose

# make stop-compose
# make clean-compose   -- cleanup after `make run-compose`
```

### Management

```bash
# View running containers
docker ps

# Stop running containers
make stop-compose
#docker-compose down

# View logs
docker-compose logs -f
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

1. **Port already in use**: If port 8080 is already in use, change the port mapping in `.env`:
   ```yaml
   ## from: HOST_PORT_FRONTEND=8080 # <------------ main PORT
   HOST_PORT_FRONTEND=8081
   ```

2. **Database file permissions**: If you encounter database file permission issues, ensure the volume directory is writable:
   ```bash
   chmod 777 ./data
   ``` 