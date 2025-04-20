# backend/Dockerfile
# ---- Stage 1: Builder ----
FROM rust:1.81 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends libssl-dev pkg-config

WORKDIR /app

# Copy manifests (Cargo.toml and Cargo.lock) - for better caching
COPY Cargo.toml ./
COPY Cargo.lock ./
RUN if [ ! -f Cargo.lock ]; then cargo generate-lockfile; fi

# Build dependencies
# RUN mkdir src

# Copy source and build
COPY src ./src
COPY .sqlx ./.sqlx

RUN cargo build

# ---- Stage 2: Runtime ----
# Production stage: minimal runtime image
FROM debian:bookworm-slim AS production

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create data directory
# RUN mkdir -p /app/data

COPY --from=builder /app/target/release/backend .
RUN if [ ! -f Cargo.lock ]; then cargo generate-lockfile; fi


RUN chmod +x ./backend

EXPOSE ${BACKEND_INTERNAL_PORT}

CMD ["./backend"]