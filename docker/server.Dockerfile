# API image: the Express server on Node.js 24, running as a non-root user.
# Build from the repo root: docker build -f docker/server.Dockerfile .

# Stage 1: install production dependencies only.
FROM node:24.22.1-alpine AS deps
WORKDIR /app
COPY application/server/package.json application/server/package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund

# Stage 2: the runtime image. Files stay owned by root, so the app,
# running as a non-root user, can read its code but never change it.
FROM node:24.22.1-alpine
ENV NODE_ENV=production
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY application/server/ ./
USER node
EXPOSE 3000
CMD ["node", "index.js"]
