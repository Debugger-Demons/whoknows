# Who Knows Frontend

A simple Rust Actix-Web implementation for serving the "Who Knows" search engine frontend.

## Overview

This project provides a lightweight frontend server that:

1. Serves static HTML, CSS, and JavaScript files
2. Proxies API requests to the backend service
3. Minimizes dependencies by using client-side JavaScript for templating and API calls

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

1. **Client Request**: Browser makes a request to `/api/search?q=query`
2. **Frontend Proxy**: Actix-Web middleware intercepts API requests
3. **Internal Request**: Proxy forwards to `http://backend:92/api/search?q=query`
4. **Backend Processing**: Backend processes request and returns response
5. **Response Forwarding**: Frontend sends backend's response back to browser

This approach solves several challenges:
- **HTTPS Mixed Content**: Browser only makes requests to one origin
- **Network Isolation**: Backend is not directly accessible from outside
- **DNS Resolution**: Docker's internal DNS resolves service names to container IPs

## Features

- Clean separation of concerns between frontend and backend
- API request proxying between containers
- Simple, lightweight implementation
- No server-side templating (uses JavaScript instead)
- Docker containerization for easy deployment

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Rust (for development only)

### Installation

1. Clone the repository
2. Build and run the containers:

```bash
docker-compose up --build
```

3. Access the application at `http://localhost:8080`

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
cd frontend
cargo run
```

For hot-reloading during development, you can use `cargo-watch`:

```bash
cargo watch -x run
```

## Implementation Details

### API Proxying

The frontend server uses Actix-Web middleware to proxy API requests:

1. Intercepts requests starting with `/api/`
2. Forwards them to the backend container
3. Returns the backend's response to the client

### Frontend JavaScript

The JavaScript API client uses relative URLs that get proxied:

```javascript
// Instead of absolute URLs like http://backend:92/api/search
fetch('/api/search?q=query')
```

### Docker Networking

In the Docker Compose setup:
- Containers communicate via the `app-network`
- Service name `backend` resolves to the backend container's IP
- Only the frontend is accessible from outside the Docker network

## Customization

- HTML files in `static/html/` can be modified to change the UI
- JavaScript in `static/js/` handles all frontend logic
- CSS in `static/css/` controls the styling
- Backend URL is configured via the `BACKEND_URL` environment variable

## License

MIT
