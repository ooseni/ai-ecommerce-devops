---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Run MongoDB in the cluster as a StatefulSet

> In the context of DevOps Platform, facing the shop needs MongoDB, we decided for StatefulSet in the cluster and neglected MongoDB Atlas, Amazon DocumentDB, to achieve cost, simplicity, accepting that no database high availability, and data is lost when the environment is destroyed.

## Context and Problem Statement

The shop needs MongoDB. Managed options cost money continuously or add a network dependency, and data here is only sample data.

## Decision Drivers

* Cost
* Simplicity

## Considered Options

* StatefulSet in the cluster
* MongoDB Atlas
* Amazon DocumentDB

## Decision Outcome

Chosen option: "StatefulSet in the cluster", because it best meets the decision drivers (cost, simplicity).

We will run mongo:7.0 as a one-replica StatefulSet on a persistent volume, reachable only by labelled pods.

### Consequences

* Good, because rebuilds need no external setup
* Good, because seed job restores sample data
* Bad, because one node's disk holds all data
* Bad, because mongosh probes need a generous timeout under a CPU limit

### Confirmation

mongo-0 Ready on both clusters; NetworkPolicy tested; API reconnects after a restart.

## Pros and Cons of the Options

### StatefulSet in the cluster

* Good, because no extra cost
* Good, because same on the laptop and AWS
* Bad, because no replication
* Bad, because backups are ours

### MongoDB Atlas

* Good, because managed, automated backups
* Bad, because external dependency and egress

### Amazon DocumentDB

* Good, because AWS-managed
* Bad, because well above this budget
* Bad, because not fully MongoDB

## More Information

Confidence: High.
Review by: Before holding any real data.
Trade-offs accepted: no database high availability, and data is lost when the environment is destroyed.
Components: MongoDB 7.0, StatefulSet.
Requirements addressed: REQ-02, REQ-06.
Part of the DevOps Platform architecture decision record.
