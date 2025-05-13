# Who Knows Frontend

A simple Rust Actix-Web implementation for serving the "Who Knows" search engine frontend.

## Overview

This project provides a lightweight frontend server that:

1. Serves static HTML, CSS, and JavaScript files
2. Proxies API requests to the backend service
3. Minimizes dependencies by using client-side JavaScript for templating and API calls

## 📚 Documentation

Detailed documentation is available in the `docs` directory:

- [Architecture Overview](docs/architecture.md) - System design and component interactions
- [Setup Guide](docs/setup.md) - Instructions for local and Docker setup
- [Client-Side Architecture](docs/client-side.md) - Frontend JavaScript, HTML, and CSS details
- [API Proxy Middleware](docs/proxy-middleware.md) - Details on the backend communication layer

## Architecture

- **Frontend**: Rust Actix-Web server serving static files and proxying API requests
- **Backend**: Separate container handling database and search functionality
- **Communication**: Frontend proxies client requests to the backend over Docker's internal network

## Docker Deployment Flow

When running with Docker Compose:

1. **Network Setup**: Docker Compose creates an internal network named `app-network`
2. **Service Discovery**: Containers can reach each other using their service names as hostnames (e.g., `backend:92`)
3. **Port Mapping**: Only the frontend container exposes a port to the host (typically 8080)

### Request-Response Flow

```
Browser → Frontend Container → Backend Container → Frontend Container → Browser
   |             |                  |                   |                   |
   |             |                  |                   |                   |
   |             |                  |                   |                   |
Public Internet  |                  |                   |                   |
                 |                  |                   |                   |
             Docker Network ----------------------->    |                   |
                                                        |                   |
                                                    Response to client
```

See the [Architecture Overview](docs/architecture.md) for more details.

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Rust (for development only)
- Cargo Make (for development only)

### Installation

1. Clone the repository
2. Build and run the containers:

```bash
# Using Docker Compose
make run-compose

# Or just the frontend container
make build-frontend
make run-frontend
```

3. Access the application at `http://localhost:8080`

For detailed setup instructions, see the [Setup Guide](docs/setup.md).

## Project Structure

```
frontend/
├── Cargo.toml         # Rust dependencies
├── Dockerfile         # Container build instructions
├── src/
│   └── main.rs        # Actix-Web server with API proxy middleware
└── static/
    ├── css/           # Stylesheets
    ├── images/        # Static images
    ├── js/            # JavaScript files
    │   └── api.js     # API client using relative URLs
    └── html/          # HTML templates
```

## Development

To run the frontend in development mode:

```bash
# Install Cargo Make (if not already installed)
cargo install cargo-make

# Run with hot-reloading
cd frontend
cargo make dev
```

For Docker-based development:

```bash
# Run in Docker container
cargo make dev-docker

# Stop running container
cargo make stop-docker
```

For available tasks:

```bash
cargo make help
```

## Environment Variables

- `FRONTEND_INTERNAL_PORT`: Port the server listens on (default: 91)
- `BACKEND_INTERNAL_PORT`: Port the backend service uses (default: 92)
- `FRONTEND_URL`: URL for CORS configuration (default: http://localhost:8080)

## Contributing

1. Ensure you have Rust installed
2. Follow the setup instructions in the [Setup Guide](docs/setup.md)
3. Review the [Architecture Overview](docs/architecture.md) to understand the system
4. Make your changes and submit a pull request

## License

MIT

