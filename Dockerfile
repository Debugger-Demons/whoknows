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

# Install more comprehensive dependencies that might be needed
RUN apt-get update && apt-get install -y \
    libssl-dev \
    ca-certificates \
    curl \
    net-tools \
    procps \
    strace \
    lsof \
    build-essential \
    pkg-config \
    gcc \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Setup working directory
WORKDIR /app

# Copy the built application from the builder stage
COPY --from=builder /app/src/Rust_Actix/backend/target/release/backend /app/backend

# Make the binary executable
RUN chmod +x /app/backend

# Create a log directory
RUN mkdir -p /app/logs

EXPOSE 8080

# Use a debug script to figure out what's happening
RUN echo '#!/bin/bash\n\
echo "=== Starting debug script ==="\n\
echo "Current directory: $(pwd)"\n\
echo "Environment variables:"\n\
env\n\
echo "Binary information:"\n\
ls -la /app/backend\n\
file /app/backend\n\
echo "Checking dependencies:"\n\
ldd /app/backend\n\
echo "Network interfaces:"\n\
ip addr\n\
echo "Open ports:"\n\
netstat -tulpn\n\
echo "Starting application with strace:"\n\
strace -f -e trace=network,process /app/backend > /app/logs/strace.log 2>&1 &\n\
STRACE_PID=$!\n\
sleep 5\n\
kill $STRACE_PID || true\n\
echo "Strace log (first 100 lines):"\n\
head -n 100 /app/logs/strace.log\n\
echo "Starting application normally:"\n\
/app/backend > /app/logs/app.log 2>&1 &\n\
APP_PID=$!\n\
sleep 5\n\
if ps -p $APP_PID > /dev/null; then\n\
  echo "Application is still running after 5 seconds"\n\
else\n\
  echo "Application exited. Exit code: $?"\n\
  echo "Application logs:"\n\
  cat /app/logs/app.log\n\
fi\n\
echo "Keeping container alive for further debugging..."\n\
tail -f /dev/null\n\
' > /app/debug.sh && chmod +x /app/debug.sh

CMD ["/app/debug.sh"]
