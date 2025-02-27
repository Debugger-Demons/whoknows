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

# Runtime stage - using Ubuntu as in your original file
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    pkg-config \
    gcc \
    libssl-dev \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Setup working directory
WORKDIR /whoknows

# Copy the built application from the builder stage
COPY --from=builder /app/src/Rust_Actix/backend/target/release/backend /whoknows/backend

RUN chmod +x /app/backend

EXPOSE 8080

# Simple direct execution of the binary
CMD ["/app/backend"]
