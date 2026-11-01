---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Use rolling updates by default and blue-green for Nginx on demand

> In the context of DevOps Platform, facing releases must not cause errors, we decided for rolling, plus blue-green for Nginx and neglected rolling only, blue-green for every tier, canary, to achieve availability, cost, accepting that the next helm upgrade restores the chart's selector and ends a blue-green experiment.

## Context and Problem Statement

Releases must not cause errors. Blue-green needs duplicate capacity and can't suit the API, which has in-memory chat state, or MongoDB.

## Decision Drivers

* Availability
* Cost

## Considered Options

* Rolling, plus blue-green for Nginx
* Rolling only
* Blue-green for every tier
* Canary

## Decision Outcome

Chosen option: "Rolling, plus blue-green for Nginx", because it best meets the decision drivers (availability, cost).

We will use rolling updates with maxSurge 1 and maxUnavailable 0 for every Deployment, and offer a scripted blue-green release for the Nginx tier.

### Consequences

* Good, because a release can be tested before it takes traffic
* Good, because no duplicated capacity by default
* Bad, because the API's missing SIGTERM handler makes each stop wait out its grace period
* Bad, because automatic rollback branch not yet triggered in a test

### Confirmation

116 of 116 and 134 of 134 answered 200; a true negative gave 14 of 28 at 502; blue-green passed on EC2.

## Pros and Cons of the Options

### Rolling, plus blue-green for Nginx

* Good, because 0 failed requests measured
* Good, because instant switch back for the front end
* Bad, because blue-green is a script, not chart-managed

### Rolling only

* Good, because simplest
* Bad, because no instant switch back

### Blue-green for every tier

* Good, because uniform
* Bad, because two API pods split chat state

### Canary

* Good, because gradual exposure
* Bad, because needs traffic-splitting; left as a future item

## More Information

Confidence: High.
Review by: When the API handles SIGTERM.
Trade-offs accepted: the next helm upgrade restores the chart's selector and ends a blue-green experiment.
Components: Kubernetes Deployments, blue-green.sh.
Requirements addressed: REQ-05.
Part of the DevOps Platform architecture decision record.
