#!/usr/bin/env bash
# setup.sh: prepare a fresh clone for local development.
# Starts MongoDB in Docker, installs dependencies and creates the .env files.
# Safe to run again: every step skips work that is already done.
#
# Usage: scripts/setup.sh
# To also load an admin user and sample data:
#   ADMIN_EMAIL=you@example.com ADMIN_PASSWORD='...' scripts/setup.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/application"
MONGO_CONTAINER="${MONGO_CONTAINER:-mongo-dev}"
MONGO_IMAGE="mongo:7.0"

step() { printf '\n==> %s\n' "$1"; }

step "Tools"
for tool in docker node npm openssl; do
  command -v "$tool" >/dev/null || { echo "missing: $tool" >&2; exit 1; }
done
echo "found docker, node $(node --version), npm $(npm --version), openssl"

step "MongoDB ($MONGO_CONTAINER)"
state=$(docker inspect -f '{{.State.Running}}' "$MONGO_CONTAINER" 2>/dev/null || true)
case "$state" in
  true)  echo "already running" ;;
  false) docker start "$MONGO_CONTAINER" >/dev/null && echo "started" ;;
  *)     docker run -d --name "$MONGO_CONTAINER" -p 127.0.0.1:27017:27017 \
           -v mongo-dev-data:/data/db "$MONGO_IMAGE" >/dev/null && echo "created" ;;
esac

mongo_ready() {
  docker exec "$MONGO_CONTAINER" mongosh --quiet --eval 'db.runCommand({ ping: 1 }).ok' 2>/dev/null | grep -q '^1$'
}
tries=0
until mongo_ready; do
  tries=$((tries + 1))
  (( tries < 30 )) || { echo "MongoDB not ready after 30 seconds" >&2; exit 1; }
  sleep 1
done
echo "ready"

for part in server client; do
  dir="$APP/$part"
  step "Dependencies and .env ($part)"
  if [[ "$dir/node_modules/.package-lock.json" -nt "$dir/package-lock.json" ]]; then
    echo "node_modules up to date, skipped npm ci"
  else
    (cd "$dir" && npm ci --no-audit --no-fund)
  fi
  if [[ -f "$dir/.env" ]]; then
    echo ".env exists, left as is"
  else
    cp "$dir/.env.example" "$dir/.env"
    echo ".env created from .env.example"
  fi
done

step "JWT secret"
if grep -q '^JWT_SECRET=$' "$APP/server/.env"; then
  sed -i "s/^JWT_SECRET=$/JWT_SECRET=$(openssl rand -hex 32)/" "$APP/server/.env"
  echo "generated (not shown)"
else
  echo "already set, left as is"
fi
chmod 600 "$APP/server/.env"

step "Seed data"
if [[ -n "${ADMIN_EMAIL:-}" && -n "${ADMIN_PASSWORD:-}" ]]; then
  (cd "$APP/server" && node utils/seed.js "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
else
  echo "skipped (set ADMIN_EMAIL and ADMIN_PASSWORD to load sample data)"
fi

echo
echo "Setup complete."