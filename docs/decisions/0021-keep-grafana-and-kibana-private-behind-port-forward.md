---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Keep Grafana and Kibana private behind port-forward

> In the context of DevOps Platform, facing both interfaces expose operational detail, we decided for port-forward only and neglected publish through the ingress with login, VPN into the VPC, to achieve security, simplicity, accepting that only someone with the kubeconfig can view the dashboards.

## Context and Problem Statement

Both interfaces expose operational detail. Publishing them needs TLS, a login and an open port, on a node with no domain.

## Decision Drivers

* Security
* Simplicity

## Considered Options

* Port-forward only
* Publish through the ingress with login
* VPN into the VPC

## Decision Outcome

Chosen option: "Port-forward only", because it best meets the decision drivers (security, simplicity).

We will leave both as ClusterIP Services and reach them only through kubectl port-forward, with Grafana's password generated into a Secret.

### Consequences

* Good, because no new port or public login page
* Good, because password never stored in git
* Bad, because port-forward had to be wrapped in a reconnect loop on an unsteady link
* Bad, because not usable for a wider team

### Confirmation

Security group has no rule for either; both reached at localhost through the forward.

## Pros and Cons of the Options

### Port-forward only

* Good, because nothing new exposed
* Good, because access requires cluster credentials
* Bad, because manual, and drops on a bad link

### Publish through the ingress with login

* Good, because easy to reach
* Bad, because no TLS yet, so passwords would cross in clear text

### VPN into the VPC

* Good, because private network access
* Bad, because a server to run and pay for

## More Information

Confidence: High.
Review by: When TLS and a domain exist.
Trade-offs accepted: only someone with the kubeconfig can view the dashboards.
Components: kubectl.
Requirements addressed: REQ-09.
Part of the DevOps Platform architecture decision record.
