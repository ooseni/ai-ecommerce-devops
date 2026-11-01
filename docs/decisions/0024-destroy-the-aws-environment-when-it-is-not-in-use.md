---
status: "accepted"
date: 2026-10-23
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Destroy the AWS environment when it is not in use

> In the context of DevOps Platform, facing a t3.large and Elastic IP cost about US$66 a month if left on (indicative), far above the US$5-15 budget, we decided for destroy when idle and neglected stop the instance, leave it running, to achieve cost, accepting that no always-on demo; screenshots and tests are the lasting evidence.

## Context and Problem Statement

A t3.large and Elastic IP cost about US$66 a month if left on (indicative), far above the US$5-15 budget. Nothing needs to run overnight.

## Decision Drivers

* Cost

## Considered Options

* Destroy when idle
* Stop the instance
* Leave it running

## Decision Outcome

Chosen option: "Destroy when idle", because it best meets the decision drivers (cost).

We will destroy the environment after each use, and keep only the small state bucket, relying on the rebuild path to bring it back.

### Consequences

* Good, because estimated US$0.20 for about 2 hours
* Good, because every use repeats the rebuild
* Bad, because addresses in old screenshots stop working
* Bad, because the Budgets alert is removed along with the environment

### Confirmation

After destroy: 0 instances, VPCs, Elastic IPs and volumes; 0 items in state; one 310-byte object in S3.

## Pros and Cons of the Options

### Destroy when idle

* Good, because no idle cost
* Good, because keeps the rebuild path proven
* Bad, because data and dashboards are lost
* Bad, because no public demo address

### Stop the instance

* Good, because keeps data
* Bad, because disk and address still cost money

### Leave it running

* Good, because always available
* Bad, because exceeds the budget within days

## More Information

Confidence: High.
Review by: If an always-on demo is needed.
Assumptions: Cost figures are estimates from on-demand rates; the final bill was not available at the time of writing.
Trade-offs accepted: no always-on demo; screenshots and tests are the lasting evidence.
Components: Terraform, AWS Budgets.
Requirements addressed: REQ-06.
Part of the DevOps Platform architecture decision record.
