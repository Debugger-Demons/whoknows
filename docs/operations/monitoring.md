# Monitoring Guide

This document covers the basic monitoring setup for the WhoKnows application.

## Monitoring Overview

For a simple application like WhoKnows, we focus on:

1. **Application Health**: Basic health checks
2. **Error Logging**: Capturing and analyzing errors
3. **Performance Metrics**: Basic resource usage

## Health Checks

The application exposes a health check endpoint:

```
GET /api/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2023-11-15T10:30:45Z",
  "version": "1.0.0"
}
```

You can monitor this endpoint with simple HTTP checks using:
- cURL scripts
- Basic monitoring tools (Uptime Robot, Pingdom)
- Health check functionality in your hosting platform

## Logging

WhoKnows uses the Rust logging framework with the following log levels:

- `error`: Critical issues that need immediate attention
- `warn`: Potential issues that should be reviewed
- `info`: Normal operational information
- `debug`: Detailed information for debugging

### Log Collection

Logs are output to:
- Console (stdout/stderr)
- Log files (when configured)

To configure file logging, set the environment variable:
```
LOG_FILE=/path/to/whoknows.log
```

### Log Analysis

For a simple application, reviewing log files directly is often sufficient:

```bash
# View recent errors
grep "ERROR" /path/to/whoknows.log

# View logs for a specific user
grep "user_id=123" /path/to/whoknows.log

# Monitor logs in real-time
tail -f /path/to/whoknows.log
```

## Resource Monitoring

Monitor the following system resources:

- **CPU Usage**: Should generally be below 70%
- **Memory Usage**: Watch for memory leaks or excessive usage
- **Disk Space**: Ensure sufficient space for database and logs
- **Network I/O**: Monitor for unusual traffic patterns

Basic monitoring can be done with:
- `top` or `htop` for CPU and memory
- `df -h` for disk space
- `nethogs` for network usage

## Simple Alerting

For basic alerting:

1. **Email Alerts**: Set up simple scripts to email on issues
   ```bash
   if ! curl -s http://your-app/api/health | grep -q "ok"; then
     mail -s "WhoKnows Health Check Failed" admin@example.com
   fi
   ```

2. **Log Monitoring**: Check for error patterns
   ```bash
   if grep -q "ERROR" /path/to/whoknows.log; then
     mail -s "WhoKnows Error Detected" admin@example.com
   fi
   ```

## Monitoring Dashboard

For a simple application, a basic status page can be sufficient:

1. Create a simple HTML page that displays:
   - Last health check status
   - Recent error count
   - System resource usage

2. Update this information using cron jobs that run monitoring scripts

## Incident Response

When issues are detected:

1. **Check Logs**: Review application logs for errors
2. **Verify Database**: Ensure the database is accessible
3. **Check Resources**: Verify sufficient system resources
4. **Restart if Needed**: Restart the application if necessary
   ```bash
   docker restart whoknows-app
   ```
   or
   ```bash
   systemctl restart whoknows
   ```