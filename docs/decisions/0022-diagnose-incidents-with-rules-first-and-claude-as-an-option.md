---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Diagnose incidents with rules first, and Claude as an option

> In the context of DevOps Platform, facing an incident tool must help when things are broken, including when the network or API key is missing, we decided for rules first, optional Claude and neglected send logs straight to an LLM, a runbook and no tool, to achieve reliability, security, accepting that unknown failures get no diagnosis from the rules, and the AI layer adds a paid dependency when used.

## Context and Problem Statement

An incident tool must help when things are broken, including when the network or API key is missing. Logs may hold secrets. Language models can be wrong.

## Decision Drivers

* Reliability
* Security

## Considered Options

* Rules first, optional Claude
* Send logs straight to an LLM
* A runbook and no tool

## Decision Outcome

Chosen option: "Rules first, optional Claude", because it best meets the decision drivers (reliability, security).

We will find known failure signatures with rules, remove secrets from every line, and add a Claude explanation only when --ai is passed.

### Consequences

* Good, because correct diagnosis of the injected outage
* Good, because a critical finding sets exit 1 for scripts
* Bad, because each new failure needs a new rule
* Bad, because the --ai path has never been run against the live API

### Confirmation

10 unit tests pass; healthy cluster exits 0; outage reports MongoDB unavailable (critical), exit 1.

## Pros and Cons of the Options

### Rules first, optional Claude

* Good, because works offline and costs nothing
* Good, because same input, same answer
* Good, because secrets removed first
* Bad, because only knows listed failures

### Send logs straight to an LLM

* Good, because handles unknown failures
* Bad, because needs network, key and money
* Bad, because risk of leaking log contents

### A runbook and no tool

* Good, because nothing to build
* Bad, because slower under pressure

## More Information

Confidence: Medium.
Review by: After --ai is exercised with a real key.
Trade-offs accepted: unknown failures get no diagnosis from the rules, and the AI layer adds a paid dependency when used.
Components: Python 3, Claude API.
Requirements addressed: REQ-08.
Part of the DevOps Platform architecture decision record.
