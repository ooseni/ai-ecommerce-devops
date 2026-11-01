#!/usr/bin/env bash
# ci-smoke.sh: start the images a build just made in a throwaway Compose stack,
# seed it, and run smoke-test.sh against it. The stack and its data are always
# removed afterwards. Needs SERVER_IMAGE, CLIENT_IMAGE and GIT_COMMIT.
#
# Runs inside the Jenkins container, which joins the stack's network to reach Nginx.
# 127.0.0.1 in there would be Jenkins itself.

set -euo pipefail

project=mern-ci
network="${project}_default"
jenkins_container=jenkins
env_file=application/server/.env
compose=(docker compose -p "$project" -f compose.yaml -f ci/compose.ci.yaml)

# This script writes and deletes .env, so it must never touch a developer's own.
if [[ -e "$env_file" ]]; then
  echo "refusing to run: $env_file already exists (this script is for clean CI checkouts)" >&2
  exit 1
fi

cleanup() {
  docker network disconnect "$network" "$jenkins_container" 2>/dev/null || true
  "${compose[@]}" logs --no-color --tail 30 server || true
  "${compose[@]}" down -v --remove-orphans || true
  rm -f "$env_file"
}
trap cleanup EXIT

# .env is gitignored, so CI writes its own with a signing key used only for this run.
umask 077
printf 'PORT=3000\nBASE_API_URL=api\nJWT_SECRET=%s\n' "$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')" >"$env_file"

"${compose[@]}" up -d --no-build --wait --wait-timeout 180

admin_password=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')
"${compose[@]}" exec -T server node utils/seed.js ci-admin@example.com "$admin_password"

docker network connect "$network" "$jenkins_container"
scripts/smoke-test.sh http://client:8080
