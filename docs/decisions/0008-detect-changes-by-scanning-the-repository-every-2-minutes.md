---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Detect changes by scanning the repository every 2 minutes

> In the context of DevOps Platform, facing Jenkins is on loopback behind a home connection, so GitHub's webhooks can't reach it, we decided for periodic scan and neglected webhook through a tunnel, public Jenkins, to achieve security, simplicity, accepting that a delay of up to 2 minutes before a build starts.

## Context and Problem Statement

Jenkins is on loopback behind a home connection, so GitHub's webhooks can't reach it. Publishing Jenkins would widen the attack surface.

## Decision Drivers

* Security
* Simplicity

## Considered Options

* Periodic scan
* Webhook through a tunnel
* Public Jenkins

## Decision Outcome

Chosen option: "Periodic scan", because it best meets the decision drivers (security, simplicity).

We will use a multibranch job with a plain Git source and a 2-minute periodic scan.

### Consequences

* Good, because strangers' forks can't run code on the laptop
* Good, because no inbound ports at all
* Bad, because no commit status from Jenkins in pull requests
* Bad, because scans fail silently while the network is down

### Confirmation

Builds started by branch indexing after each merge, without an inbound connection.

## Pros and Cons of the Options

### Periodic scan

* Good, because nothing exposed
* Good, because plain Git source builds own branches only, not forks
* Bad, because up to 2 minutes' delay
* Bad, because constant small requests

### Webhook through a tunnel

* Good, because instant builds
* Bad, because a public path to Jenkins, which has the socket

### Public Jenkins

* Good, because normal webhooks
* Bad, because exposes a root-equivalent system

## More Information

Confidence: High.
Review by: If Jenkins moves to a server.
Trade-offs accepted: a delay of up to 2 minutes before a build starts.
Components: Jenkins multibranch.
Requirements addressed: REQ-04, REQ-09.
Part of the DevOps Platform architecture decision record.
