# frontend/Dockerfile
# ---- Stage 1: Build ----
   FROM node:18-alpine as builder
   WORKDIR /app
   COPY package.json package-lock.json* ./
   RUN npm ci
   COPY . .
   RUN npm run build
   
   # ---- Stage 2: Serve ----
   FROM nginx:1.25-alpine
   RUN rm /etc/nginx/conf.d/default.conf
   
   COPY nginx.conf /etc/nginx/templates/default.conf.template
   COPY --from=builder /app/dist /usr/share/nginx/html
   
   EXPOSE 91
   
   # Add script to perform variable substitution and start nginx
   CMD ["/bin/sh", "-c", "envsubst '${FRONTEND_INTERNAL_PORT} ${BACKEND_INTERNAL_PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
