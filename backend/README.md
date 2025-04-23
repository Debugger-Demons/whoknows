# Backend Service

## Overview
The backend service is built with Rust using the Actix web framework. It provides RESTful API endpoints and handles user authentication, data storage, and business logic for the application.

## 📚 Documentation

Detailed documentation is available in the `docs` directory:

- [API Documentation](docs/api.md) - Details of all API endpoints
- [Architecture Overview](docs/architecture.md) - System design and components
- [Setup Guide](docs/setup.md) - Instructions for local and Docker setup
- [Database Documentation](docs/database.md) - Schema and data access patterns

## Tech Stack
- **Language**: Rust
- **Web Framework**: Actix-web 4.0
- **Database**: SQLite with SQLx for type-safe queries
- **Authentication**: Argon2 password hashing, session-based authentication
- **Serialization**: Serde

## Directory Structure
- `/src` - Source code
  - `main.rs` - Application entry point and route definitions
  - `models.rs` - Data models and structures
- `/db-migration` - Database schema and migration files
- `/.sqlx` - SQLx prepared statements cache
- `/scripts` - Utility scripts
- `/learnings` - Documentation and notes
- `/docs` - Detailed documentation

## Quick Start

### Local Development
```bash
# Clone repository and navigate to backend directory
cd backend

# Set up environment variables
cp .env.example .env.local.backend
# Edit .env.local.backend with your settings

# Run with hot-reloading (uses cargo-make)
cargo install cargo-make
cargo make dev
```

### Docker Development
```bash
# Using cargo-make
cargo make dev-docker

# Or using root Makefile
cd ..
make build-backend
make run-backend
```

### Using Docker Compose
```bash
# From project root
make run-compose
```

## Environment Variables
- `DATABASE_URL`: Path to SQLite database
- `BACKEND_INTERNAL_PORT`: Port the server listens on
- `RUST_LOG`: Logging level configuration
- `SESSION_SECRET_KEY`: Key for secure session cookies

## API Endpoints Overview
- `GET /` - Health check
- `GET /config` - Server configuration info
- `POST /api/login` - User authentication
- `GET /api/logout` - Session termination
- `POST /api/register` - User registration
- `GET /api/search` - Search functionality

See the [API Documentation](docs/api.md) for complete details.

## Contributing
1. Ensure you have Rust installed
2. Follow the setup instructions in the [Setup Guide](docs/setup.md)
3. Review the [Architecture Overview](docs/architecture.md) to understand the system
4. Make your changes and submit a pull request
