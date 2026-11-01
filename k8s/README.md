# Plain Kubernetes manifests

The shop as plain YAML, with one object per concern and nothing templated. They exist to show
what runs on the cluster. The pipeline deploys the Helm chart in
[`helm/ecommerce`](../helm/ecommerce), which produces these same objects and adds the seed
job and per-environment values.

They use their own namespace and host name, so they can run beside the chart:

```bash
kubectl apply -f k8s/namespace.yaml
# Never commit a real secret. k8s/examples/secret.example.yaml shows the shape only.
kubectl -n shop-raw create secret generic shop-secrets \
  --from-literal=JWT_SECRET="$(openssl rand -hex 32)"
kubectl apply -f k8s/
curl -H 'Host: shop-raw.localhost' http://127.0.0.1:8088/api/health
kubectl delete namespace shop-raw
```

| File | Objects |
|---|---|
| `namespace.yaml` | Namespace `shop-raw` |
| `configmap.yaml` | ConfigMap with the API's settings |
| `mongo.yaml` | MongoDB StatefulSet with a 1 GiB volume, headless Service, NetworkPolicy |
| `server.yaml` | API Service and Deployment with probes, limits and a rolling update |
| `client.yaml` | Nginx Service, Deployment and HorizontalPodAutoscaler |
| `ingress.yaml` | Ingress for Traefik, the controller built into k3s |
