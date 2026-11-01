#!/usr/bin/env bash
# rolling-update-check.sh: prove a rolling update causes no downtime. Restarts the API
# and Nginx pods one by one while sending requests through the ingress, then counts
# every answer. Exit code 0 only when every request got a 200.
#
# Usage: scripts/rolling-update-check.sh [BASE_URL] (default http://127.0.0.1:8088)

set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8088}"
results=$(mktemp)
trap 'rm -f "$results"' EXIT

# probe PATH: one request, written as its status code; 000 means no answer.
probe() {
  curl -s -o /dev/null -w '%{http_code}\n' --max-time 5 "$BASE_URL$1" >>"$results" || true
}

(
  while [[ ! -e "$results.stop" ]]; do
    probe /api/health
    probe /
    sleep 0.2
  done
) &
prober=$!

kubectl --namespace shop rollout restart deployment/server deployment/client
kubectl --namespace shop rollout status deployment/server --timeout=180s
kubectl --namespace shop rollout status deployment/client --timeout=180s

touch "$results.stop"
wait "$prober"
rm -f "$results.stop"

total=$(wc -l <"$results")
failed=$(grep -vc '^200$' "$results" || true)
echo "Requests: $total, not 200: $failed"
sort "$results" | uniq -c

if ((total == 0 || failed > 0)); then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: PASS, no downtime"
