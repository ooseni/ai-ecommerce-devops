---
status: "accepted"
date: 2026-10-23
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Pin tool and image versions everywhere

> In the context of DevOps Platform, facing unpinned tools change without warning, we decided for pin everything and neglected track latest, pin apt packages as well, to achieve security, reproducibility, accepting that versions go stale unless someone updates them, and apt packages stay unpinned with a written reason.

## Context and Problem Statement

Unpinned tools change without warning. One Trivy release, 0.69.4, was compromised upstream (CVE-2026-33634), and a Jenkins rebuild could silently change plugins.

## Decision Drivers

* Security
* Reproducibility

## Considered Options

* Pin everything
* Track latest
* Pin apt packages as well

## Decision Outcome

Chosen option: "Pin everything", because it best meets the decision drivers (security, reproducibility).

We will pin Kubernetes, Helm, Trivy, gitleaks, hadolint, shfmt, base images, Jenkins plugins and GitHub Actions, and copy tools from their official images.

### Consequences

* Good, because local and cloud clusters run the same Kubernetes
* Good, because hadolint exception is documented in the Dockerfile
* Bad, because security fixes do not arrive by themselves
* Bad, because no automated update tool is set up

### Confirmation

Versions visible in ci/jenkins/Dockerfile, plugins.txt, Chart, Compose and ci.yml; hadolint passes.

## Pros and Cons of the Options

### Pin everything

* Good, because same result on every rebuild
* Good, because upgrades are visible commits
* Good, because no curl into a shell
* Bad, because upgrades take deliberate work

### Track latest

* Good, because always current
* Bad, because silent breakage
* Bad, because exposure to a compromised release

### Pin apt packages as well

* Good, because fully fixed
* Bad, because repositories drop old versions, breaking rebuilds

## More Information

Confidence: High.
Review by: 2027-01.
Trade-offs accepted: versions go stale unless someone updates them, and apt packages stay unpinned with a written reason.
Components: Docker, Jenkins, GitHub Actions.
Requirements addressed: REQ-03, REQ-02.
Part of the DevOps Platform architecture decision record.
