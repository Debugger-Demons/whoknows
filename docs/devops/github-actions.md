# GitHub Actions

## Overview

GitHub Actions automate our CI/CD pipeline for the WhoKnows project. This document outlines the workflows we use and how to work with them.

## Main Workflows

### CI Workflow

This workflow runs on every pull request and push to the main branch.

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          override: true
      - name: Build
        run: cargo build --verbose
      - name: Run tests
        run: cargo test --verbose
      - name: Lint
        run: cargo clippy -- -D warnings
```

### Deploy Workflow

This workflow deploys the application when changes are pushed to the main branch.

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          override: true
      - name: Build
        run: cargo build --release
      - name: Deploy
        run: ./scripts/deploy.sh
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

## Setting Up Secrets

To set up the required secrets for workflows:

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Add the following secrets:
   - `DEPLOY_TOKEN`: Token for deployment

## Running Workflows Locally

You can test GitHub Actions workflows locally using [act](https://github.com/nektos/act):

```bash
# Install act
brew install act  # macOS
# or download from https://github.com/nektos/act/releases

# Run the CI workflow
act -j test

# Run with secrets for deployment
act -j deploy -s DEPLOY_TOKEN=your_token_here
```

## Extending Workflows

To add a new workflow:

1. Create a new YAML file in `.github/workflows/`
2. Define the workflow following GitHub Actions syntax
3. Commit and push the file to the repository

## Troubleshooting

If a workflow fails, check:

1. The workflow run in GitHub Actions tab for detailed logs
2. Verify all required secrets are set correctly
3. Ensure any external services or APIs are accessible from the workflow 