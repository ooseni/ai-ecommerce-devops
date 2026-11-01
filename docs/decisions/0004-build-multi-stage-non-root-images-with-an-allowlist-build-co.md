---
status: "accepted"
date: 2026-10-28
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Build multi-stage, non-root images with an allowlist build context

> In the context of DevOps Platform, facing upstream images used Node 16 as root with npm install, we decided for multi-stage, non-root, allowlist and neglected keep the upstream Dockerfiles, single stage on a current base, to achieve security, size, accepting that a blocklist would be easier to read, but one missed path could leak a secret.

## Context and Problem Statement

Upstream images used Node 16 as root with npm install. Images must be small, repeatable and free of secrets.

## Decision Drivers

* Security
* Size

## Considered Options

* Multi-stage, non-root, allowlist
* Keep the upstream Dockerfiles
* Single stage on a current base

## Decision Outcome

Chosen option: "Multi-stage, non-root, allowlist", because it best meets the decision drivers (security, size).

We will build each image in two stages on pinned bases, run as numeric uid 1000 and 101 on root-owned files, and send only allowlisted paths to the builder.

### Consequences

* Good, because API 353 MB unpacked and 80 MB compressed; shop 70 MB and 28.8 MB
* Good, because numeric uid lets Kubernetes verify runAsNonRoot
* Bad, because a new top-level folder must be added to the allowlist
* Bad, because --omit=dev exposed chalk as a packaging fault

### Confirmation

id shows uid 1000 and 101; no .env in the image; hadolint runs in every build.

## Pros and Cons of the Options

### Multi-stage, non-root, allowlist

* Good, because no build tools at run time
* Good, because no .env can enter the image
* Good, because API can't change its own code
* Bad, because longer Dockerfiles

### Keep the upstream Dockerfiles

* Good, because no work
* Bad, because end-of-life Node
* Bad, because runs as root

### Single stage on a current base

* Good, because simple
* Bad, because build tools and dev packages ship

## More Information

Confidence: High.
Review by: At the next Node LTS change.
Trade-offs accepted: a blocklist would be easier to read, but one missed path could leak a secret.
Components: Docker, hadolint.
Requirements addressed: REQ-03.
Part of the DevOps Platform architecture decision record.
