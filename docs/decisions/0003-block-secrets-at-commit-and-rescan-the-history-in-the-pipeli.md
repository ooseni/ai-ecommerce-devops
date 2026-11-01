---
status: "accepted"
date: 2026-10-23
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Block secrets at commit and rescan the history in the pipeline

> In the context of DevOps Platform, facing the repository is public, and a pushed secret must be treated as leaked, we decided for hooks plus a pipeline scan and neglected pipeline scan only, GitHub secret scanning only, to achieve security, accepting that some commit friction, and false positives must be checked by hand.

## Context and Problem Statement

The repository is public, and a pushed secret must be treated as leaked. Hooks can be skipped on another machine, so one layer is not enough.

## Decision Drivers

* Security

## Considered Options

* Hooks plus a pipeline scan
* Pipeline scan only
* GitHub secret scanning only

## Decision Outcome

Chosen option: "Hooks plus a pipeline scan", because it best meets the decision drivers (security).

We will run gitleaks in pre-commit and pre-push hooks, and scan the full git history in Jenkins and GitHub Actions as a hard gate.

### Consequences

* Good, because a leak is stopped on the laptop in most cases
* Good, because any secret fails the build, whatever its age
* Bad, because each clone must install the hooks
* Bad, because a secret in an unknown format can still slip through

### Confirmation

A fake AWS key was rejected at commit; Jenkins reports 52 commits scanned, no leaks.

## Pros and Cons of the Options

### Hooks plus a pipeline scan

* Good, because stops most leaks before they exist
* Good, because catches a skipped hook
* Bad, because two places to maintain

### Pipeline scan only

* Good, because one place
* Bad, because the secret is already pushed

### GitHub secret scanning only

* Good, because no setup
* Bad, because finds it after the push
* Bad, because known token formats only

## More Information

Confidence: High.
Review by: 2027-06.
Trade-offs accepted: some commit friction, and false positives must be checked by hand.
Components: gitleaks, pre-commit.
Requirements addressed: REQ-01, REQ-04.
Part of the DevOps Platform architecture decision record.
