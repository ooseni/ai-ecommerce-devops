#!/usr/bin/env bash
# security-gate.sh: compare a scan's critical findings with the recorded baseline.
# Exit code 0 at or below the baseline, 1 above it or when the report is unreadable,
# so a scanner that failed to run can never pass as a clean scan.
#
# Usage: scripts/security-gate.sh npm|trivy REPORT_JSON BASELINE_KEY
# Baselines live in ci/security-baseline.env.

set -euo pipefail

kind="$1"
report="$2"
key="$3"
baseline_file="$(dirname "$0")/../ci/security-baseline.env"

case "$kind" in
npm) filter='.metadata.vulnerabilities.critical' ;;
trivy) filter='select(.SchemaVersion) | [.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' ;;
*)
  echo "unknown scan kind: $kind" >&2
  exit 1
  ;;
esac

if ! found=$(jq -er "$filter" "$report" 2>/dev/null); then
  echo "FAIL $key: cannot read a result from $report"
  exit 1
fi

baseline=$(awk -F= -v k="$key" '$1 == k { print $2 }' "$baseline_file")
if [[ -z "$baseline" ]]; then
  echo "FAIL $key: no baseline in $baseline_file"
  exit 1
fi

if ((found > baseline)); then
  echo "FAIL $key: $found critical, baseline $baseline"
  exit 1
fi
echo "PASS $key: $found critical, baseline $baseline"
