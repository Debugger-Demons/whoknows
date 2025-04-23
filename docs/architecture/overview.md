# WhoKnows Architecture Overview

## System Architecture

WhoKnows is built with a simple and straightforward architecture that consists of:

1. **Frontend**: User interface for search and authentication
2. **Backend**: API server for handling requests
3. **Database**: SQLite database for storing users and pages

## Component Diagram

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│             │      │             │      │             │
│   Frontend  │◄────►│   Backend   │◄────►│  Database   │
│             │      │             │      │             │
└─────────────┘      └─────────────┘      └─────────────┘
```

## Components

### Frontend

- Written in Rust using a web framework
- Provides login/registration forms
- Offers search interface
- Displays page content results

### Backend

- Rust-based API server
- Handles authentication (login, register, logout)
- Manages search queries
- Retrieves and returns page content

### Database

- SQLite database
- Two main tables:
  - `users`: Stores user credentials
  - `pages`: Stores page content for searching

## Data Flow

1. **Authentication Flow**
   - User enters credentials in frontend
   - Backend validates credentials against database
   - Session token is returned to frontend

2. **Search Flow**
   - User enters search query
   - Backend executes search on page content
   - Results are returned to frontend
   - Frontend displays results to user

## Technology Stack

- **Language**: Rust
- **Database**: SQLite
- **HTTP Server**: Built into the Rust application
- **Frontend Framework**: Rust web framework

This architecture prioritizes simplicity and ease of maintenance while providing the core functionality of user authentication and search capabilities.