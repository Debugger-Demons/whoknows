# backend/Dockerfile for Rust Actix Web Backend
# ---- Stage 1: Builder ----
    FROM rust:1.81 AS builder

    # Define build arguments with defaults from .env files
    ARG APP_NAME=whoknows_rust_actix_backend
    ARG RUST_LOG=info
    ARG COMPOSE_PROJECT_NAME=whoknows
    
    # Install build dependencies
    RUN apt-get update && apt-get install -y --no-install-recommends libssl-dev pkg-config \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
    
    WORKDIR /app
    
    # Copy manifests (Cargo.toml and Cargo.lock) - for better caching
    COPY Cargo.toml ./
    COPY Cargo.lock* ./
    RUN if [ ! -f Cargo.lock ]; then cargo generate-lockfile; fi
    
    # Build dependencies
    RUN mkdir src \
        && echo 'fn main() {println!("Building dependencies...")}' > src/main.rs \
        && cargo build --release \
        && rm -rf src \
        && rm -f target/release/deps/${APP_NAME}*
    
    # Copy the actual source code
    COPY src ./src
    
    # Build the application
    RUN cargo build --release
    
    # --------------------------
    # ---- Stage 2: Runtime ----
    FROM debian:bookworm-slim
    
    # Runtime arguments with defaults
    ARG BACKEND_INTERNAL_PORT=8080
    ARG RUST_LOG=info
    ARG COMPOSE_PROJECT_NAME=whoknows
    
    # Set environment variables for runtime
    ENV BACKEND_INTERNAL_PORT=${BACKEND_INTERNAL_PORT}
    ENV RUST_LOG=${RUST_LOG}
    ENV COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
    
    RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
    
    WORKDIR /app
    
    # 'backend' -- the binary created and named by Cargo.toml - this is the default name
    ## ./Cargo.toml
    # [package]
    # name = "backend"  <-----
    COPY --from=builder /app/target/release/backend .
    
    RUN chmod +x ./backend
    
    EXPOSE ${BACKEND_INTERNAL_PORT}
    
    # Start the application
    CMD ["./backend"]