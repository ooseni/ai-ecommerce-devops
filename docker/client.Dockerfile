# Shop image: the React app built by webpack, served by Nginx as a non-root user.
# Build from the repo root: docker build -f docker/client.Dockerfile .

# Stage 1: build the static files. Node and node_modules stay in this stage.
FROM node:24.22.1-alpine AS build
WORKDIR /app
COPY application/client/package.json application/client/package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY application/client/ ./
# webpack bakes the API address into the JavaScript. /api is relative, so the
# browser calls the host it loaded the shop from, and Nginx forwards the call.
ARG API_URL=/api
ENV API_URL=$API_URL
RUN npm run build

# Stage 2: only Nginx and the built files.
FROM nginxinc/nginx-unprivileged:1.30-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
