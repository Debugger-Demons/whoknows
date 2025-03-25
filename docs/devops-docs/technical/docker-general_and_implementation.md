# Docker Documentation

## What is Docker?
Docker is a platform that helps developers package applications and their dependencies into standardized units called containers. Think of a container as a lightweight, standalone package that includes everything needed to run your application.

### Key Concepts
- **Container**: A runnable instance of an application and its dependencies
- **Image**: A template for containers (like a class in programming)
- **Dockerfile**: Instructions to build an image
- **Docker Compose**: Tool to manage multi-container applications

### Simple Example
```dockerfile
# Basic example of a Dockerfile
FROM ubuntu:latest              # Base image
COPY my-app /app               # Copy files
WORKDIR /app                   # Set working directory
CMD ["./my-app"]              # Run command
```

## Our Implementation

### Project Structure
```
whoknows/
├── Dockerfile             # Container build instructions
├── docker-compose.yml     # Container orchestration
├── supervisord.conf       # Process management
└── src/
    └── Rust_Actix/
        └── backend/
            └── Scripts/   # Application scripts
```

### Key Files Explained

1. **Dockerfile**
```dockerfile
FROM ubuntu:22.04
# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    supervisor
# Setup Rust environment
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
WORKDIR /whoknows
COPY . .
```

2. **docker-compose.yml**
```yaml
services:
  rust-app:
    build: .
    ports:
      - "8080:8080"
    volumes:
      - ./logs:/var/log/supervisor
```

### How to Use

1. Build and Start:
```bash
docker-compose up -d --build
```

2. Check Status:
```bash
docker ps
docker-compose logs -f
```

3. Stop:
```bash
docker-compose down
```

### Common Commands
- `docker ps`: List running containers
- `docker logs [container-id]`: View container logs
- `docker exec -it [container-id] bash`: Enter container
- `docker-compose restart`: Restart services

### Troubleshooting
1. If container keeps restarting:
   - Check logs: `docker-compose logs -f`
   - Verify ports aren't in use: `netstat -tuln`

2. If application isn't accessible:
   - Check if container is running: `docker ps`
   - Verify port mapping: `docker port rust-app`

## Maintenance
- Logs are stored in `./logs/`
- Container automatically restarts on failure
- Updates handled by auto_update script

## Next Steps
1. Add monitoring
2. Implement health checks
3. Setup CI/CD pipeline
