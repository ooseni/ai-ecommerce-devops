#!/usr/bin/env bash
# blue-green.sh: release a new Nginx image beside the running one, test it, then move all
# traffic to it at once. The old pods stay up, so going back takes one Service change.
# It works on the client Deployment only; the API and MongoDB keep their rolling updates.
#
# Usage: scripts/blue-green.sh release IMAGE_TAG BASE_URL   start green, test, switch
#        scripts/blue-green.sh rollback BASE_URL            send traffic back to blue
#        scripts/blue-green.sh clean                        remove green and its traffic
#
# The next helm upgrade restores the chart's own selector, which ends the experiment.

set -euo pipefail

namespace=shop
base_dir="$(dirname "$0")"

# point_service_at APP: send the client Service's traffic to the pods labelled APP.
point_service_at() {
  kubectl -n "$namespace" patch service client \
    -p "{\"spec\":{\"selector\":{\"app\":\"$1\"}}}" >/dev/null
  echo "client Service now selects app=$1"
}

case "${1:-}" in
release)
  tag="$2"
  base_url="$3"
  image="ghcr.io/ooseni/mern-shop-client:$tag"

  # Green is a copy of blue with its own name and label, so the Service can tell them apart.
  kubectl -n "$namespace" get deployment client -o json |
    jq --arg image "$image" '
        .metadata = {name: "client-green", namespace: .metadata.namespace}
        | del(.status)
        | .spec.replicas = 1
        | .spec.selector.matchLabels.app = "client-green"
        | .spec.template.metadata.labels.app = "client-green"
        | .spec.template.spec.containers[0].image = $image' |
    kubectl apply -f -
  kubectl -n "$namespace" rollout status deployment/client-green --timeout=180s

  echo "Testing green directly, before it takes any traffic"
  kubectl -n "$namespace" port-forward deployment/client-green 18080:8080 >/dev/null &
  forward=$!
  trap 'kill "$forward" 2>/dev/null || true' EXIT
  sleep 3
  if ! "$base_dir/smoke-test.sh" http://127.0.0.1:18080; then
    echo "Green failed its test. Blue still has all the traffic."
    exit 1
  fi
  kill "$forward" 2>/dev/null || true
  trap - EXIT

  point_service_at client-green
  if ! "$base_dir/smoke-test.sh" "$base_url"; then
    echo "The shop failed after the switch. Going back to blue."
    point_service_at client
    exit 1
  fi
  echo "Green is live. Blue is still running: scripts/blue-green.sh rollback $base_url"
  ;;
rollback)
  point_service_at client
  "$base_dir/smoke-test.sh" "$2"
  ;;
clean)
  point_service_at client
  kubectl -n "$namespace" delete deployment client-green --ignore-not-found
  ;;
*)
  sed -n '2,10p' "$0"
  exit 1
  ;;
esac
