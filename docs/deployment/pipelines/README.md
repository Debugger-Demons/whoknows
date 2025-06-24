# CD Pipeline Differentiation Overview

This document outlines the key differences and desired configurations for the Continuous Deployment (CD) pipelines.

## Current State of CD Pipelines

The table below reflects the **current configuration based on the actual workflow files as of the last review**. 
It highlights how Production, Development, and Branch-Test pipelines are set up, including areas of overlap and potential conflict.

| Feature                                                    | Production Pipeline (`cd.prod.yml`)                                                      | Development Pipeline (`cd.dev.yml`)                                                     | Branch-Test Pipeline (`cd.branch-test.yml`) - DANGER: CURRENTLY OVERWRITES DEV ENVIRONNMENT! | Needs Update for Isolation? |
| :--------------------------------------------------------- | :--------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------- | :-------------------------- |
| **Triggering Event**                                       | *PR Merged* to `main` branch                                                             | *PR Merged* to `development` branch                                                     | *Push* to `<feat-branch>`                                                                    |                             |
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


| Feature                                              | Production Pipeline (`cd.prod.yml`)                                 | Development Pipeline (`cd.dev.yml`)                                 | Branch-Test Pipeline (`cd.branch-test.yml`)                                                               |
| :--------------------------------------------------- | :------------------------------------------------------------------ | :------------------------------------------------------------------ | :-------------------------------------------------------------------------------------------------------- |
| **Triggering Event**                                 | *PR Merged* to `main` branch                                        | *PR Merged* to `development` branch                                 | *Push* to `<feat-branch>`                                                                                 |
| **Base .env File Source (Secret Name)**              | `secrets.PROD_ENV_FILE`                                             | `secrets.DEV_ENV_FILE`                                              | `secrets.BRANCH_TEST_ENV_FILE`                                                                            |
| **Effective .env on Runner (Filename)**              | `.env.production` (Workflow copies `PROD_ENV_FILE` content to this) | `.env.development` (Workflow copies `DEV_ENV_FILE` content to this) | `.env.branch-test` (Workflow copies `BRANCH_TEST_ENV_FILE` content to this)                               |
| **VM Deployment Directory (`env.DEPLOY_DIR`)**       | `./deployment/whoknows/`                                            | `./deployment/whoknows-dev/`                                        | `./deployment/whoknows-test/`                                                                             |
| **`COMPOSE_PROJECT_NAME` (in respective .env file)** | `whoknows_prod`                                                     | `whoknows_dev`                                                      | `whoknows_test`                                                                                           |
| **Docker Image Tagging (by Workflow)**               | `img_base/svc:prod-<sha>` <br/> `img_base/svc:prod-latest`          | `img_base/svc:dev-<sha>` <br/> `img_base/svc:dev-latest`            | `img_base/svc:test-${branch_slug}-<sha>` <br/> `img_base/svc:test-${branch_slug}-latest`                  |
| **`HOST_PORT_FRONTEND` (in respective .env file)**   | `8080` (Internal, Nginx proxies from 80/443)                        | `8081`                                                              | `8082`                                                                                                    |
| **`DATABASE_URL` (in respective .env file)**         | `sqlite:/app/data/prod.db`                                          | `sqlite:/app/data/dev.db`                                           | `sqlite:/app/data/test.db`                                                                                |
| **`docker-compose` file (Source in repo)**           | `./docker-compose.prod.yml`                                         | `./docker-compose.dev.yml`                                          | `./docker-compose.branch-test.yml` (Recommended: or copy `dev.yml` and adapt if only .env changes needed) |
| **Server Reverse Proxy/Gateway Config**              | Manages `nginx.conf` (e.g., for prod, copied to server)             | Not explicitly managed by workflow.                                 | Not explicitly managed by workflow.                                                                       |

## `COMPOSE_PROJECT_NAME` for Environment Isolation

The `COMPOSE_PROJECT_NAME` environment variable is a cornerstone of maintaining isolated deployment environments (Production, Development, Branch-Test) on a shared server. Its correct definition and consistent use throughout the CI/CD and deployment process prevent resource conflicts.

### 1. Definition and Source

The value for `COMPOSE_PROJECT_NAME` is unique for each environment and is defined within the content of environment-specific files, which are stored as GitHub Secrets:

*   **Production:** The content of `secrets.PROD_ENV_FILE` includes a line like `COMPOSE_PROJECT_NAME=whoknows_prod`.
*   **Development:** The content of `secrets.DEV_ENV_FILE` includes a line like `COMPOSE_PROJECT_NAME=whoknows_dev`.
*   **Branch-Test:** The content of `secrets.BRANCH_TEST_ENV_FILE` includes a line like `COMPOSE_PROJECT_NAME=whoknows_test` (or a dynamically generated name like `whoknows_test_${branch_slug}` if implemented).

