# Build stage
FROM rust:1.81-slim AS builder

# Copy the binary from the builder stage
## binary flow:
# 1. build stage: 
# - Cargo.toml package name: frontend 
# - cargo build --release
#  -> creates binary in target/release/frontend.exe
# 2. runtime stage:
# - COPY binary to current dir with '.' 
# - CMD ["./frontend"]
#  -> running the binary


# this path is relative to the Dockerfile location
WORKDIR /usr/src/app

COPY Cargo.toml ./
COPY Cargo.lock ./

# Create empty src/main.rs to build dependencies
RUN mkdir -p src && echo "fn main() {}" > src/main.rs
RUN cargo build --release

# Now copy the actual source code and build again
COPY src ./src
RUN touch src/main.rs && cargo build --release

# -------------------------
# Dev stage: full Rust toolchain + source for local development
FROM rust:1.81-slim AS dev
WORKDIR /usr/src/app
# Install native dependencies (e.g., SSL libs) for development
RUN apt-get update && apt-get install -y \
  pkg-config \
  libssl-dev \
  && rm -rf /var/lib/apt/lists/*
# Copy everything (source, static, config)
COPY . .
# Install development tooling: cargo-watch, dotenv-cli, cargo-make
RUN cargo install cargo-watch dotenv-cli cargo-make
# Expose port for dev server
EXPOSE 8080
# Default command: hot-reload dev server
CMD ["cargo", "make", "dev"]

# Production stage: minimal runtime image
FROM debian:bookworm-slim AS production

RUN apt-get update && apt-get install -y \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /usr/src/app/target/release/frontend .

# Copy static files
COPY static ./static

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
## since frontend.exe is executable it just needs temrinal command: './frontend'
CMD ["./frontend"]
