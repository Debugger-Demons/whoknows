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
FROM debian:slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/src/Rust_Actix/backend/target/release/backend /app/

EXPOSE 8080
CMD ["/app/backend"]