### 2. Workflow Processing and `.env` File Creation

Each CI/CD workflow (`cd.prod.yml`, `cd.dev.yml`, `cd.branch-test.yml`) is responsible for handling its respective environment configuration:

1.  **Secret Retrieval:** The workflow fetches the content of the relevant secret (e.g., `ENV_FILE_CONTENT: ${{ secrets.PROD_ENV_FILE }}`).
2.  **Local `.env` Creation (Runner):** This content is written to a temporary environment file on the GitHub Actions runner (e.g., `.env.production` for the production workflow, `.env.development` for development, and `.env.branch-test` for branch testing).
3.  **Transfer to Server:** This runner-specific file (e.g., `.env.production`) is then transferred via `scp` to the designated deployment directory for that environment on the target server (e.g., `~/deployment/whoknows/` for production, `~/deployment/whoknows-dev/` for development, `~/deployment/whoknows-test/` for branch-test).
4.  **Final `.env` on Server:** Upon arrival on the server, this file is named simply `.env` within its environment-specific deployment directory. This `.env` file now contains the correct `COMPOSE_PROJECT_NAME` for that environment.

### 3. Role in Docker Compose for Resource Isolation

When the `deploy.sh` script executes Docker Compose commands (e.g., `docker compose --env-file .env up -d`), Docker Compose automatically reads and utilizes the `COMPOSE_PROJECT_NAME` variable from the `.env` file located in the current deployment directory.

This variable is critical because Docker Compose uses it to prefix:

*   **Containers:** Ensures container names are unique per environment (e.g., `whoknows_prod-backend-1`, `whoknows_dev-frontend-1`).
*   **Networks:** Creates isolated networks for each environment (e.g., `whoknows_prod_default_network`, `whoknows_dev_app_net`).
*   **Volumes:** Manages named volumes specific to each environment (e.g., `whoknows_prod_database_volume`, `whoknows_dev_static_files`).

This prefixing mechanism is the primary way Docker Compose achieves resource isolation, allowing multiple instances of the application (prod, dev, test) to coexist on the same host without interfering with each other.

### 4. Utilization in `deploy.sh`

The `deploy.sh` script leverages `COMPOSE_PROJECT_NAME` as follows:

1.  **Loading Environment:** The script sources the `.env` file (e.g., `source .env`), making `COMPOSE_PROJECT_NAME` available as a shell variable.
2.  **Docker Compose Commands:** All `docker compose --env-file .env ...` commands implicitly use the `COMPOSE_PROJECT_NAME` from the loaded `.env` file to target the correct set of containers, networks, and volumes for the intended environment.
3.  **Rollback and Logging (Important Note):**
    *   The `prepare_rollback` and `log_success_confirmation` functions within `deploy.sh` are responsible for identifying currently running containers to save their image tags for potential rollback and for logging purposes.
    *   **Current Implementation Detail:** As of the last review, these functions in `deploy.sh` might use a hardcoded logic (e.g., assuming a `_dev` suffix like `${COMPOSE_PROJECT_NAME}_backend_dev`) which may not correctly identify containers across all environments (production, development, branch-test).
    *   **Required Refinement:** For robust operation, these functions **must be updated** to dynamically and accurately determine container names. This typically involves using the `${COMPOSE_PROJECT_NAME}` variable combined with the service names defined in the `docker-compose.yml` file (e.g., `backend`, `frontend`). Docker Compose usually names containers like `${COMPOSE_PROJECT_NAME}-<service_name>-1` or `${COMPOSE_PROJECT_NAME}_<service_name>_1`. Commands like `docker compose ps -q <service_name>` can be used to reliably get container IDs for further inspection.

By ensuring `COMPOSE_PROJECT_NAME` is correctly set and utilized, particularly in the `deploy.sh` script's container identification logic, true environment isolation is achieved.

## Other Key Differentiation Components for `deploy.sh` Isolation

Beyond `COMPOSE_PROJECT_NAME`, the following components are crucial for ensuring the `deploy.sh` script operates in complete isolation for each environment (Production, Development, Branch-Test).

### 1. Dedicated VM Deployment Directory

*   **How it works:** Each CI/CD workflow (`cd.prod.yml`, `cd.dev.yml`, `cd.branch-test.yml`) copies all necessary deployment files (the environment-specific `.env`, the correct `docker-compose.yml`, `deploy.sh` itself, and the `VERSION` file) to a unique directory on the deployment server.
    *   Production: e.g., `~/deployment/whoknows/`
    *   Development: e.g., `~/deployment/whoknows-dev/`
    *   Branch-Test: e.g., `~/deployment/whoknows-test/`
*   **Isolation Impact:** The `deploy.sh` script executes entirely within its current working directory (e.g., `cd ~/deployment/whoknows-dev/ && ./deploy.sh`). All its file operations (reading `.env`, finding `docker-compose.yml`) and Docker Compose commands are inherently scoped to this directory, preventing any interaction with other environments' files or processes.

