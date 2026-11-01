---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Gate vulnerabilities on a recorded baseline

> In the context of DevOps Platform, facing scans found critical issues on day one (npm: 11 API, 4 client; Trivy: 11 API, 1 client), we decided for baseline gate and neglected fail on any critical, report only, npm audit fix --force, to achieve security, usability, accepting that known critical vulnerabilities remain in shipped images.

## Context and Problem Statement

Scans found critical issues on day one (npm: 11 API, 4 client; Trivy: 11 API, 1 client). Failing on any critical would leave the pipeline red, and forced upgrades can break the app.

## Decision Drivers

* Security
* Usability

## Considered Options

* Baseline gate
* Fail on any critical
* Report only
* npm audit fix --force

## Decision Outcome

Chosen option: "Baseline gate", because it best meets the decision drivers (security, usability).

We will fail a build when critical findings exceed ci/security-baseline.env, or when a report can't be read, and keep gitleaks a hard gate.

### Consequences

* Good, because a gate the team will keep on
* Good, because lowering the baseline is a visible, reviewable commit
* Bad, because a new CVE published against an old package fails a build with no code change
* Bad, because high findings are not gated

### Confirmation

A baseline lowered to 10 gave FAIL npm_server: 11 critical, baseline 10, and every later stage was skipped.

## Pros and Cons of the Options

### Baseline gate

* Good, because blocks new risk today
* Good, because a scanner that fails can't pass
* Good, because debt is recorded in the repository
* Bad, because known criticals still ship

### Fail on any critical

* Good, because strictest
* Bad, because always red, so it gets ignored or disabled

### Report only

* Good, because never blocks
* Bad, because nothing stops new risk

### npm audit fix --force

* Good, because lower counts
* Bad, because major version jumps can break the app

## More Information

Confidence: Medium.
Review by: When any dependency upgrade lands.
Trade-offs accepted: known critical vulnerabilities remain in shipped images.
Components: npm audit, Trivy 0.76.1, security-gate.sh.
Requirements addressed: REQ-04.
Part of the DevOps Platform architecture decision record.
