# WhoKnows Documentation

## Introduction
Welcome to the WhoKnows project documentation. This documentation covers all aspects of the WhoKnows search engine, from architecture to development guides.

## Core Documentation

### System Overview
- [Project Overview](../README.md) - Main project description and goals
- [Modern System](../README.rust.md) - Overview of the modern Rust implementation
- [Getting Started](./Getting-Started.md) - Quick start guide for new developers

### Component Documentation

#### Backend
- [Backend Overview](../backend/README.md) - Backend service introduction
- [Backend Documentation](../backend/docs/index.md) - Detailed backend documentation
  - [API Reference](../backend/docs/api.md) - API endpoints and usage
  - [Architecture](../backend/docs/architecture.md) - Backend system design
  - [Database](../backend/docs/database.md) - Database schema and access patterns
  - [Setup Guide](../backend/docs/setup.md) - Backend setup instructions

#### Frontend
- [Frontend Overview](../frontend/README.md) - Frontend service introduction
- [Frontend Documentation](../frontend/docs/index.md) - Detailed frontend documentation
  - [Architecture](../frontend/docs/architecture.md) - Frontend system design
  - [Client-Side](../frontend/docs/client-side.md) - JavaScript, HTML, and CSS details
  - [Proxy Middleware](../frontend/docs/proxy-middleware.md) - Backend communication layer
  - [Setup Guide](../frontend/docs/setup.md) - Frontend setup instructions

### Development Guides
- [Contribution Guidelines](./development/contributing.md) - How to contribute to the project
- [Git Workflow](./VCS/VCS-Git-flow.md) - Version control workflow
- [Development Setup](./development/setup.md) - Full development environment setup

### Operations
- [Deployment Guide](./operations/deployment.md) - How to deploy the application
- [Monitoring Setup](./devops-docs/monitoring/setup.md) - Monitoring configuration
- [Troubleshooting](./operations/troubleshooting.md) - Common issues and solutions

## Documentation Structure

```
/
├── README.md                # Project overview
├── README.rust.md           # Modern system documentation
├── docs/                    # Project-wide documentation
│   ├── index.md             # This documentation hub
│   ├── Getting-Started.md   # Quick start guide
│   ├── architecture/        # System architecture
│   ├── development/         # Development guides
│   ├── operations/          # Deployment & operations
│   └── ...                  # Other documentation categories
├── backend/                 # Backend service
│   ├── README.md            # Backend overview
│   └── docs/                # Backend-specific documentation
└── frontend/                # Frontend service
    ├── README.md            # Frontend overview
    └── docs/                # Frontend-specific documentation
```

## Contributing to Documentation
We welcome contributions to improve this documentation. Please follow our [contribution guidelines](./development/contributing.md) when submitting changes. 