### 2. Isolated Environment Configuration File (`.env`)

*   **How it works:** Each workflow places an `.env` file within the dedicated deployment directory. This file is sourced from environment-specific GitHub Secrets (e.g., `secrets.DEV_ENV_FILE` for development).
*   **Content:** This `.env` file contains all critical environment-specific variables needed by `deploy.sh` and `docker-compose`, such as:
    *   `COMPOSE_PROJECT_NAME` (as detailed previously).
    *   `IMAGE_TAG_BACKEND` and `IMAGE_TAG_FRONTEND` (pointing to the unique Docker image versions for this environment).
    *   `HOST_PORT_FRONTEND` (defining the unique port for this environment's frontend).
    *   `DATABASE_URL` (pointing to the isolated database for this environment).
*   **Isolation Impact:** When `deploy.sh` sources this `.env` file, it configures its operations (like which images to pull via `docker compose pull` or which health endpoint to check) specifically for the intended environment, ensuring it doesn't use settings from another.

### 3. Unique Docker Image Tags/Names

*   **How it works:** Each environment's CI/CD pipeline builds and pushes Docker images to the container registry (GHCR) using unique tags or names.
    *   Production: e.g., `ghcr.io/owner/repo/backend:prod-<sha>`, `ghcr.io/owner/repo/frontend:prod-latest`
    *   Development: e.g., `ghcr.io/owner/repo/backend:dev-<sha>`, `ghcr.io/owner/repo/frontend:dev-latest`
    *   Branch-Test: e.g., `ghcr.io/owner/repo/backend-test:<branch_slug>-<sha>`, `ghcr.io/owner/repo/frontend-test:<branch_slug>-latest`
*   **Isolation Impact:** The `IMAGE_TAG_BACKEND` and `IMAGE_TAG_FRONTEND` variables in each environment's `.env` file specify these unique image identifiers. `deploy.sh` uses these to instruct `docker compose` to pull and run only the images built for that specific environment. This prevents accidental deployment of, for instance, a development image into the production environment.

### 4. Environment-Specific `docker-compose.yml`

*   **How it works:** Each CI/CD workflow ensures the correct `docker-compose.yml` file is present in the environment's dedicated deployment directory on the server (named simply `docker-compose.yml` there).
    *   This can be achieved by copying a distinctly named file from the repository (e.g., `docker-compose.prod.yml` becomes `docker-compose.yml` in the prod deployment dir).
    *   Alternatively, for environments with minimal structural differences (like branch-test vs. dev), a base file (e.g., `docker-compose.dev.yml`) might be copied and then primarily differentiated by the variables in its `.env` file.
*   **Isolation Impact:** The `deploy.sh` script invokes `docker compose --env-file .env up ...`. Docker Compose reads the `docker-compose.yml` from the current directory. This file defines the service names, how they link, default port mappings (which can be overridden by the `.env`), and volume definitions. Ensuring it's the correct one for the environment is vital for the structural integrity of that deployment. For example, the production `docker-compose.yml` might have different resource limits or logging configurations than the development one.

These components, working together, ensure that the `deploy.sh` script, when executed within a specific environment's deployment directory, manages only that environment's lifecycle without impacting others.


The 'Internal Workflow Differentiation for `cd.branch-test.yml`' section further below describes the *target state modifications* needed for the Branch-Test pipeline to achieve full isolation and prevent it from overwriting other environments.

## Internal Workflow Differentiation for `cd.branch-test.yml`

To ensure the `branch-test` pipeline doesn't interfere with the development environment (or production), it differentiates itself as follows:

1.  **Dedicated VM Deployment Directory:**
    *   The workflow's `env.DEPLOY_DIR` variable will be set to a unique path for branch testing, e.g., `~/deployment/whoknows-test/`. All files (`docker-compose.yml`, `.env`, `VERSION`) will be copied here.

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
    *   Image tags will be constructed like: `your_registry/your_repo/backend-test:{{ github.sha }}` and `your_registry/your_repo/backend-test:${branch_slug}-latest`.

4.  **Docker Compose File Selection (`docker-compose.branch-test.yml` or adapted `docker-compose.dev.yml`):
    *   Ideally, create a `docker-compose.branch-test.yml` if specific service adjustments are needed for testing beyond what `.env` can control.
    *   If changes are minimal and controllable via the `.env.branch-test` file, the workflow could copy `docker-compose.dev.yml` to the server as `docker-compose.yml` within the test deployment directory. The `.env.branch-test` file (which becomes `.env` there) would then provide the necessary overrides for image tags, project name, and ports.

This comprehensive approach ensures that running the `branch-test` pipeline results in a fully isolated and independently configurable environment on the deployment server.
