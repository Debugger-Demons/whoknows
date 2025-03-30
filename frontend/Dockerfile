# frontend/Dockerfile
# ---- Stage 1: Build ----
   FROM node:18-alpine AS builder

   # Accept build args but ensure development mode for build
   ARG COMPOSE_PROJECT_NAME
   ENV NODE_ENV=development
   ENV COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
   
   WORKDIR /app
   
   COPY package.json package-lock.json* ./
   RUN npm ci
   
   COPY . .
   RUN npm run build
   
   # ---- Stage 2: Serve ----
   FROM nginx:1.25-alpine
   
   # Accept all configuration from docker-compose
   ARG FRONTEND_INTERNAL_PORT
   ARG BACKEND_INTERNAL_PORT
   ARG COMPOSE_PROJECT_NAME
   ARG NODE_ENV
   
   # Pass through to container environment
   ENV FRONTEND_INTERNAL_PORT=${FRONTEND_INTERNAL_PORT}
   ENV BACKEND_INTERNAL_PORT=${BACKEND_INTERNAL_PORT}
   ENV COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
   ENV NODE_ENV=${NODE_ENV}
   
   RUN rm /etc/nginx/conf.d/default.conf
   COPY nginx.conf /etc/nginx/templates/default.conf.template
   COPY --from=builder /app/dist /usr/share/nginx/html
   
   EXPOSE ${FRONTEND_INTERNAL_PORT}
   
   CMD ["sh", "-c", "envsubst '${FRONTEND_INTERNAL_PORT} ${BACKEND_INTERNAL_PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]