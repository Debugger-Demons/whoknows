# Backend Architecture

## Overview
The backend service is built with Rust using the Actix web framework. This document outlines the architectural design, core components, and interactions within the system.

## High-Level Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│  Client     │◄────►│  Actix Web   │◄────►│  SQLite DB  │
│  (Frontend) │      │  (Backend)   │      │  (Storage)  │
└─────────────┘      └──────────────┘      └─────────────┘
```

## Core Components

### Web Server (Actix)
- **Role**: Handles HTTP requests, manages middleware, and routes to appropriate handlers
- **Key Features**:
  - Asynchronous request handling with Tokio runtime
  - Structured logging
  - CORS support
  - Session management and authentication

### Database Layer (SQLx)
- **Role**: Provides type-safe database interaction
- **Key Features**:
  - SQL query validation at compile time
  - Connection pooling
  - Transaction support
  - Migration management

### Data Models
- Defined in `src/models.rs`
- **Key Models**:
  - `User`: Authentication and user profile data
  - `Page`: Content data for the application

### Authentication System
- **Components**:
  - Password hashing with Argon2
  - Session-based authentication
  - Flash messages for user feedback
- **Security Measures**:
  - Secure password storage
  - Secure cookie settings

## Request Flow

1. **Client Request**: Frontend sends HTTP request to backend endpoint
2. **Middleware Processing**:
   - CORS headers applied
   - Session validation
   - Authentication checks
3. **Response Generation**:
   - Data serialization
   - Status code selection
   - Header application
4. **Client Response**: Formatted data returned to frontend

## Deployment Architecture

```
┌─────────────────────────────────┐
│ Docker Container                │
│                                 │
│  ┌─────────────┐ ┌───────────┐  │
│  │  Actix Web  │ │  SQLite   │  │
│  │  Server     │ │  Database │  │
│  └─────────────┘ └───────────┘  │
│                                 │
└─────────────────────────────────┘
```

- **Container**: Docker-based deployment
- **Data Persistence**: Volume mapping for SQLite database
- **Networking**: Exposed on configured port with appropriate security 
