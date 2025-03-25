FROM rust:latest

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    curl \
    git \
    cron \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /

# Copy scripts
COPY ./Scripts/start.sh /start.sh
RUN chmod +x /start.sh

# Create log file
RUN touch /var/log/whoknows.log

# Run the start script as entry point
CMD ["/start.sh"]
