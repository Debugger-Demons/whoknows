#!/bin/bash

# Start cron service
service cron start

# Start systemd
exec /lib/systemd/systemd --system --unit=multi-user.target
