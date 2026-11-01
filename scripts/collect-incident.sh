#!/usr/bin/env bash
# collect-incident.sh: print what the incident analyzer needs from a running cluster:
# the shop's health as a user sees it, pod states, recent events and recent logs.
#
# Usage: scripts/collect-incident.sh [BASE_URL] [NAMESPACE] (default http://127.0.0.1:8088 shop)
# Then:  scripts/collect-incident.sh | ai/incident_analyzer.py

set -uo pipefail

BASE_URL="${1:-http://127.0.0.1:8088}"
namespace="${2:-shop}"

echo "=== health through the front door, $(date '+%Y-%m-%d %H:%M:%S')"
curl -s --max-time 5 "$BASE_URL/api/health" || echo "no answer from $BASE_URL/api/health"
echo

echo "=== pods"
kubectl -n "$namespace" get pods -o wide

echo "=== database"
kubectl -n "$namespace" get statefulset mongo -o jsonpath='statefulset/mongo replicas: {.status.readyReplicas}{"\n"}' 2>&1 |
  sed 's/replicas: $/replicas: 0/'

echo "=== recent events"
kubectl -n "$namespace" get events --sort-by=.lastTimestamp | tail -n 40

for app in server client; do
  echo "=== logs, $app"
  kubectl -n "$namespace" logs -l "app=$app" --tail=100 --prefix 2>&1
done
