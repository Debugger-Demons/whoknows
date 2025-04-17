 # Dockerfile Multi-Stage Setup for “Who Knows” Frontend

 This document explains the multi-stage Dockerfile configuration used in the “Who Knows Frontend” project,
 enabling both a minimal production image and a containerized development workflow with hot-reloading.

- [1. Stages](#1-stages)
  - [builder](#builder)
  - [dev](#dev)
  - [production](#production)
- [2. Building and Running](#2-building-and-running)
    - [Production image](#production-image)
    - [Development image](#development-image)
- [3. Docker Compose Example](#3-docker-compose-example)
- [4. Benefits](#4-benefits)

 ## 1. Stages

 ### builder
 - Base image: `rust:1.81-slim`
 - Purpose: compile a release binary with cached dependencies
 - Steps:
   1. Copy `Cargo.toml` & `Cargo.lock`
   2. Build dummy `src/main.rs` (to cache deps)
   3. Copy real `src/` and rebuild in `--release` mode

 ### dev
 - Base image: `rust:1.81-slim`
 - Purpose: local development with hot-reloading inside Docker
 - Steps:
   1. Install native deps (`pkg-config`, `libssl-dev`)
   2. Copy entire repo (source, `static/`, configs)
   3. Install dev tooling: `cargo-watch`, `dotenv-cli`, `cargo-make`
 - Default `CMD`: `cargo make dev` (runs hot-reload server using environment vars)

 ### production
 - Base image: `debian:bookworm-slim`
 - Purpose: minimal runtime for deployment
 - Steps:
   1. Install `ca-certificates`
   2. Copy release binary from `builder`
   3. Copy `static/` assets
   4. Expose port `8080`
 - Default `CMD`: `./frontend` (runs the compiled binary)

 ## 2. Building and Running

 ### Production image
```bash
docker build -t whoknows-frontend .
docker run -d -p 8080:8080 whoknows-frontend
```

### Development image
```bash
docker build --target dev -t whoknows-frontend-dev .
docker run --rm -it \
  -p 8080:8080 \
  -v "$(pwd)":/usr/src/app \
  whoknows-frontend-dev
```
Inside the dev container, file changes trigger a hot-rebuild and restart of the server via `cargo-watch`.

 ## 3. Docker Compose Example

 In your `docker-compose.yml`, reference the default (production) image:
```yaml
services:
  frontend:
    build: .
    ports:
      - "8080:8080"
    environment:
      BACKEND_URL: http://backend:8080
```

 ## 4. Benefits
 - Single Dockerfile for both dev & prod workflows
 - Fast feedback loop with hot-reload in containerized dev
 - Lean production image containing only the release binary and static assets
