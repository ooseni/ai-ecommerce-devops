#!/usr/bin/env bash
# deploy.sh: start the whole stack locally and wait until it is healthy.
# Runs setup.sh, starts the API and the client in the background unless
# they are already up, then retries health-check.sh until it passes.
# Logs and process IDs go to .run/. Stop everything with scripts/cleanup.sh.
#
# Usage: scripts/deploy.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="$ROOT/.run"
TIMEOUT="${TIMEOUT:-120}"

"$ROOT/scripts/setup.sh"
mkdir -p "$RUN_DIR"

# start NAME PORT DIR: run 'npm run dev' in DIR in the background,
# unless something already answers on PORT.
start() {
  local name="$1" port="$2" dir="$3"
  if curl -s -o /dev/null --max-time 2 "http://localhost:$port"; then
    echo "$name: already running on port $port, left as is"
    return
  fi
  (
    cd "$dir"
    setsid npm run dev >"$RUN_DIR/$name.log" 2>&1 &
    echo $! >"$RUN_DIR/$name.pid"
  )
  echo "$name: started, log in .run/$name.log"
}

printf '\n==> Starting services\n'
start api 3000 "$ROOT/application/server"
start client 8080 "$ROOT/application/client"

printf '\n==> Waiting up to %ss for a healthy stack\n' "$TIMEOUT"
waited=0
until "$ROOT/scripts/health-check.sh" >/dev/null; do
  waited=$((waited + 5))
  if ((waited >= TIMEOUT)); then
    "$ROOT/scripts/health-check.sh" || true
    echo "Deploy failed: not healthy after ${TIMEOUT}s, see the logs in .run/" >&2
    exit 1
  fi
  sleep 5
done
"$ROOT/scripts/health-check.sh"
echo "Deploy complete: the shop is at http://localhost:8080"
