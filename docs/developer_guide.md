# Developer Guide

This guide provides essential information for developers working on the WhoKnows project.

## Project Structure

```
/
├── backend/                # Backend service
│   ├── src/                # Rust source code
│   └── db-migration/       # Database migration scripts
├── frontend/               # Frontend service
│   └── src/                # Rust source code
└── docs/                   # Documentation
```

## Development Setup

Follow the [Getting Started](./Getting-Started.md) guide to set up your development environment.

## Architecture

WhoKnows follows a simple architecture with:
- Frontend UI built with Rust
- Backend API built with Rust
- SQLite database for storage

For more details, see the [Architecture Overview](./architecture/overview.md).

## Database

The database schema includes two main tables:
- `users`: For authentication
- `pages`: For searchable content

For details, see the [Database Schema](./database_schema.md).

## API

The API provides endpoints for:
- User authentication (register, login, logout)
- Search functionality

For complete API documentation, see the [API Documentation](./api_documentation.md).

## Development Workflow

### Making Changes

1. Create a new branch for your changes
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes to the code

3. Test your changes
   ```bash
   cargo test
   ```

4. Commit your changes
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

5. Push your branch
   ```bash
   git push origin feature/your-feature-name
   ```

6. Create a pull request on GitHub

### Code Style

- Follow the Rust style guide
- Use meaningful variable and function names
- Write clear comments for complex logic
- Include tests for new functionality

### Testing

Run tests using:
```bash
cargo test
```

## Adding Features

When adding new features:

1. Consider the core functionality (authentication and search)
2. Design the user interface
3. Implement the backend API changes
4. Update the database schema if needed
5. Write tests for the new functionality
6. Update documentation

## Common Tasks

### Adding a New API Endpoint

1. Define the route in the backend
2. Implement the handler function
3. Connect to any required database operations
4. Add tests for the endpoint
5. Update API documentation

### Updating the Database Schema

1. Create a new migration script in `backend/db-migration/`
2. Run the migration during development
3. Update the database schema documentation
4. Update any affected code

## Troubleshooting

### Common Development Issues

- **Compilation errors**: Check for syntax errors or missing dependencies
- **Test failures**: Check the test output for specific failures
- **Database issues**: Ensure the database file exists and has the correct permissions

### Debugging

- Use `println!` statements or the Rust logging system
- Check application logs for errors
- Use Rust debugging tools if available

## Resources

- [Rust Documentation](https://www.rust-lang.org/learn)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Git Guide](https://git-scm.com/book) 