---
status: "accepted"
date: 2026-10-30
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Run Jenkins in Docker, using the host's Docker Engine through its socket

> In the context of DevOps Platform, facing the project calls for Jenkins as the main CI, we decided for Docker-outside-of-Docker and neglected Docker-in-Docker, GitHub Actions only, short-lived build agents, to achieve footprint, reproducibility, accepting that convenience on a single-user lab, in exchange for root-equivalent access.

## Context and Problem Statement

The project calls for Jenkins as the main CI. It must build images and start containers on a 7 GB laptop, and the whole setup must be reproducible.

## Decision Drivers

* Footprint
* Reproducibility

## Considered Options

* Docker-outside-of-Docker
* Docker-in-Docker
* GitHub Actions only
* Short-lived build agents

## Decision Outcome

Chosen option: "Docker-outside-of-Docker", because it best meets the decision drivers (footprint, reproducibility).

We will run a custom Jenkins image in its own Compose stack on loopback, with the Docker socket mounted, plus a basic GitHub Actions check on pull requests.

### Consequences

* Good, because tools are pinned in the image
* Good, because one executor makes builds queue rather than compete for memory
* Bad, because a malicious build could control the host: only own-repo branches are built, and production needs agents
* Bad, because CI stops when the laptop is off, hence the Actions check

### Confirmation

Non-root uid 1000 reached the engine through group 986. Green builds on develop and main.

## Pros and Cons of the Options

### Docker-outside-of-Docker

* Good, because shares the layer cache, so builds took seconds to minutes
* Good, because light on memory
* Bad, because socket access equals root on the host

### Docker-in-Docker

* Good, because isolated from the host engine
* Bad, because needs privileged mode
* Bad, because separate cache, more memory

### GitHub Actions only

* Good, because no server to run
* Bad, because the project calls for Jenkins
* Bad, because cannot reach the local cluster

### Short-lived build agents

* Good, because the production pattern
* Bad, because more moving parts than 7 GB allows

## More Information

Confidence: Medium.
Review by: Before any shared or production use.
Trade-offs accepted: convenience on a single-user lab, in exchange for root-equivalent access.
Components: Jenkins 2.580.2, Docker, GitHub Actions.
Requirements addressed: REQ-04, REQ-06, REQ-10.
Part of the DevOps Platform architecture decision record.
