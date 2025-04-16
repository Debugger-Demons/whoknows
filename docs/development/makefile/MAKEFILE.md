# Makefile Commands

This document explains the available Makefile commands for managing GitHub secrets, pull requests, and issue creation.

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

### GitHub Issue Creation Commands

You can create GitHub issues directly from the Makefile using the following commands.
These commands require appropriate variables to be passed:

- `t` for title description
- `f` for body file (path to markdown file)
- `LABEL` for issue label

#### Main Issue Command

- `make i-create`  
  Validates inputs and creates an issue in the configured repository and project.

#### Shortcut Targets for Common Issue Labels

- `make i-create-enhancement`  
  Creates an issue with label "enhancement".
- `make i-create-bug`  
  Creates an issue with label "bug".
- `make i-create-dependencies`  
  Creates an issue with label "dependencies".
- `make i-create-documentation`  
  Creates an issue with label "documentation".

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

**_MacOS:_**

```bash
# Using Homebrew
brew install make
```
