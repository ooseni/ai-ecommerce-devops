---
status: "accepted"
date: 2026-10-23
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Run k3s on EC2 and k3d on the laptop

> In the context of DevOps Platform, facing Kubernetes must run locally on 7 GB and on AWS within US$5-15, for one person, we decided for k3s and k3d and neglected Amazon EKS, kubeadm on EC2, to achieve cost, footprint, accepting that no managed control plane or multi-zone resilience, in exchange for cost.

## Context and Problem Statement

Kubernetes must run locally on 7 GB and on AWS within US$5-15, for one person. The same distribution in both keeps behaviour alike.

## Decision Drivers

* Cost
* Footprint

## Considered Options

* k3s and k3d
* Amazon EKS
* kubeadm on EC2

## Decision Outcome

Chosen option: "k3s and k3d", because it best meets the decision drivers (cost, footprint).

We will run k3s v1.36.5 on one EC2 node, and k3d with the same version locally.

### Consequences

* Good, because a complete cluster for about US$0.09 an hour
* Good, because one chart runs in both places
* Bad, because upgrades and control-plane failures are ours to handle
* Bad, because skills differ slightly from EKS

### Confirmation

Node Ready at v1.36.5+k3s1 on both; the shop passes its smoke test on both.

## Pros and Cons of the Options

### k3s and k3d

* Good, because same distribution in both places
* Good, because includes Traefik, metrics-server and local storage
* Bad, because we run the control plane
* Bad, because not highly available as built

### Amazon EKS

* Good, because managed control plane
* Good, because common in production
* Bad, because about US$73 a month for the control plane alone (indicative)
* Bad, because different from local

### kubeadm on EC2

* Good, because upstream Kubernetes
* Bad, because more setup and more memory

## More Information

Confidence: High.
Review by: If the system needs high availability.
Trade-offs accepted: no managed control plane or multi-zone resilience, in exchange for cost.
Components: k3s, k3d 5.9.0, Amazon EC2.
Requirements addressed: REQ-02, REQ-06.
Part of the DevOps Platform architecture decision record.
