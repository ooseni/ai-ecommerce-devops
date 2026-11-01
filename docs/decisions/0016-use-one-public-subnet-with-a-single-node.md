---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Use one public subnet with a single node

> In the context of DevOps Platform, facing a multi-AZ design with private subnets is the normal pattern, but it needs NAT, load balancing and more nodes, which the budget and purpose do not justify, we decided for one public subnet, one node and neglected Multi-AZ, private subnets, NAT, ALB, public node with a default VPC, to achieve cost, simplicity, accepting that no high availability and a publicly addressable node, accepted for a project with no real users.

## Context and Problem Statement

A multi-AZ design with private subnets is the normal pattern, but it needs NAT, load balancing and more nodes, which the budget and purpose do not justify.

## Decision Drivers

* Cost
* Simplicity

## Considered Options

* One public subnet, one node
* Multi-AZ, private subnets, NAT, ALB
* Public node with a default VPC

## Decision Outcome

Chosen option: "One public subnet, one node", because it best meets the decision drivers (cost, simplicity).

We will use one VPC with one public subnet and one EC2 node with an Elastic IP, and rely on layered filtering instead of a private tier.

### Consequences

* Good, because simple to reason about and rebuild
* Good, because well inside budget
* Bad, because a node or zone failure stops everything until a rebuild
* Bad, because filtering is the only barrier, so it must be right

### Confirmation

Only 80 answers publicly; 22 and 6443 are limited; a rebuild takes 248 s after apply.

## Pros and Cons of the Options

### One public subnet, one node

* Good, because about US$0.09 an hour
* Good, because no NAT or load balancer
* Bad, because no zone resilience
* Bad, because the node has a public address

### Multi-AZ, private subnets, NAT, ALB

* Good, because the production pattern
* Good, because survives a zone loss
* Bad, because NAT and ALB cost more than the whole budget if left on (indicative)

### Public node with a default VPC

* Good, because least code
* Bad, because nothing for Terraform to prove
* Bad, because shared defaults

## More Information

Confidence: Medium.
Review by: Before any production use.
Trade-offs accepted: no high availability and a publicly addressable node, accepted for a project with no real users.
Components: Amazon VPC, Amazon EC2, Elastic IP.
Requirements addressed: REQ-06, REQ-09.
Part of the DevOps Platform architecture decision record.
