---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Monitor with kube-prometheus-stack

> In the context of DevOps Platform, facing dashboards must show CPU, memory, pods, availability and requests, and raise alerts, we decided for kube-prometheus-stack and neglected Amazon CloudWatch, hand-written Prometheus manifests, to achieve observability, cost, accepting that more memory on one small node, and metrics are lost when it is destroyed.

## Context and Problem Statement

Dashboards must show CPU, memory, pods, availability and requests, and raise alerts. The tool must cover Kubernetes objects and stay on one node.

## Decision Drivers

* Observability
* Cost

## Considered Options

* kube-prometheus-stack
* Amazon CloudWatch
* Hand-written Prometheus manifests

## Decision Outcome

Chosen option: "kube-prometheus-stack", because it best meets the decision drivers (observability, cost).

We will install kube-prometheus-stack 92.17 with resource limits and 2 days' retention, and keep the dashboard and alert rules in the repository.

### Consequences

* Good, because dashboard shows the outage as dips in pods, API and database
* Good, because alerts proven both ways
* Bad, because no notification channel is configured yet
* Bad, because a rule bug fired ShopDatabaseDown all the time until a screenshot exposed it

### Confirmation

No shop alerts while healthy; ShopAPIDown and ShopDatabaseDown firing 100 s into an outage; clear after recovery.

## Pros and Cons of the Options

### kube-prometheus-stack

* Good, because prometheus, Grafana, Alertmanager and exporters together
* Good, because dashboards and rules as code
* Bad, because about 1 GiB more memory

### Amazon CloudWatch

* Good, because managed
* Bad, because cost per metric
* Bad, because not available on the laptop

### Hand-written Prometheus manifests

* Good, because smallest
* Bad, because exporters and rules to assemble by hand

## More Information

Confidence: High.
Review by: When a notification channel is added.
Trade-offs accepted: more memory on one small node, and metrics are lost when it is destroyed.
Components: Prometheus, Grafana, Alertmanager.
Requirements addressed: REQ-07.
Part of the DevOps Platform architecture decision record.
