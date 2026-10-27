#!/usr/bin/env bash
# health-check.sh: check that MongoDB, the API and the client are up.
# Exits 0 when every check passes and 1 when any fails, so CI can use it.
#
# Usage: scripts/health-check.sh
# Point it elsewhere with environment variables, for example:
#   CLIENT_URL=http://localhost:9999 scripts/health-check.sh

set -euo pipefail

API_URL="${API_URL:-http://localhost:3000/api}"
CLIENT_URL="${CLIENT_URL:-http://localhost:8080}"
MONGO_CONTAINER="${MONGO_CONTAINER:-mongo-dev}"

failures=0

pass() { printf '  PASS  %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; failures=$((failures + 1)); }

# check_http NAME URL: passes when URL answers with 200.
check_http() {
  local name="$1" url="$2" code
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$url" || true)
  if [[ "$code" == "200" ]]; then
    pass "$name: $url -> $code"
  else
    fail "$name: $url -> $code"
  fi
}
echo "Health check, $(date '+%Y-%m-%d %H:%M:%S')"

if docker exec "$MONGO_CONTAINER" mongosh --quiet --eval 'db.runCommand({ ping: 1 }).ok' 2>/dev/null | grep -q '^1$'; then
  pass "MongoDB: $MONGO_CONTAINER answers ping"
else
  fail "MongoDB: $MONGO_CONTAINER does not answer ping"
fi

check_http "API" "$API_URL/brand/list"
check_http "Client" "$CLIENT_URL/"

if (( failures > 0)); then
  echo "RESULT: FAIL ($failures of 3 checks failed)"
  exit 1
fi
echo "RESULT: PASS (3 of 3 checks passed)"
