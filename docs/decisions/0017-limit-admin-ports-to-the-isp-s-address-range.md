---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Limit admin ports to the ISP's address range

> In the context of DevOps Platform, facing SSH and the Kubernetes API must reach the node from a laptop whose public address changes: it changed within the same range inside an hour, we decided for allow the ISP's /24 and neglected allow one /32, AWS Systems Manager Session Manager, allow 0.0.0.0/0, to achieve security, reliability, accepting that other customers of the ISP can reach the ports, though they can't authenticate.

## Context and Problem Statement

SSH and the Kubernetes API must reach the node from a laptop whose public address changes: it changed within the same range inside an hour. A /32 rule could lock out Ansible mid-run.

## Decision Drivers

* Security
* Reliability

## Considered Options

* Allow the ISP's /24
* Allow one /32
* AWS Systems Manager Session Manager
* Allow 0.0.0.0/0

## Decision Outcome

Chosen option: "Allow the ISP's /24", because it best meets the decision drivers (security, reliability).

We will allow ports 22 and 6443 from my ISP's /24 range, and rely on the SSH key and API client certificate for authentication.

### Consequences

* Good, because stable through address changes during long runs
* Good, because a /24 is simple to read in a review
* Bad, because the range is hard-coded for this ISP in terraform.tfvars
* Bad, because if the ISP changes range, access stops until a re-apply

### Confirmation

Plan shows the /24 on both rules; SSH passwords read back as off; admin access worked throughout.

## Pros and Cons of the Options

### Allow the ISP's /24

* Good, because survives the address changing
* Good, because blocks almost all of the internet
* Bad, because shared with other customers of the ISP

### Allow one /32

* Good, because tightest rule
* Bad, because locks out mid-run when the address moves

### AWS Systems Manager Session Manager

* Good, because no inbound SSH at all
* Bad, because IAM role and agent to add
* Bad, because kubectl still needs a path

### Allow 0.0.0.0/0

* Good, because always works
* Bad, because exposes SSH and the API to everyone

## More Information

Confidence: Medium.
Review by: Move to Session Manager if this becomes long-lived.
Trade-offs accepted: other customers of the ISP can reach the ports, though they can't authenticate.
Components: Security group.
Requirements addressed: REQ-09.
Part of the DevOps Platform architecture decision record.
