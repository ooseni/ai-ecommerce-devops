---
status: "accepted"
date: 2026-10-23
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Build the platform around a vendored open-source shop

> In the context of DevOps Platform, facing the goal is to deliver an application, not to write one, we decided for vendor mern-ecommerce and neglected write a small shop, use a polyglot microservices demo, to achieve time, realism, accepting that inherits upstream debt, including 227 known vulnerabilities.

## Context and Problem Statement

The goal is to deliver an application, not to write one. It needs a real API, database and front end, and must run with little configuration.

## Decision Drivers

* Time
* Realism

## Considered Options

* Vendor mern-ecommerce
* Write a small shop
* Use a polyglot microservices demo

## Decision Outcome

Chosen option: "Vendor mern-ecommerce", because it best meets the decision drivers (time, realism).

We will vendor mern-ecommerce at commit 7f73dfb under its MIT licence, and change it only where the platform requires.

### Consequences

* Good, because real problems appeared, such as chalk in devDependencies
* Good, because all effort went into the platform
* Bad, because the platform carries the app's limits, such as one API replica
* Bad, because vulnerabilities are measured rather than fixed

### Confirmation

Shop lists 100 seeded products through the full stack; changes to upstream are listed in the README credits.

## Pros and Cons of the Options

### Vendor mern-ecommerce

* Good, because real React, Express and MongoDB app
* Good, because runs with only MONGO_URI and JWT_SECRET
* Good, because MIT licence
* Bad, because old dependencies
* Bad, because no tests or health route

### Write a small shop

* Good, because clean, current code
* Bad, because takes time from the platform work
* Bad, because less realistic problems

### Use a polyglot microservices demo

* Good, because many services to orchestrate
* Bad, because too heavy for a 7 GB laptop

## More Information

Confidence: High.
Review by: If upstream is abandoned or relicensed.
Trade-offs accepted: inherits upstream debt, including 227 known vulnerabilities.
Components: mern-ecommerce.
Requirements addressed: REQ-10.
Part of the DevOps Platform architecture decision record.
