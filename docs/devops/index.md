# DevOps Documentation

## Overview

This section documents the DevOps practices and tools used in the WhoKnows project. The documentation is designed to be straightforward and focused on the essential components needed to develop, test, and deploy the application.

## CI/CD Pipeline

- **GitHub Actions**: Automated workflows for testing and deployment
- **Pre-commit Hooks**: Local code quality checks

## Development Environment

- **Docker**: Container-based development environment
- **SQLite**: Simple database for development

## Deployment

- **Deployment Process**: Steps to deploy the application
- **Environment Setup**: Configuration for different environments

## Monitoring

- **Basic Logging**: Application logging setup
- **Health Checks**: Endpoint monitoring

## Core Tools Reference

| Tool | Purpose | Documentation |
|------|---------|---------------|
| Git | Version control | [Git Documentation](https://git-scm.com/doc) |
| GitHub Actions | CI/CD | [GitHub Actions](github-actions.md) |
| Docker | Containerization | [Docker Documentation](docker.md) |
| SQLite | Database | [SQLite Documentation](https://www.sqlite.org/docs.html) |
| Rust | Backend & Frontend | [Rust Documentation](https://www.rust-lang.org/learn) |

## Getting Started with DevOps

If you're new to the DevOps aspects of this project, start with the following:

1. Set up [pre-commit hooks](../precommitsetup.md)
2. Review the [GitHub Actions workflows](github-actions.md)
3. Learn how to [build and run with Docker](docker.md) 