#!/usr/bin/env bash
# observability-up.sh: install Prometheus and Grafana, then the ELK log pipeline, on the
# cluster in the current kubeconfig. Safe to run again. Grafana and Kibana are not published:
#   kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
#   kubectl -n logging port-forward svc/kibana 5601

set -euo pipefail

dir="$(dirname "$0")/../observability"

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Generated once and kept, so no password lives in git or in the chart's values.
if ! kubectl -n monitoring get secret grafana-admin >/dev/null 2>&1; then
  kubectl -n monitoring create secret generic grafana-admin \
    --from-literal=admin-user=admin \
    --from-literal=admin-password="$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')"
fi

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo update prometheus-community >/dev/null
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --version 92.17.0 \
  --values "$dir/kube-prometheus-values.yaml" \
  --wait --timeout 10m

kubectl apply -f "$dir/traefik-metrics.yaml" -f "$dir/alert-rules.yaml" -f "$dir/shop-dashboard.yaml"

kubectl apply -f "$dir/elk/namespace.yaml"
kubectl apply -f "$dir/elk/elasticsearch.yaml" -f "$dir/elk/logstash.yaml" \
  -f "$dir/elk/filebeat.yaml" -f "$dir/elk/kibana.yaml"
kubectl -n logging rollout status statefulset/elasticsearch --timeout=300s
kubectl -n logging rollout status deployment/logstash --timeout=300s
kubectl -n logging rollout status deployment/kibana --timeout=300s
kubectl -n logging rollout status daemonset/filebeat --timeout=120s

# Load the saved searches through a temporary port-forward.
kubectl -n logging port-forward svc/kibana 5601 >/dev/null &
forward=$!
trap 'kill "$forward" 2>/dev/null || true' EXIT
for _ in $(seq 1 30); do
  curl -sf --max-time 3 http://127.0.0.1:5601/api/status >/dev/null && break
  sleep 2
done
curl -sf -X POST 'http://127.0.0.1:5601/api/saved_objects/_import?overwrite=true' \
  -H 'kbn-xsrf: true' --form file=@"$dir/elk/kibana-objects.ndjson" |
  jq '{success, successCount}'

kubectl -n monitoring get pods
kubectl -n logging get pods
