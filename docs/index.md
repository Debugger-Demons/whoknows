# WhoKnows Documentation

## Introduction
Welcome to the WhoKnows project documentation. This documentation covers the core aspects of the WhoKnows search engine with user authentication and search functionality.

## Project Overview

- [Backend README](../backend/README.md) - Backend service overview
- [Frontend README](../frontend/README.md) - Frontend service overview

## Core Documentation

### Getting Started
- [Getting Started](./Getting-Started.md) - Quick start guide for new developers

### System Components

#### Database
- [Database Schema](./database_schema.md) - Simple database structure with users and pages tables

#### Authentication
- User authentication (login, register, logout)
- [API Documentation](./api_documentation.md) - Authentication endpoints

#### Search
- Search functionality
- [API Documentation](./api_documentation.md#search) - Search endpoints

### Backend Documentation

The backend is a Rust service using Actix web framework and SQLite:

- [Backend Index](../backend/docs/index.md) - Backend documentation hub
- [Architecture](../backend/docs/architecture.md) - Backend system design
- [API Reference](../backend/docs/api.md) - Detailed API endpoints
- [Database](../backend/docs/database.md) - Database schema details
- [Setup Guide](../backend/docs/setup.md) - Backend setup instructions

### Frontend Documentation

The frontend is a Rust Actix-Web service serving static files:

- [Frontend Index](../frontend/docs/index.md) - Frontend documentation hub
- [Architecture](../frontend/docs/architecture.md) - Frontend system design
- [Client-Side](../frontend/docs/client-side.md) - JavaScript, HTML, and CSS details
- [Proxy Middleware](../frontend/docs/proxy-middleware.md) - Backend communication layer
- [Setup Guide](../frontend/docs/setup.md) - Frontend setup instructions

### Development Guides
- [Developer Guide](./developer_guide.md) - Essential information for developers
- [Development Setup](./development/setup.md) - Development environment setup 
- [Pre-commit Setup](./precommitsetup.md) - Setting up pre-commit hooks

### DevOps Documentation
- [DevOps Implementation Checklist](./devops-docs/DevOps_Checklist.md) - Week-by-week DevOps implementation tasks
- [DevOps Index](./devops/index.md) - DevOps documentation overview
- [GitHub Actions](./devops/github-actions.md) - CI/CD workflows
- [Docker](./devops/docker.md) - Docker setup and usage

### Architecture Documentation
- [Architecture Overview](./architecture/overview.md) - System architecture overview

### Operations Documentation
- [Deployment Guide](./operations/deployment.md) - How to deploy the application
- [Monitoring Guide](./operations/monitoring.md) - Basic monitoring setup

## User Documentation
- [User Guide](./user_guide.md) - Instructions for end users

## Documentation Management
- [Documentation Checklist](./documentation-checklist.md) - Track documentation progress

## Documentation Structure

```
/
├── README.md               # Project overview
├── backend/                # Backend service
│   ├── README.md           # Backend overview
│   └── docs/               # Backend-specific documentation
│       ├── index.md        # Backend documentation hub
│       ├── api.md          # API reference
│       ├── architecture.md # Backend architecture
│       ├── database.md     # Database details
│       └── setup.md        # Backend setup
├── frontend/               # Frontend service
│   ├── README.md           # Frontend overview
│   └── docs/               # Frontend-specific documentation
│       ├── index.md        # Frontend documentation hub
│       ├── architecture.md # Frontend architecture
│       ├── client-side.md  # JavaScript implementation
│       ├── proxy-middleware.md # Backend communication
│       └── setup.md        # Frontend setup
└── docs/                   # Project-wide documentation
    ├── index.md            # This documentation hub
    ├── Getting-Started.md  # Quick start guide
    ├── database_schema.md  # Database structure
    ├── api_documentation.md # API overview
    ├── user_guide.md       # User instructions
    ├── devops-docs/        # DevOps implementation documentation
    │   └── DevOps_Checklist.md # DevOps implementation checklist
    ├── architecture/       # Architecture documentation
    ├── devops/             # DevOps documentation
    ├── operations/         # Operations documentation
    └── development/        # Development guides
```

## Contributing to Documentation
We welcome contributions to improve this documentation. Please follow our contribution guidelines when submitting changes. 