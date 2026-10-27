#!/usr/bin/env bash
# cleanup.sh: stop what deploy.sh started, then stop MongoDB.
# Nothing is deleted: the data stays in the mongo-dev-data volume
# and the logs stay in .run/.
#
# Usage: scripts/cleanup.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="$ROOT/.run"
MONGO_CONTAINER="${MONGO_CONTAINER:-mongo-dev}"

for name in client api; do
  pid_file="$RUN_DIR/$name.pid"
  if [[ ! -f "$pid_file" ]]; then
    echo "$name: no PID file, nothing started by deploy.sh"
    continue
  fi
  pid=$(cat "$pid_file")
  if kill -0 "$pid" 2>/dev/null; then
    # The minus sign targets the whole process group: npm and every child it started.
    kill -- "-$pid"
    echo "$name: stopped"
  else
    echo "$name: already stopped"
  fi
  rm -f "$pid_file"
done

if [[ "$(docker inspect -f '{{.State.Running}}' "$MONGO_CONTAINER" 2>/dev/null)" == "true" ]]; then
  docker stop "$MONGO_CONTAINER" >/dev/null
  echo "MongoDB: stopped, data kept in the volume"
else
  echo "MongoDB: not running"
fi
