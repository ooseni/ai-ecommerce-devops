---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Package the shop as one Helm chart with per-environment values

> In the context of DevOps Platform, facing the same objects must deploy to two clusters with small differences, and generated secrets must survive upgrades, we decided for helm chart and neglected kustomize, plain manifests only, to achieve consistency, operability, accepting that templating complexity, and a second copy of the objects in k8s/.

## Context and Problem Statement

The same objects must deploy to two clusters with small differences, and generated secrets must survive upgrades.

## Decision Drivers

* Consistency
* Operability

## Considered Options

* Helm chart
* Kustomize
* Plain manifests only

## Decision Outcome

Chosen option: "Helm chart", because it best meets the decision drivers (consistency, operability).

We will deploy one chart, helm/ecommerce, with values-dev and values-prod, and keep plain manifests in k8s/ as a readable reference.

### Consequences

* Good, because an unhealthy release rolls back by itself
* Good, because no secret in git or in values files
* Bad, because k8s/ can drift from the chart
* Bad, because a ConfigMap change needed a checksum annotation to roll pods

### Confirmation

helm lint passes in the pipeline; revisions deployed on both clusters; plain manifests tested separately.

## Pros and Cons of the Options

### Helm chart

* Good, because releases, history and rollback built in
* Good, because lookup keeps generated secrets
* Good, because seed hook
* Bad, because templates are harder to read

### Kustomize

* Good, because plain YAML overlays
* Bad, because no release history or rollback

### Plain manifests only

* Good, because easy to read
* Bad, because duplicated per environment

## More Information

Confidence: High.
Review by: 2027-06.
Trade-offs accepted: templating complexity, and a second copy of the objects in k8s/.
Components: Helm 4.3.1.
Requirements addressed: REQ-02, REQ-05.
Part of the DevOps Platform architecture decision record.
