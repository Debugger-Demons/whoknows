# Makefile Commands

This document explains the available Makefile commands for managing GitHub secrets and pull requests.

## Prerequisites

- [GitHub CLI](https://cli.github.com/) installed and authenticated
- Proper environment files (`.env.development` and `.env.production`) in project root
- Make installed on your system

## Available Commands

### `make update-env-secrets`

Updates GitHub repository secrets with the contents of your environment files:

- Updates `DEV_ENV_FILE` with the contents of `.env.development`
- Updates `PROD_ENV_FILE` with the contents of `.env.production`

### `make pr-create`

Updates environment secrets and creates a pull request in one step.

### `make help`

Displays available commands with descriptions.

## Installation Guide

### Installing Make

**_Windows:_**

```bash
# Using Chocolatey
choco install make

# Using Scoop
scoop install make
```

**_MacOS_**

```bash
# MacOS
brew install make
```
