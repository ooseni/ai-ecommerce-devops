---
status: "accepted"
date: 2026-10-28
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Separate liveness from readiness

> In the context of DevOps Platform, facing the upstream API had no health endpoint, we decided for two endpoints and neglected one endpoint with the database check, TCP probes only, to achieve availability, diagnosis, accepting that upstream code is changed and carried forward.

## Context and Problem Statement

The upstream API had no health endpoint. If a probe includes the database, a database outage restarts healthy API pods, which fixes nothing.

## Decision Drivers

* Availability
* Diagnosis

## Considered Options

* Two endpoints
* One endpoint with the database check
* TCP probes only

## Decision Outcome

Chosen option: "Two endpoints", because it best meets the decision drivers (availability, diagnosis).

We will expose /api/health/live, which never checks the database, and /api/health, which returns 503 unless MongoDB is connected.

### Consequences

* Good, because the API recovers on its own when MongoDB returns
* Good, because probes, Compose and the smoke test share one signal
* Bad, because the switch to 503 can take about 20 s, because the driver notices on its heartbeat
* Bad, because a first connection is never retried, so start order matters

### Confirmation

With MongoDB stopped: readiness 503, liveness 200. Restarted: 200 with no API restart.

## Pros and Cons of the Options

### Two endpoints

* Good, because an outage stops traffic without restarts
* Good, because 503 names the failed dependency
* Bad, because a small change to upstream code

### One endpoint with the database check

* Good, because simple
* Bad, because an outage causes restart loops

### TCP probes only

* Good, because no code change
* Bad, because port open does not mean working

## More Information

Confidence: High.
Review by: When the API can scale out.
Trade-offs accepted: upstream code is changed and carried forward.
Components: Express, Mongoose.
Requirements addressed: REQ-05, REQ-07.
Part of the DevOps Platform architecture decision record.
