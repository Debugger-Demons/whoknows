# Who Knows Frontend

A simple Rust Actix-Web implementation for serving the "Who Knows" search engine frontend.

## Overview

This project provides a lightweight frontend server that:

1. Serves static HTML, CSS, and JavaScript files
2. Communicates with a backend container for data operations
3. Minimizes dependencies by using client-side JavaScript for templating and API calls

## Architecture

- **Frontend**: Rust Actix-Web server serving static files
- **Backend**: Separate container handling database and search functionality
- **Communication**: Frontend JavaScript makes API calls to the backend

## Features

- Clean separation of concerns between frontend and backend
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
│   └── main.rs        # Actix-Web server
└── static/
    ├── css/           # Stylesheets
    ├── images/        # Static images
    ├── js/            # JavaScript files
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

## Customization

- HTML files in `static/html/` can be modified to change the UI
- JavaScript in `static/js/` handles all frontend logic
- CSS in `static/css/` controls the styling
- Backend URL is configured via the `BACKEND_URL` environment variable

## License

MIT

