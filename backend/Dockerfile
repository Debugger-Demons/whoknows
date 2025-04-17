# backend/Dockerfile
# ---- Stage 1: Builder ----
FROM rust:1.81 AS builder

# Define build arguments with values from .env files
ARG APP_NAME
ARG RUST_LOG
ARG COMPOSE_PROJECT_NAME

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
    && rm -f target/release/deps/*

# Copy source and build
COPY src ./src
RUN cargo build --release

# ---- Stage 2: Runtime ----


# Production stage: minimal runtime image
FROM debian:bookworm-slim AS production

# Accept runtime args without defaults
ARG BACKEND_INTERNAL_PORT
ARG RUST_LOG
ARG COMPOSE_PROJECT_NAME

# Set runtime environment
ENV BACKEND_INTERNAL_PORT=${BACKEND_INTERNAL_PORT}
ENV RUST_LOG=${RUST_LOG}
ENV COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create data directory
RUN mkdir -p /app/data


# 'backend' -- the binary created and named by Cargo.toml - this is the default name
## ./Cargo.toml
# [package]
# name = "backend"  <-----
COPY --from=builder /app/target/release/backend .

RUN chmod +x ./backend

EXPOSE ${BACKEND_INTERNAL_PORT}

CMD ["./backend"]