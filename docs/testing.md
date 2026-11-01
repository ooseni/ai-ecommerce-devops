# Testing

What was tested, how, and what actually happened, including the failures. Unless stated, every live test ran on 1 November 2026. Each script and gate was tested for both outcomes: it must pass on a healthy system and fail clearly on a broken one.

## Automated

| Where | When | What runs |
|---|---|---|
| Git hooks | Every commit and push | gitleaks, private key detection, the 1 MB file guard, merge conflict check |
| [GitHub Actions](../.github/workflows/ci.yml) | Pull requests, and pushes to `develop` and `main` | ShellCheck on 14 scripts, hadolint on 3 Dockerfiles, gitleaks over the full history, 10 analyzer unit tests, both image builds |
| [Jenkins](../Jenkinsfile) | Every branch, within 2 minutes, while the laptop is on | The 10 stages below |

Jenkins stages: Lint, Secret scan, Dependency audit, Build images, Image scan, Smoke test, then for `develop` and `main` Push to GHCR. `develop` adds Deploy to k3d and Post-deploy check; `main` adds Deploy to EC2.

## Versions

Kubernetes 1.36.5 (k3s and k3d), Helm 4.3.1, Terraform 1.17, Ansible core 2.21, Jenkins 2.580.2, Docker 29.9, Trivy 0.76.1, gitleaks 8.30.1, hadolint 2.15.1, shfmt 3.14.1, Node.js 24.22.1, MongoDB 7.0, Elastic stack 8.19.5, kube-prometheus-stack 92.17.

## Security gates

| Test | Expected | Actual |
|---|---|---|
| Commit a fake AWS key | Blocked | Blocked, key shown as REDACTED |
| gitleaks over the history in the pipeline | No leaks | 52 commits scanned, no leaks |
| Gate at the baseline, above it, and on an unreadable report | Pass, fail, fail | Exit 0 at 11 of 11, exit 1 at 11 of 4, exit 1 on a report with no result |
| Baseline lowered below the real count, on a throwaway branch | Build fails at the gate, later stages skip | `FAIL npm_server: 11 critical, baseline 10`, build failed, later stages skipped |
| Audit and image scans | At or below the baseline | npm: 11 API, 4 client. Trivy: 11 API, 1 client. All pass |
| Nginx pod connects to MongoDB | Blocked by NetworkPolicy | Blocked |

The baselines accept critical findings that were already present. They are not fixed, and they are recorded in [`ci/security-baseline.env`](../ci/security-baseline.env).

## Pipeline

| Test | Expected | Actual |
|---|---|---|
| First build: lint and images | Green | Success in 73 seconds, using cached layers |
| Smoke stage on the images just built | 3 of 3, nothing left behind | Page 200, database connected, 100 products; 0 containers, networks or volumes left |
| First push from `develop` | Images on GHCR | **Failed:** timeout on the largest layer. Added retries |
| Next deploying build | Every stage green | **Failed:** DNS timeout at `docker login`. Added retries to the login |
| Build after a power cut | Every stage green | **Failed:** CI MongoDB unhealthy on a strained laptop. Gave it longer |
| `develop` build #6 | Deploy to k3d | Success: images pushed, Helm deployed, post-deploy smoke 3 of 3 |
| `main` build #2 | Deploy to EC2 | Success: all 8 stages, Helm revision 2 on EC2, smoke 3 of 3 on the public address |

## Kubernetes

| Test | Expected | Actual |
|---|---|---|
| First install on k3d | API ready | **Failed:** 404 on the probe, routes under `/undefined`. Set `BASE_API_URL` |
| Install again | API ready | **Failed:** 503 with MongoDB up, first connection never retried. Added an init container |
| MongoDB under a CPU limit | Ready | **Failed:** `mongosh` probe timed out. Longer timeout, and a 1 CPU limit |
| Smoke test through the ingress | 3 of 3 | Page 200, database connected, 100 products |
| `rolling-update-check.sh` | Every request 200 | 116 of 116, and 134 of 134 in a later run |
| Same check with the API scaled to zero | Check fails | **First run wrongly passed** at 66 of 66, because the terminating pod still served. With the pod gone: 14 of 28 at 502, exit 1 |
| Plain manifests in their own namespace | Healthy | All rolled out, database connected, then deleted |

## AWS

| Test | Expected | Actual |
|---|---|---|
| Plan, read, then apply | Additions only | 9 added, then the budget alert, 1 added |
| First Ansible run | All roles applied | 21 ok, 13 changed. Connection lost at the very end; the node was Ready |
| Second Ansible run | No changes | `ok=21 changed=0` in 61 seconds |
| Read the hardening back over SSH | Passwords and root login off | `passwordauthentication no`, `permitrootlogin no`, UFW and fail2ban active |
| Destroy, apply, Ansible, Helm, smoke | Rebuilt with no manual steps | 10 destroyed, old address silent, 10 added. Ansible `ok=23 changed=14 unreachable=0` in 136 seconds. 3 of 3 smoke checks 248 seconds after apply |
| Final destroy | Nothing left running | 10 destroyed; 0 instances, VPCs, Elastic IPs and volumes. Only the S3 state bucket remains |

## Monitoring, incidents and releases

| Test | Expected | Actual |
|---|---|---|
| Install monitoring and logging | Pods ready, data flowing | Installed in 592 seconds; 1,630 log lines indexed; Traefik target up |
| Analyzer unit tests | All pass | 10 of 10, including secret redaction |
| Analyzer on a healthy cluster | No incident | **First flagged old start-up events.** Now a warning, exit 0 |
| Scale MongoDB to zero | Smoke fails; analyzer names MongoDB | Smoke 2 of 3 failed with the page still up; "Likely cause: MongoDB unavailable (critical)", exit 1; indexed errors rose from 15 to 20 |
| Scale MongoDB back up | Recovery with no API restart | 3 of 3 after 8 seconds, API restarts 0 |
| `ShopDatabaseDown` before the fix | Quiet while healthy | **Failed:** firing all the time, found from a screenshot |
| `ShopDatabaseDown` after the fix | Quiet, fires, clears | No shop alerts while healthy; `ShopAPIDown` and `ShopDatabaseDown` firing 100 seconds into an outage; both clear after recovery |
| Blue-green on EC2 | Shop passes at every step | 3 of 3 after the switch and after the rollback; clean-up removed green. The automatic rollback branch was not triggered |

## Not tested

- The analyzer's `--ai` option against the live Claude API, because no API key was available.
- Load: no load test was run, so the resource limits are estimates.
- High availability: one node in one zone, by design.
