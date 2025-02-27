
FROM rust:1.68-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    pkg-config \
    curl \
    git \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Setup working directory (starting with an empty directory)
WORKDIR /whoknows

# Copy only the scripts first to optimize caching
COPY ./src/Rust_Actix/backend/Scripts /whoknows/src/Rust_Actix/backend/Scripts

# Make scripts executable
RUN chmod +x /whoknows/src/Rust_Actix/backend/Scripts/*.sh

# Expose the application port
EXPOSE 8080

# Use start.sh as entrypoint - it will handle git clone
CMD ["/whoknows/src/Rust_Actix/backend/Scripts/start.sh"]
