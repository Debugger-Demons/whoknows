# Builder stage
FROM rust:slim as builder
WORKDIR /app

# Copy dependencies info first for better layer caching
COPY ./src/Rust_Actix/backend/Cargo.toml ./src/Rust_Actix/backend/Cargo.lock ./src/Rust_Actix/backend/

# Build dependencies
RUN cd ./src/Rust_Actix/backend && \
    mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# Copy the actual source code
COPY ./src/Rust_Actix/backend/src ./src/Rust_Actix/backend/src/

# Build the application
RUN cd ./src/Rust_Actix/backend && cargo build --release

# Runtime stage
FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/src/Rust_Actix/backend/target/release/backend /app/

# Make the binary executable
RUN chmod +x /app/backend

# Health check to verify the application is running properly
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Create a non-root user to run the application
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

# Modify the CMD to be more verbose and capture logs
CMD ["/bin/bash", "-c", "/app/backend || (echo 'Application failed to start with exit code $?' && cat /tmp/app.log && exit 1)"]
