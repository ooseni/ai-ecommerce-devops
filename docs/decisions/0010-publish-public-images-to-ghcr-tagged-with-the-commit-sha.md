---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Publish public images to GHCR, tagged with the commit SHA

> In the context of DevOps Platform, facing the cluster must pull images on a node that may be rebuilt, we decided for public GHCR, SHA tags and neglected private GHCR with a pull secret, Amazon ECR, a latest tag, to achieve security, traceability, accepting that anyone can pull the images, so they must never hold secrets (ADR-004).

## Context and Problem Statement

The cluster must pull images on a node that may be rebuilt. The only classic GitHub token available for pushing also holds the repo scope, which should not live in a cluster.

## Decision Drivers

* Security
* Traceability

## Considered Options

* Public GHCR, SHA tags
* Private GHCR with a pull secret
* Amazon ECR
* A latest tag

## Decision Outcome

Chosen option: "Public GHCR, SHA tags", because it best meets the decision drivers (security, traceability).

We will push from develop and main to public GHCR packages, tagged with the full commit SHA, with no registry login on the cluster.

### Consequences

* Good, because rollback means deploying an earlier SHA
* Good, because rebuilt nodes need no credentials
* Bad, because the push token keeps the repo scope, which GitHub's page would not remove
* Bad, because pushes need retries on a slow link

### Confirmation

Anonymous manifest read returns 200 after the visibility change; main build #2 deployed by SHA.

## Pros and Cons of the Options

### Public GHCR, SHA tags

* Good, because no registry secret on the node
* Good, because every image traces to one commit
* Good, because free
* Bad, because images are public

### Private GHCR with a pull secret

* Good, because private images
* Bad, because a repo-scoped token stored in the cluster

### Amazon ECR

* Good, because IAM-based pulls
* Bad, because extra cost and a push credential on the laptop

### A latest tag

* Good, because simple
* Bad, because can't tell what is running or roll back reliably

## More Information

Confidence: High.
Review by: If the images ever hold private code.
Trade-offs accepted: anyone can pull the images, so they must never hold secrets (ADR-004).
Components: GitHub Container Registry.
Requirements addressed: REQ-03, REQ-04, REQ-09.
Part of the DevOps Platform architecture decision record.
