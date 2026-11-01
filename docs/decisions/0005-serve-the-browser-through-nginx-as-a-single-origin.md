---
status: "accepted"
date: 2026-10-28
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Serve the browser through Nginx as a single origin

> In the context of DevOps Platform, facing the browser needs both static files and the API, we decided for Nginx as single origin and neglected publish client and API separately, express serves the build, to achieve security, simplicity, accepting that Nginx resolves server at start-up, so it fails to start if the name is missing.

## Context and Problem Statement

The browser needs both static files and the API. webpack bakes the API address in at build time, and the API should not be exposed directly.

## Decision Drivers

* Security
* Simplicity

## Considered Options

* Nginx as single origin
* Publish client and API separately
* Express serves the build

## Decision Outcome

Chosen option: "Nginx as single origin", because it best meets the decision drivers (security, simplicity).

We will serve the React build from Nginx and proxy /api/ and /socket.io/ to the API, with API_URL set to the relative path /api.

### Consequences

* Good, because only one port is published
* Good, because hashed assets cached for a year; index.html never cached
* Bad, because upstream's localhost shortcut breaks chat at localhost:8080
* Bad, because Nginx waits on a stopped API for 60 s by default, so a user can wait on a failure

### Confirmation

API health through Nginx reports db connected; React route returns 200; Server header hides the version.

## Pros and Cons of the Options

### Nginx as single origin

* Good, because no CORS
* Good, because one image works on any host
* Good, because API stays private
* Bad, because one more hop
* Bad, because Nginx needs the API's name at start

### Publish client and API separately

* Good, because independent endpoints
* Bad, because CORS, and the address is baked into the build

### Express serves the build

* Good, because one container
* Bad, because node serves static files
* Bad, because no separate scaling

## More Information

Confidence: High.
Review by: When TLS is added.
Trade-offs accepted: Nginx resolves server at start-up, so it fails to start if the name is missing.
Components: Nginx 1.30.
Requirements addressed: REQ-09.
Part of the DevOps Platform architecture decision record.
