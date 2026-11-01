---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Manage AWS with Terraform, S3 state and reviewed plans

> In the context of DevOps Platform, facing the environment must be rebuilt repeatedly, we decided for Terraform, S3 native lock and neglected Terraform, S3 and DynamoDB lock, Terraform with local state, AWS CloudFormation, to achieve reproducibility, safety, accepting that a separate bootstrap stack, whose own state stays local.

## Context and Problem Statement

The environment must be rebuilt repeatedly. State must survive the laptop, which loses power, and a change must be readable before it is applied.

## Decision Drivers

* Reproducibility
* Safety

## Considered Options

* Terraform, S3 native lock
* Terraform, S3 and DynamoDB lock
* Terraform with local state
* AWS CloudFormation

## Decision Outcome

Chosen option: "Terraform, S3 native lock", because it best meets the decision drivers (reproducibility, safety).

We will use Terraform with versioned, encrypted S3 state and S3's native lock file, and apply only saved plans that have been read.

### Consequences

* Good, because a power cut can't lose the state
* Good, because nothing changes unless a plan was read
* Bad, because applying needs a person to read and run each plan
* Bad, because the state bucket stays after a destroy, at very small cost

### Confirmation

Plans of 9, 1 and 10 additions and 10 destructions reviewed and applied as saved; 0 items left in state.

## Pros and Cons of the Options

### Terraform, S3 native lock

* Good, because no lock table to run
* Good, because works across clouds
* Good, because plans can be read and saved
* Bad, because state bucket needs a bootstrap step

### Terraform, S3 and DynamoDB lock

* Good, because long-established pattern
* Bad, because an extra table, now unnecessary

### Terraform with local state

* Good, because no bucket
* Bad, because state lost with the laptop

### AWS CloudFormation

* Good, because no state to manage
* Bad, because AWS only
* Bad, because the project calls for Terraform

## More Information

Confidence: High.
Review by: 2027-06.
Trade-offs accepted: a separate bootstrap stack, whose own state stays local.
Components: Terraform 1.17, Amazon S3.
Requirements addressed: REQ-02, REQ-10.
Part of the DevOps Platform architecture decision record.
