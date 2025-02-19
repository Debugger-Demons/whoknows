# Use Ubuntu as base image - required for systemd
FROM ubuntu:22.04

# Enable systemd
ENV container docker
ENV DEBIAN_FRONTEND noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    systemd systemd-sysv \
    build-essential \
    curl \
    pkg-config \
    gcc \
    libssl-dev \
    git \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Setup working directory
WORKDIR /whoknows

# Copy application files
COPY . .

# Copy service file
COPY src/Rust_Actix/backend/Scripts/rust-app.service /etc/systemd/system/
RUN systemctl enable rust-app

# Copy entrypoint script
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Configure cron for auto-update
RUN (crontab -l 2>/dev/null; echo "*/5 * * * * /whoknows/src/Rust_Actix/backend/Scripts/auto_update.sh >> /var/log/whoknows-update.log 2>&1") | crontab -

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/docker-entrypoint.sh"]
