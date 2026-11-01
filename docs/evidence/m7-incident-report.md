# Incident report

**Likely cause: MongoDB unavailable** (severity: critical)

The API cannot reach MongoDB, so every request that needs data fails. The API process itself is alive: liveness passes while readiness fails.

Read 291 log lines and found 3 kind(s) of failure.

## MongoDB unavailable (1 lines)

Evidence:

```
statefulset/mongo replicas: 0
```

What to do:

1. Check the database pod: kubectl -n shop get pod mongo-0
2. Bring it back if it was scaled down: kubectl -n shop scale statefulset/mongo --replicas=1
3. Read its logs: kubectl -n shop logs mongo-0 --tail=50
4. Confirm recovery: scripts/smoke-test.sh <shop URL>

## API unreachable from Nginx (5 lines)

Evidence:

```
[pod/client-7bdb9c455c-7rsb8/client] 2026/11/01 19:10:05 [error] 22#22: *295 connect() failed (111: Connection refused) while connecting to upstream, client: 10.42.0.8, server: _, request: "GET /api/category/list HTTP/1.1", upstream: "http://10.43.140.139:3000/api/category/list", host: "52.23.117.25
[pod/client-7bdb9c455c-7rsb8/client] 2026/11/01 19:10:14 [error] 22#22: *295 connect() failed (111: Connection refused) while connecting to upstream, client: 10.42.0.8, server: _, request: "GET /api/health HTTP/1.1", upstream: "http://10.43.140.139:3000/api/health", host: "52.23.117.254"
[pod/client-7bdb9c455c-7rsb8/client] 2026/11/01 19:10:15 [error] 22#22: *295 connect() failed (111: Connection refused) while connecting to upstream, client: 10.42.0.8, server: _, request: "GET /api/health HTTP/1.1", upstream: "http://10.43.140.139:3000/api/health", host: "52.23.117.254"
[pod/client-7bdb9c455c-p4d7z/client] 2026/11/01 19:10:05 [error] 21#21: *291 connect() failed (111: Connection refused) while connecting to upstream, client: 10.42.0.8, server: _, request: "GET /api/brand/list HTTP/1.1", upstream: "http://10.43.140.139:3000/api/brand/list", host: "52.23.117.254", re
[pod/client-7bdb9c455c-p4d7z/client] 2026/11/01 19:10:15 [error] 21#21: *291 connect() failed (111: Connection refused) while connecting to upstream, client: 10.42.0.8, server: _, request: "GET /api/product/list?sortOrder=%7b%22_id%22%3a-1%7d&rating=0&min=1&max=2500 HTTP/1.1", upstream: "http://10.4
```

What to do:

1. Check the API pods and their readiness: kubectl -n shop get pods -l app=server
2. Check the Service has endpoints: kubectl -n shop get endpointslices

## Readiness failing (4 lines)

Evidence:

```
15m         Warning   Unhealthy               pod/client-7bdb9c455c-7rsb8          Readiness probe failed: Get "http://10.42.0.10:8080/": dial tcp 10.42.0.10:8080: connect: connection refused
14m         Warning   Unhealthy               pod/server-64cb4f779b-q4pr4          Startup probe failed: Get "http://10.42.0.9:3000/api/health/live": dial tcp 10.42.0.9:3000: connect: connection refused
12m         Warning   Unhealthy               pod/client-green-76f4d4689-lbcrs     Readiness probe failed: Get "http://10.42.0.15:8080/": dial tcp 10.42.0.15:8080: connect: connection refused
1s          Warning   Unhealthy               pod/server-64cb4f779b-q4pr4          Readiness probe failed: HTTP probe failed with statuscode: 503
```

What to do:

1. Read the probe's message: kubectl -n shop describe pod <pod>
