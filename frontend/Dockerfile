# frontend/Dockerfile
# ---- Stage 1: Build ----
   FROM node:18-alpine as builder

   # Build arguments with defaults
   ARG NODE_ENV=production
   ARG COMPOSE_PROJECT_NAME=whoknows
   
   ENV NODE_ENV=${NODE_ENV}
   ENV COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
   
   WORKDIR /app
   
   # Copy dependencies first for better caching
   COPY package.json package-lock.json* ./
   RUN npm ci
   
   # Copy rest of the app
   COPY . .
   RUN npm run build
   
   # ---- Stage 2: Serve ----
   FROM nginx:1.25-alpine
   
   # Runtime arguments with defaults
   ARG FRONTEND_INTERNAL_PORT=91
   ARG BACKEND_INTERNAL_PORT=8080
   ARG COMPOSE_PROJECT_NAME=whoknows
   
   ENV FRONTEND_INTERNAL_PORT=${FRONTEND_INTERNAL_PORT}
   ENV BACKEND_INTERNAL_PORT=${BACKEND_INTERNAL_PORT}
   ENV COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
   
   RUN rm /etc/nginx/conf.d/default.conf
   
   COPY nginx.conf /etc/nginx/templates/default.conf.template
   COPY --from=builder /app/dist /usr/share/nginx/html
   
   EXPOSE ${FRONTEND_INTERNAL_PORT}
   
   # Add script to perform variable substitution and start nginx
   CMD ["/bin/sh", "-c", "envsubst '${FRONTEND_INTERNAL_PORT} ${BACKEND_INTERNAL_PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]