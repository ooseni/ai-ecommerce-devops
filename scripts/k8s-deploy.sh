#!/usr/bin/env bash
# k8s-deploy.sh: deploy one commit's images to a cluster with Helm. A release that
# does not become healthy is rolled back, so the previous version keeps serving.
#
# Usage: scripts/k8s-deploy.sh dev|prod COMMIT_SHA
# Uses the cluster in the current kubeconfig.

set -euo pipefail

environment="$1"
tag="$2"
chart="$(dirname "$0")/../helm/ecommerce"

kubectl version --request-timeout=10s >/dev/null

helm upgrade --install shop "$chart" \
  --namespace shop --create-namespace \
  --values "$chart/values-$environment.yaml" \
  --set image.tag="$tag" \
  --rollback-on-failure --wait --timeout 5m

kubectl --namespace shop get pods
helm --namespace shop history shop --max 3
