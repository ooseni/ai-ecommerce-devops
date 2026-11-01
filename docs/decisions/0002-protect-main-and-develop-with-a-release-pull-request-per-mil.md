---
status: "accepted"
date: 2026-10-25
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Protect main and develop, with a release pull request per milestone

> In the context of DevOps Platform, facing GitHub shows main by default, so it must stay truthful, we decided for ruleset, pull requests, 0 approvals and neglected direct pushes to main, require 1 approval, to achieve traceability, safety, accepting that a pull request without a second reviewer is a record, not a review.

## Context and Problem Statement

GitHub shows main by default, so it must stay truthful. Work happens alone, so nobody else can approve a pull request.

## Decision Drivers

* Traceability
* Safety

## Considered Options

* Ruleset, pull requests, 0 approvals
* Direct pushes to main
* Require 1 approval

## Decision Outcome

Chosen option: "Ruleset, pull requests, 0 approvals", because it best meets the decision drivers (traceability, safety).

We will require pull requests on main and develop through a ruleset with 0 approvals, and promote develop to main at each release.

### Consequences

* Good, because the history reads milestone by milestone
* Good, because main always matches a tagged release
* Bad, because extra merge steps, even for small fixes
* Bad, because no independent code review

### Confirmation

Ruleset protect-main-and-develop is active; pull requests #1 to #13 record every change.

## Pros and Cons of the Options

### Ruleset, pull requests, 0 approvals

* Good, because every change has a record and a CI check
* Good, because works for one person
* Bad, because no second reviewer

### Direct pushes to main

* Good, because fastest
* Bad, because no record or checks

### Require 1 approval

* Good, because real review
* Bad, because blocks a solo project

## More Information

Confidence: High.
Review by: When a second contributor joins.
Trade-offs accepted: a pull request without a second reviewer is a record, not a review.
Components: GitHub rulesets.
Requirements addressed: REQ-01.
Part of the DevOps Platform architecture decision record.
