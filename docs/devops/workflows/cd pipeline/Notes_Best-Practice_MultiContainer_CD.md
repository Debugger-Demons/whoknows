Let me break down the flow from workflow to Dockerfiles, container communication, and address those specific issues:

## Workflow to Dockerfile Flow

1. **GitHub Actions Workflow** (`cd.prod.yml`):

   - Builds Docker images using Dockerfiles
   - Pushes images to GitHub Container Registry
   - Transfers config files to production server
   - Runs remote deployment script

2. **Deployment Script** (`deploy.sh`):

   - Pulls Docker images from registry
   - Sets up environment for docker-compose
   - Starts containers via docker-compose
   - Monitors health and handles cleanup

3. **Docker Compose** (`docker-compose.prod.yml`):

   - Defines service configuration
   - Maps volumes, networks, and environment variables
   - Orchestrates containers and their interdependencies

4. **Dockerfiles** (backend and frontend):
   - Define multi-stage builds
   - Compile/build application code
   - Create lightweight runtime images

## Container Communication

Your containers communicate via:

1. **Docker Network**:

   - Services connect through the `app-network` bridge network
   - Backend is referenced by hostname `backend` in nginx config

2. **Nginx Reverse Proxy**:

   - Frontend container runs Nginx that forwards API requests to backend
   - Uses `/api/` path prefix to route to backend service

3. **Port Mapping**:
   - Frontend internal port: 91 (exposed to host via HOST_PORT_FRONTEND)
   - Backend internal port: 8090 (only exposed within Docker network)

## Best Practices for Multi-Container CD Pipelines

1. **Environment Isolation**:

   - Clear separation between dev, staging, and production
   - Environment-specific variables and configs

2. **Immutable Infrastructure**:

   - Tag images with specific versions (commit SHA)
   - Don't modify running containers; replace them

3. **Health Checks**:

   - Verify services are healthy after deployment
   - Implement automated rollback on failure

4. **Secret Management**:

   - Store secrets in GitHub Secrets or environment-specific vaults
   - Never hardcode secrets in config files

5. **Minimal Configuration Drift**:

   - Use templates with variable substitution
   - Generate environment-specific configs at deploy time

6. **Monitoring and Logging**:
   - Capture deployment results and container logs
   - Enable alerting for failed deployments

Would you like me to provide updated configuration files with these changes implemented?
