# WhoKnows Modern Implementation

A modern search engine built with Rust and ActixWeb, modernizing the legacy WhoKnows project from 2009.

## Table of Contents

- [WhoKnows Modern Implementation](#whoknows-modern-implementation)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [Documentation](#documentation)
    - [Centralized Documentation](#centralized-documentation)
    - [Component Documentation](#component-documentation)
    - [Development Guides](#development-guides)
  - [System Architecture](#system-architecture)
  - [Development](#development)
    - [Prerequisites](#prerequisites)
    - [Development Workflow](#development-workflow)
  - [Operations](#operations)
  - [Project Status](#project-status)
  - [License](#license)

## Overview

The modern WhoKnows implementation is a complete rewrite of the original Python-based search engine, employing contemporary technologies, architectural patterns, and development practices. The system consists of a Rust-based backend API and a lightweight frontend, both designed for simplicity, performance, and maintainability.

## Quick Start

To get the system up and running quickly:

1. **Clone the repository**
   ```bash
   git clone https://github.com/Debugger-Demons/whoknows.git
   cd whoknows
   ```

2. **Start with Make cmd**
   ```bash
   make run-compose

   # make help for all available cmds
   ```

3. **Access the application**
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:8080/api

For more detailed setup instructions, see the [Getting Started Guide](docs/Getting-Started.md).

## Documentation

### Centralized Documentation
- [Documentation Hub](docs/index.md) - Central navigation for all documentation

### Component Documentation
- **Backend**
  - [Overview](backend/README.md) - Backend service introduction
  - [API Reference](backend/docs/api.md) - Complete API documentation
  - [Architecture](backend/docs/architecture.md) - Backend system design
  - [Database Schema](backend/docs/database.md) - Data model and access patterns
  - [Setup Guide](backend/docs/setup.md) - Detailed setup instructions

- **Frontend**
  - [Overview](frontend/README.md) - Frontend service introduction
  - [Architecture](frontend/docs/architecture.md) - Frontend system design
  - [Client-Side Documentation](frontend/docs/client-side.md) - UI implementation details
  - [API Integration](frontend/docs/proxy-middleware.md) - Backend communication
  - [Setup Guide](frontend/docs/setup.md) - Frontend setup instructions

### Development Guides
- [Contribution Guidelines](docs/development/contributing.md)
- [Development Environment Setup](docs/development/setup.md)
- [Git Workflow](docs/VCS/VCS-Git-flow.md)

### DevOps Documentation
- [DevOps Implementation Checklist](docs/devops-docs/DevOps_Checklist.md) - Week-by-week DevOps implementation tasks
- [DevOps Index](docs/devops/index.md) - DevOps documentation overview
- [GitHub Actions](docs/devops/github-actions.md) - CI/CD workflows
- [Docker](docs/devops/docker.md) - Docker setup and usage

## System Architecture

The modern WhoKnows system follows a clean, service-oriented architecture:

```
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│  Browser    │◄────►│  Frontend    │◄────►│  Backend     │
│  (Client)   │      │  (Actix Web) │      │  (API)       │
└─────────────┘      └──────────────┘      └──────────────┘
                                                  │
                                                  ▼
                                           ┌──────────────┐
                                           │  Database    │
                                           │  (SQLite)    │
                                           └──────────────┘
```

- **Frontend**: Lightweight Rust Actix service serving static content and proxying API requests
- **Backend**: RESTful API implemented in Rust with Actix Web
- **Database**: SQLite with SQLx for type-safe queries

For detailed architectural documentation:
- [Backend Architecture](backend/docs/architecture.md)
- [Frontend Architecture](frontend/docs/architecture.md)

## Development

### Prerequisites
- Rust 1.81 or later
- Docker & Docker Compose (optional, for containerized development)
- Git

### Development Workflow
1. Fork and clone the repository
2. Set up your development environment using the [Setup Guide](docs/development/setup.md)
3. Create a feature branch following our [Git Workflow](docs/VCS/VCS-Git-flow.md)
4. Implement your changes with tests
5. Submit a pull request for review

## Operations

- [Deployment Guide](docs/operations/deployment.md)
- [Monitoring Setup](docs/devops-docs/monitoring/setup.md)
- [Troubleshooting](docs/operations/troubleshooting.md)

## Project Status

Current status: **In Development**

Current phase:
- DevOps => Phase 2: CI/CD & Cloud Infrastructure
- Rust Backend => Phase 1 & 2: Rust Core and Web & Data

Implementation Progress:
- [DevOps Implementation Checklist](docs/devops-docs/DevOps_Checklist.md) - Track current DevOps implementation status

Roadmap docs:
- [DevOps Roadmap](docs/development/roadmap.DevOps.md)
- [Rust Backend Roadmap](docs/development/roadmap.Rust_Devving.md)
- [Ambitious Rust Learning and Devving Roadmap](docs/development/roadmap.Rust_Devving.ambitious.md)

## License

This project is licensed under the terms included in [LICENSE](LICENSE).
