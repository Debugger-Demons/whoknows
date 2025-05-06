# Database Documentation

## Overview
The backend service uses SQLite as its database system, with SQLx providing type-safe query interfaces.

## Schema Design

### Users Table
Stores user authentication and profile information.

| Column   | Type    | Description                  | Constraints        |
|----------|---------|------------------------------|-------------------|
| id       | INTEGER | Unique user identifier       | PRIMARY KEY, AUTOINCREMENT |
| username | TEXT    | User login name              | UNIQUE, NOT NULL  |
| email    | TEXT    | User email address           | UNIQUE, NOT NULL  |
| password | TEXT    | Argon2 hashed password       | NOT NULL          |

### Pages Table
Stores content pages for the application.

| Column       | Type      | Description                  | Constraints     |
|--------------|-----------|------------------------------|----------------|
| title        | TEXT      | Page title                   | PRIMARY KEY, UNIQUE |
| url          | TEXT      | URL identifier for the page  | UNIQUE, NOT NULL |
| language     | TEXT      | Content language code        | NOT NULL, CHECK(language IN ('en', 'da')), DEFAULT 'en' |
| last_updated | TIMESTAMP | Timestamp of last update     |                |
| content      | TEXT      | Page content                 | NOT NULL       |

## Database Access Patterns

### SQLx Integration
The application uses SQLx for type-safe queries:

```rust
// Example: User lookup
sqlx::query!("SELECT id, username, email, password FROM users WHERE username = ?", username)
    .fetch_optional(pool.get_ref())
    .await
```

### Connection Pooling
Connection pooling is configured in `main.rs`:

```rust
let pool = SqlitePoolOptions::new()
    .max_connections(5)
    .connect(&database_url)
    .await?;
```

## Migrations
Database migrations are stored in the `db-migration` directory.

### Initial Schema
The initial schema is defined in `whoknows.tables.sql`. The schema includes:
- User authentication tables
- Content storage tables
- Appropriate constraints and defaults

### Running Migrations
Migrations can be applied using:
```bash
sqlx migrate run
```

## Security Considerations

### Password Storage
- Passwords are stored using Argon2 hashing algorithm
- Password verification is handled by the authentication system

### SQL Injection Prevention
- Parameterized queries are used throughout the application
- SQLx provides compile-time validation of SQL queries

## Performance Notes

### Indexes
- Primary key indexes on ID fields
- Consider adding indexes for frequently queried fields

### Query Optimization
- For complex queries, consider using prepared statements
- Limit result sets for large data operations 