# Backend Service

## Overview
The backend service is built with Rust using the Actix web framework. It provides RESTful API endpoints and handles user authentication, data storage, and business logic for the application.

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

## Docker Integration
The backend service is containerized and managed via Docker Compose.

### Dockerfile
The backend Dockerfile uses a multi-stage build process:
1. **Builder Stage**: Compiles the Rust application
2. **Runtime Stage**: Creates a minimal image with only the compiled binary

### Docker Compose Configuration
In `docker-compose.dev.yml`, the backend service is configured with:
- **Container Name**: Derived from `${COMPOSE_PROJECT_NAME}_backend_dev`
- **Environment Variables**: Database URL, session secrets, ports, etc.
- **Volume Mount**: `/home/deployer/deployment/app/data:/app/data` for persistent data
- **Network**: Connected to `app-network` for communication with other services
- **Port**: Exposed on `${BACKEND_INTERNAL_PORT}`

## Database Connection
The backend connects to an SQLite database:

1. **Connection Initialization**:
   ```rust
   let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
   let pool = SqlitePoolOptions::new()
       .max_connections(5)
       .connect(&database_url)
       .await?;
   ```

2. **Data Access**: The application uses SQLx for type-safe database operations:
   ```rust
   sqlx::query!("SELECT * FROM users WHERE username = ?", username)
       .fetch_optional(pool.get_ref())
       .await
   ```

3. **Migration**: Database schema is defined in `/db-migration/whoknows.sql`

## Request-Response Flow

1. **HTTP Request**: Client sends a request to an endpoint (e.g., `/api/login`)

2. **Middleware Processing**:
   - CORS handling
   - Session management
   - Authentication verification
   - Logging

3. **Route Handler**:
   - Request payload extraction and validation
   - Business logic execution
   - Database interaction
   - Response generation

4. **Response**: Formatted JSON is returned to the client

### Example: Login Flow
1. Client sends credentials to `/api/login`
2. Backend validates credentials against database
3. On success, session is created and user data returned
4. On failure, appropriate error message is returned

## Environment Variables
- `DATABASE_URL`: Path to SQLite database
- `BACKEND_INTERNAL_PORT`: Port the server listens on
- `RUST_LOG`: Logging level configuration
- `SESSION_SECRET_KEY`: Key for secure session cookies

## Running the Backend
### With Docker Compose
```bash
docker-compose -f docker-compose.dev.yml up backend
```

### Locally for Development
```bash
cd backend
cargo run
```

## API Endpoints
- `GET /` - Health check
- `GET /config` - Server configuration info
- `POST /api/login` - User authentication
- `GET /api/logout` - Session termination
- `POST /api/register` - User registration
- `GET /api/search` - Search functionality
