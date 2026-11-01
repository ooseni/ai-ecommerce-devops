# Architecture decision log

One record per decision, in the MADR format. Records are immutable once accepted: a changed decision gets a new record that supersedes the old one.

| ID | Decision | Status | Date |
|---|---|---|---|
| [ADR-0001](0001-build-the-platform-around-a-vendored-open-source-shop.md) | Build the platform around a vendored open-source shop | accepted | 2026-10-23 |
| [ADR-0002](0002-protect-main-and-develop-with-a-release-pull-request-per-mil.md) | Protect main and develop, with a release pull request per milestone | accepted | 2026-10-25 |
| [ADR-0003](0003-block-secrets-at-commit-and-rescan-the-history-in-the-pipeli.md) | Block secrets at commit and rescan the history in the pipeline | accepted | 2026-10-23 |
| [ADR-0004](0004-build-multi-stage-non-root-images-with-an-allowlist-build-co.md) | Build multi-stage, non-root images with an allowlist build context | accepted | 2026-10-28 |
| [ADR-0005](0005-serve-the-browser-through-nginx-as-a-single-origin.md) | Serve the browser through Nginx as a single origin | accepted | 2026-10-28 |
| [ADR-0006](0006-separate-liveness-from-readiness.md) | Separate liveness from readiness | accepted | 2026-10-28 |
| [ADR-0007](0007-run-jenkins-in-docker-using-the-host-s-docker-engine-through.md) | Run Jenkins in Docker, using the host's Docker Engine through its socket | accepted | 2026-10-30 |
| [ADR-0008](0008-detect-changes-by-scanning-the-repository-every-2-minutes.md) | Detect changes by scanning the repository every 2 minutes | accepted | 2026-11-01 |
| [ADR-0009](0009-gate-vulnerabilities-on-a-recorded-baseline.md) | Gate vulnerabilities on a recorded baseline | accepted | 2026-11-01 |
| [ADR-0010](0010-publish-public-images-to-ghcr-tagged-with-the-commit-sha.md) | Publish public images to GHCR, tagged with the commit SHA | accepted | 2026-11-01 |
| [ADR-0011](0011-run-k3s-on-ec2-and-k3d-on-the-laptop.md) | Run k3s on EC2 and k3d on the laptop | accepted | 2026-10-23 |
| [ADR-0012](0012-package-the-shop-as-one-helm-chart-with-per-environment-valu.md) | Package the shop as one Helm chart with per-environment values | accepted | 2026-11-01 |
| [ADR-0013](0013-keep-the-api-at-one-replica-and-autoscale-nginx-instead.md) | Keep the API at one replica and autoscale Nginx instead | accepted | 2026-11-01 |
| [ADR-0014](0014-run-mongodb-in-the-cluster-as-a-statefulset.md) | Run MongoDB in the cluster as a StatefulSet | accepted | 2026-11-01 |
| [ADR-0015](0015-manage-aws-with-terraform-s3-state-and-reviewed-plans.md) | Manage AWS with Terraform, S3 state and reviewed plans | accepted | 2026-11-01 |
| [ADR-0016](0016-use-one-public-subnet-with-a-single-node.md) | Use one public subnet with a single node | accepted | 2026-11-01 |
| [ADR-0017](0017-limit-admin-ports-to-the-isp-s-address-range.md) | Limit admin ports to the ISP's address range | accepted | 2026-11-01 |
| [ADR-0018](0018-configure-the-node-with-ansible-roles.md) | Configure the node with Ansible roles | accepted | 2026-11-01 |
| [ADR-0019](0019-monitor-with-kube-prometheus-stack.md) | Monitor with kube-prometheus-stack | accepted | 2026-11-01 |
| [ADR-0020](0020-search-logs-with-an-elk-pipeline-on-the-node.md) | Search logs with an ELK pipeline on the node | accepted | 2026-11-01 |
| [ADR-0021](0021-keep-grafana-and-kibana-private-behind-port-forward.md) | Keep Grafana and Kibana private behind port-forward | accepted | 2026-11-01 |
| [ADR-0022](0022-diagnose-incidents-with-rules-first-and-claude-as-an-option.md) | Diagnose incidents with rules first, and Claude as an option | accepted | 2026-11-01 |
| [ADR-0023](0023-use-rolling-updates-by-default-and-blue-green-for-nginx-on-d.md) | Use rolling updates by default and blue-green for Nginx on demand | accepted | 2026-11-01 |
| [ADR-0024](0024-destroy-the-aws-environment-when-it-is-not-in-use.md) | Destroy the AWS environment when it is not in use | accepted | 2026-10-23 |
| [ADR-0025](0025-pin-tool-and-image-versions-everywhere.md) | Pin tool and image versions everywhere | accepted | 2026-10-23 |
