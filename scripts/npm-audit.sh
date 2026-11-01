#!/usr/bin/env bash
# npm-audit.sh: audit an app's production dependencies in a throwaway Node container.
# Only the manifest and lockfile go in, through a pipe: no workspace mount, so the
# Jenkins container's Docker socket stays out of it. npm audit exits 1 on any
# finding, so the verdict is left to security-gate.sh, which reads the report.
#
# Usage: scripts/npm-audit.sh APP_DIR REPORT_JSON

set -euo pipefail

app_dir="$1"
report="$2"

tar -C "$app_dir" -cf - package.json package-lock.json |
  docker run --rm -i node:24.22.1-alpine sh -c \
    'mkdir /audit && cd /audit && tar xf - && npm audit --omit=dev --json' >"$report" || true
