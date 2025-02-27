FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    pkg-config \
    gcc \
    libssl-dev \
    git \
    supervisor \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Setup working directory
WORKDIR /whoknows

# executable before copying (just to be sure) 
RUN chmod +x ./src/Rust_Actix/backend/Scripts/*.sh

# Copy application files
COPY . .

# Make scripts executable
RUN chmod +x /whoknows/src/Rust_Actix/backend/Scripts/*.sh

# Setup cron job for auto-updates
RUN echo "*/5 * * * * /whoknows/src/Rust_Actix/backend/Scripts/auto_update.sh >> /var/log/supervisor/cron-auto-update.log 2>&1" > /etc/cron.d/auto-update-cron
RUN chmod 0644 /etc/cron.d/auto-update-cron

# Setup supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create log directory
RUN mkdir -p /var/log/supervisor

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
