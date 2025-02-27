# ~/entrypoint.sh 
#!/bin/bash
set -e
echo "Starting the application"
exec /app/backend
