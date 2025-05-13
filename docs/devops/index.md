# DevOps Documentation

## Overview

This section documents the streamlined DevOps practices and tools used in the WhoKnows project. The documentation focuses on the essential components needed to develop, test, and deploy our simple application with:
- User functionality: login, register, logout
- Core feature: search

## Implementation Status

For a detailed week-by-week implementation status, see the [DevOps Implementation Checklist](../devops-docs/DevOps_Checklist.md).

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

| GitHub Actions | CI/CD | [GitHub Actions](github-actions.md) |
| Docker | Containerization | [Docker Documentation](./docker/docker.md) |
| Monitoring | | [Monitoring documentation](./monitoring/setup.md) |
| SQLite | Database | [SQLite Documentation](https://www.sqlite.org/docs.html) |
| Git | Version control | [Git Documentation](https://git-scm.com/doc) |
| Rust | Backend & Frontend | [Rust Documentation](https://www.rust-lang.org/learn) |

## Getting Started with DevOps

If you're new to the DevOps aspects of this project, start with the following:

1. Set up [pre-commit hooks](../precommitsetup.md)
2. Review the [GitHub Actions workflows](github-actions.md)
3. Learn how to [build and run with Docker](docker.md) 