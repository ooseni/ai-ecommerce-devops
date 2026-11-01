---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Configure the node with Ansible roles

> In the context of DevOps Platform, facing after Terraform creates the node, it needs hardening, Docker and k3s, we decided for ansible roles and neglected Terraform user_data script, prebuilt AMI with Packer, to achieve reproducibility, security, accepting that a separate tool and step after Terraform.

## Context and Problem Statement

After Terraform creates the node, it needs hardening, Docker and k3s. The steps must be safe to repeat, because a connection can drop mid-run.

## Decision Drivers

* Reproducibility
* Security

## Considered Options

* Ansible roles
* Terraform user_data script
* Prebuilt AMI with Packer

## Decision Outcome

Chosen option: "Ansible roles", because it best meets the decision drivers (reproducibility, security).

We will use an Ansible playbook with common, hardening, docker and k3s roles, and save a kubeconfig that points at the public address.

### Consequences

* Good, because an interrupted run is cheap to repeat
* Good, because hardening can be read and reviewed
* Bad, because host key checking is off, because rebuilt nodes are new
* Bad, because the docker role installs an engine k3s does not need

### Confirmation

Second run: ok=21 changed=0. Fresh node: ok=23 changed=14 unreachable=0 in 136 s. sshd -T confirms the settings.

## Pros and Cons of the Options

### Ansible roles

* Good, because repeatable, and checks state first
* Good, because readable hardening steps
* Bad, because needs SSH from the laptop

### Terraform user_data script

* Good, because no SSH needed
* Bad, because runs once
* Bad, because failures are hard to see

### Prebuilt AMI with Packer

* Good, because fast boots
* Bad, because an image pipeline to maintain

## More Information

Confidence: High.
Review by: 2027-06.
Trade-offs accepted: a separate tool and step after Terraform.
Components: Ansible core 2.21, k3s installer.
Requirements addressed: REQ-02, REQ-09.
Part of the DevOps Platform architecture decision record.
