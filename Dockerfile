# Builder stage
FROM rust:slim as builder
WORKDIR /app

# Copy dependencies 
COPY ./src/Rust_Actix/backend/Cargo.toml ./src/Rust_Actix/backend/Cargo.lock ./src/Rust_Actix/backend/

# Build dependencies
RUN cd ./src/Rust_Actix/backend && \
    mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

COPY ./src/Rust_Actix/backend/src ./src/Rust_Actix/backend/src/

# Build the application
RUN cd ./src/Rust_Actix/backend && cargo build --release

# Runtime stage - using Ubuntu 
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Install only the packages needed for runtime
RUN apt-get update && apt-get install -y \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Setup working directory
WORKDIR /app

# Copy the built application from the builder stage
COPY --from=builder /app/src/Rust_Actix/backend/target/release/backend /app/backend

# Make the binary executable
RUN chmod +x /app/backend

EXPOSE 8080

# Simple direct execution of the binary
CMD ["/app/backend"]
