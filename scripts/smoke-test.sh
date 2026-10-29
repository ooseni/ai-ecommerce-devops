#!/usr/bin/env bash
# smoke-test.sh: check a running shop end to end, through its front door.
# Passes only if the shop page loads, the API reports MongoDB connected,
# and the product list returns products. Exit code 0 on pass, 1 on fail.
#
# Usage: scripts/smoke-test.sh [BASE_URL] (default http://localhost:8080)

set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"
failures=0

# report OK MESSAGE: print PASS or FAIL; OK is the exit status of a test.
report() {
  if (($1 == 0)); then
    printf ' PASS %s\n' "$2"
  else
    printf ' FAIL %s\n' "$2"
    failures=$((failures + 1))
  fi
}

echo "Smoke test, $BASE_URL, $(date '+%Y-%m-%d %H:%M:%S')"

code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$BASE_URL/" || true)
[[ "$code" == 200 ]] && ok=0 || ok=1
report "$ok" "shop page -> $code"

db=$(curl -s --max-time 5 "$BASE_URL/api/health" | jq -r '.db // empty' 2>/dev/null || true)
[[ "$db" == connected ]] && ok=0 || ok=1
report "$ok" "API health: database ${db:-no answer}"

# The list endpoint needs the same filters the shop sends, or it matches nothing.
count=$(curl -s --max-time 5 -G "$BASE_URL/api/product/list" \
  --data-urlencode 'sortOrder={"_id":-1}' -d rating=0 -d min=1 -d max=2500 |
  jq -r '.count // 0' 2>/dev/null || true)
((${count:-0} > 0)) && ok=0 || ok=1
report "$ok" "products: ${count:-0} in the catalogue"

if ((failures == 0)); then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL ($failures of 3 checks failed)"
  exit 1
fi
