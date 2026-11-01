---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Keep the API at one replica and autoscale Nginx instead

> In the context of DevOps Platform, facing the support chat keeps online users in API memory, and Socket.IO's handshake needs one pod to serve each client, we decided for one API pod, autoscale Nginx and neglected scale the API with a Redis adapter, scale the API with sticky sessions, to achieve correctness, cost, accepting that no horizontal scaling of the API until chat state moves out of memory.

## Context and Problem Statement

The support chat keeps online users in API memory, and Socket.IO's handshake needs one pod to serve each client. The first chart ran two API pods, which would have broken chat.

## Decision Drivers

* Correctness
* Cost

## Considered Options

* One API pod, autoscale Nginx
* Scale the API with a Redis adapter
* Scale the API with sticky sessions

## Decision Outcome

Chosen option: "One API pod, autoscale Nginx", because it best meets the decision drivers (correctness, cost).

We will run one API replica and put the HorizontalPodAutoscaler on Nginx (1-3 pods locally, 2-4 on EC2).

### Consequences

* Good, because correct behaviour for signed-in users
* Good, because stateless tier scales by CPU
* Bad, because a busy API has nowhere to scale
* Bad, because chat connections drop briefly in a restart

### Confirmation

HPA reads live metrics; rolling check 116 of 116 at one API replica.

## Pros and Cons of the Options

### One API pod, autoscale Nginx

* Good, because chat keeps working
* Good, because no new components
* Good, because rolling update still gives 0 failures
* Bad, because the API can't scale out
* Bad, because API is a single point of failure

### Scale the API with a Redis adapter

* Good, because true API scaling
* Bad, because code change and another stateful service

### Scale the API with sticky sessions

* Good, because no Redis
* Bad, because online lists still split per pod

## More Information

Confidence: High.
Review by: When chat moves to a shared adapter.
Trade-offs accepted: no horizontal scaling of the API until chat state moves out of memory.
Components: HorizontalPodAutoscaler.
Requirements addressed: REQ-05, REQ-06.
Part of the DevOps Platform architecture decision record.
