# Builder stage
FROM rust:slim as builder
WORKDIR /app
# Copy dependencies first (for better caching)
COPY ./src/Rust_Actix/backend/Cargo.toml ./src/Rust_Actix/backend/Cargo.lock ./src/Rust_Actix/backend/
# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*
# Build dependencies
RUN cd ./src/Rust_Actix/backend && \
    mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src
# Copy actual source code
COPY ./src/Rust_Actix/backend/src ./src/Rust_Actix/backend/src/
# Build the application
RUN cd ./src/Rust_Actix/backend && cargo build --release

# Runtime stage
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
# Setup working directory
WORKDIR /app
# Copy the built application from the builder stage
COPY --from=builder /app/src/Rust_Actix/backend/target/release/backend /app/backend
# Make the binary executable
RUN chmod +x /app/backend
# Create a log directory
RUN mkdir -p /app/logs
EXPOSE 8080
# Set the main command to run your application
CMD ["/app/backend"]
