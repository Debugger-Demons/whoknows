# CD Pipeline Differentiation Overview

This document outlines the key differences and desired configurations for the Continuous Deployment (CD) pipelines.

## Current State of CD Pipelines

The table below reflects the **current configuration based on the actual workflow files as of the last review**. 
It highlights how Production, Development, and Branch-Test pipelines are set up, including areas of overlap and potential conflict.

| Feature                                                    | Production Pipeline (`cd.prod.yml`)                                                      | Development Pipeline (`cd.dev.yml`)                                                     | Branch-Test Pipeline (`cd.branch-test.yml`) - DANGER: CURRENTLY OVERWRITES DEV ENVIRONNMENT! | Needs Update for Isolation? |
| :--------------------------------------------------------- | :--------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------- | :-------------------------- |
| **Triggering Event**                                       | PR Merged to `main` branch                                                               | PR Merged to `development` branch                                                       | Push to designated test branches (e.g., `some-branch`) / Manual (`workflow_dispatch`)        |                             |
| **Base .env File Source (Secret)**                         | `secrets.PROD_ENV_FILE`                                                                  | `secrets.DEV_ENV_FILE`                                                                  | `secrets.DEV_ENV_FILE` (Currently shares with Dev)                                           | X                           |
| **Effective .env on Runner (Filename)**                    | `.env.production`                                                                        | `.env.development`                                                                      | `.env.development` (Currently shares with Dev)                                               | X                           |
| **VM Deployment Directory (`env.DEPLOY_DIR` in workflow)** | `./deployment/whoknows` <br/>**(Shares with Dev & Branch-Test - Overwrites Expected)**   | `./deployment/whoknows` <br/>**(Shares with Prod & Branch-Test - Overwrites Expected)** | `./deployment/whoknows` <br/>**(Shares with Prod & Dev - CRITICAL OVERWRITE OF DEV)**        | X                           |
| **`COMPOSE_PROJECT_NAME` (from .env file)**                | Defined in `PROD_ENV_FILE` content (e.g., `whoknows_prod`)                               | Defined in `DEV_ENV_FILE` content (e.g., `whoknows_dev` or `mywebapp`)                  | Uses `DEV_ENV_FILE` content (Same as Dev - CRITICAL OVERWRITE OF DEV CONTAINERS)             | X                           |
| **Docker Image Tagging Strategy (by Workflow)**            | No distinct suffix (standard naming, e.g., `image:latest`, `image:<sha>`)                | No distinct suffix (standard naming, e.g., `image:latest`, `image:<sha>`)               | No distinct suffix (Same as Dev - CRITICAL OVERWRITE OF DEV `latest` TAGS IN REGISTRY)       | X                           |
| **`HOST_PORT_FRONTEND` (from .env file)**                  | Defined in `PROD_ENV_FILE` content (e.g., 80, 443 via reverse proxy to an internal port) | Defined in `DEV_ENV_FILE` content (e.g., 8080)                                          | Uses `DEV_ENV_FILE` content (Same as Dev - LEADS TO PORT CONFLICTS WITH DEV)                 | X                           |
| **`DATABASE_URL` (from .env file)**                        | Defined in `PROD_ENV_FILE` content (e.g., `sqlite:/app/data/actual_prod.db`)             | Defined in `DEV_ENV_FILE` content (e.g., `sqlite:/app/data/actual_dev.db`)              | Uses `DEV_ENV_FILE` content (Same as Dev - CRITICAL OVERWRITE OF DEV DATABASE)               | X                           |
| **`docker-compose` file (Source in repo)**                 | `./docker-compose.prod.yml`                                                              | `./docker-compose.dev.yml`                                                              | `./docker-compose.dev.yml` (Uses Dev's compose file)                                         | X                           |
| **Server Reverse Proxy/Gateway Config**                    | Copies `frontend/nginx.conf` from repo to server.                                        | Not explicitly managed by workflow (no `nginx.conf` copied by default).                 | Not explicitly managed by workflow (no `nginx.conf` copied by default).                      |                             |

## Desired State for Isolated CD Pipelines

The following table outlines the target configuration to ensure all three pipelines can operate independently and safely on the same server. The `.env.*` files mentioned below are sourced from GitHub Secrets (`secrets.PROD_ENV_FILE`, `secrets.DEV_ENV_FILE`, `secrets.BRANCH_TEST_ENV_FILE`).

| Feature                                              | Production Pipeline (`cd.prod.yml`)                                 | Development Pipeline (`cd.dev.yml`)                                 | Branch-Test Pipeline (`cd.branch-test.yml`)                                                        |
| :--------------------------------------------------- | :------------------------------------------------------------------ | :------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------- |
| **Triggering Event**                                 | PR Merged to `main` branch                                          | PR Merged to `development` branch                                   | Push to any non-main, non-dev branch (e.g., `feature/*`, `fix/*`) / `workflow_dispatch`            |
| **Base .env File Source (Secret Name)**              | `secrets.PROD_ENV_FILE`                                             | `secrets.DEV_ENV_FILE`                                              | `secrets.BRANCH_TEST_ENV_FILE` (New distinct secret)                                               |
| **Effective .env on Runner (Filename)**              | `.env.production` (Workflow copies `PROD_ENV_FILE` content to this) | `.env.development` (Workflow copies `DEV_ENV_FILE` content to this) | `.env.branch-test` (Workflow copies `BRANCH_TEST_ENV_FILE` content to this)                        |
| **VM Deployment Directory (`env.DEPLOY_DIR`)**       | `./deployment/whoknows/`                                            | `./deployment/whoknows-dev/`                                        | `./deployment/whoknows-branch-test/`                                                               |
| **`COMPOSE_PROJECT_NAME` (in respective .env file)** | `whoknows_prod`                                                     | `whoknows_dev`                                                      | `whoknows_test`                                                                                    |
| **Docker Image Tagging (by Workflow)**               | `img_base/svc:prod-<sha>` <br/> `img_base/svc:prod-latest`          | `img_base/svc:dev-<sha>` <br/> `img_base/svc:dev-latest`            | `img_base/svc:test-${branch_slug}-<sha>` <br/> `img_base/svc:test-${branch_slug}-latest`           |
| **`HOST_PORT_FRONTEND` (in respective .env file)**   | `8080` (Internal, Nginx proxies from 80/443)                        | `8081`                                                              | `8082`                                                                                             |
| **`DATABASE_URL` (in respective .env file)**         | `sqlite:/app/data/prod.db`                                          | `sqlite:/app/data/dev.db`                                           | `sqlite:/app/data/test.db`                                                                         |
| **`docker-compose` file (Source in repo)**           | `./docker-compose.prod.yml`                                         | `./docker-compose.dev.yml`                                          | `./docker-compose.test.yml` (Recommended: or copy `dev.yml` and adapt if only .env changes needed) |
| **Server Reverse Proxy/Gateway Config**              | Manages `nginx.conf` (e.g., for prod, copied to server)             | Not explicitly managed by workflow.                                 | Not explicitly managed by workflow.                                                                |

The 'Internal Workflow Differentiation for `cd.branch-test.yml`' section further below describes the *target state modifications* needed for the Branch-Test pipeline to achieve full isolation and prevent it from overwriting other environments.

## Internal Workflow Differentiation for `cd.branch-test.yml`

To ensure the `branch-test` pipeline doesn't interfere with the development environment (or production), it differentiates itself as follows:

1.  **Dedicated VM Deployment Directory:**
    *   The workflow's `env.DEPLOY_DIR` variable will be set to a unique path for branch testing, e.g., `~/deployment/whoknows-branch-test/`. All files (`docker-compose.yml`, `.env`, `VERSION`) will be copied here.

2.  **Separate Environment Configuration (`.env.branch-test` from `secrets.BRANCH_TEST_ENV_FILE`):**
    *   A new GitHub Secret `BRANCH_TEST_ENV_FILE` will store the content for the test environment.
    *   The workflow will write this secret's content to a local `.env.branch-test` file on the runner.
    *   This file must define:
        *   `COMPOSE_PROJECT_NAME=whoknows_test` (Ensures unique Docker container, network, and volume names).
        *   `HOST_PORT_FRONTEND=8082` (Unique port for the test frontend).
        *   `DATABASE_URL=sqlite:/app/data/test.db` (Separate database for testing).
        *   Other necessary variables, like `RUST_LOG=debug`.
    *   The workflow will append the CI/CD-generated `IMAGE_TAG_BACKEND` and `IMAGE_TAG_FRONTEND` (with `test-${branch_slug}-` prefixes) to this `.env.branch-test` file before it's copied to the server as `.env` in the `DEPLOY_DIR`.

3.  **Docker Image Naming Suffix (via Workflow Logic):**
    *   The workflow will dynamically generate a `branch_slug` from the Git branch name (e.g., `feature/login-ux` becomes `feature-login-ux`).
    *   Image tags will be constructed like: `your_registry/your_repo/backend:test-${branch_slug}-${{ github.sha }}` and `your_registry/your_repo/backend:test-${branch_slug}-latest`.

4.  **Docker Compose File Selection (`docker-compose.test.yml` or adapted `docker-compose.dev.yml`):
    *   Ideally, create a `docker-compose.test.yml` if specific service adjustments are needed for testing beyond what `.env` can control.
    *   If changes are minimal and controllable via the `.env.branch-test` file, the workflow could copy `docker-compose.dev.yml` to the server as `docker-compose.yml` within the test deployment directory. The `.env.branch-test` file (which becomes `.env` there) would then provide the necessary overrides for image tags, project name, and ports.

This comprehensive approach ensures that running the `branch-test` pipeline results in a fully isolated and independently configurable environment on the deployment server.
