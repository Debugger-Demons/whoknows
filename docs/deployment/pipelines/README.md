# CD Pipeline Guide

A concise overview of how the three Continuous Deployment pipelines work and how to keep them isolated on the same host.

---

## 1. TL;DR

* Three pipelines: **Production**, **Development**, **Branch-Test**.
* Isolation relies on five key elements:
  1. Unique secret-backed `.env` files.
  2. Dedicated deployment directories on server. (e.g. `~/deployment/whoknows-dev/`)
  3. Distinct `COMPOSE_PROJECT_NAME` values.
  4. Environment-specific Docker image tags.
  5. A matching `docker-compose.yml` per environment.
* Branch-Test currently re-uses Development settings and overwrites its resources. Give it its own secret, directory, project name and compose file.

---

## 2. At-a-Glance Matrix

| Pipeline    | Trigger            | Secret                 | Server dir                    | Runner `.env`      | `COMPOSE_PROJECT_NAME` | Frontend port    | DB file   | Compose file                     |
| ----------- | ------------------ | ---------------------- | ----------------------------- | ------------------ | ---------------------- | ---------------- | --------- | -------------------------------- |
| Prod        | PR → `main`        | `PROD_ENV_FILE`        | `~/deployment/whoknows/`      | `.env.production`  | `whoknows_prod`        | 8080 (via nginx) | `prod.db` | `docker-compose.prod.yml`        |
| Dev         | PR → `development` | `DEV_ENV_FILE`         | `~/deployment/whoknows-dev/`  | `.env.development` | `whoknows_dev`         | 8081             | `dev.db`  | `docker-compose.dev.yml`         |
| Branch-Test | Push → any branch  | `BRANCH_TEST_ENV_FILE` | `~/deployment/whoknows-test/` | `.env.branch-test` | `whoknows_test`        | 8082             | `test.db` | `docker-compose.branch-test.yml` |

---

## 3. Quick Fix Checklist for Branch-Test

1. Create **`BRANCH_TEST_ENV_FILE`** secret containing its own `.env` content.
2. In `cd.branch-test.yml`:
   * Write the secret to `.env.branch-test` on the runner.
   * Set `DEPLOY_DIR` to `~/deployment/whoknows-test/`.
   * Build & push images tagged `*-test-*` (single namespace).
3. Copy or generate the correct compose file inside the test directory.
4. Ensure `COMPOSE_PROJECT_NAME` is `whoknows_test` (or a slugged variant).
5. Confirm the frontend uses **8082** and the database path is unique.

---

## 4. Deep Dive

### 4.1 `COMPOSE_PROJECT_NAME`
Defines the namespace for every container, network and volume created by Docker Compose. Setting it uniquely per environment is the primary guard against cross-talk.

### 4.2 `.env` Flow
1. Workflow reads the secret and writes a local `.env.*` file.
2. File is copied to the server and renamed to `.env` inside the environment's deployment directory.
3. `deploy.sh` sources this `.env` before running Docker Compose commands.

### 4.3 Deployment Directory Layout
Each workflow operates exclusively in its directory (e.g. `~/deployment/whoknows-dev/`). Scripts never leave this path, guaranteeing file and compose isolation.

### 4.4 Image Tagging Strategy
* **Prod:** `*-prod-<sha>`, `*-prod-latest`.
* **Dev:** `*-dev-<sha>`, `*-dev-latest`.
* **Branch-Test:** `*-test-<sha>`, `*-test-latest`.

### 4.5 `deploy.sh` Reminders
* Always include `--env-file .env` in Docker Compose commands.
* Functions that locate running containers must use `COMPOSE_PROJECT_NAME`, not hard-coded names.

---

## 5. Reference Commands

```bash
# Example: run deployment script for Dev on the server
cd ~/deployment/whoknows-dev
./deploy.sh
```

---

## 6. Further Reading

* `.github/workflows/cd.prod.yml`
* `.github/workflows/cd.dev.yml`
* `.github/workflows/cd.branch-test.yml`
* `deployment/scripts/deploy.sh`

> Decision: one shared **test** namespace keeps the workflow simple. `latest` may be overwritten by concurrent branches, but every push still gets an immutable `<sha>` tag for rollback. 