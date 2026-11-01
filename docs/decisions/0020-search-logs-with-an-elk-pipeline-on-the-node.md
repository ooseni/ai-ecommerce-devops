---
status: "accepted"
date: 2026-11-01
decision-makers: Oseni Sakariyau Oluwadamilare
---

# Search logs with an ELK pipeline on the node

> In the context of DevOps Platform, facing application errors must be searchable, we decided for ELK on EC2 and neglected grafana Loki, Amazon CloudWatch Logs, to achieve observability, footprint, accepting that a t3.large instead of something smaller, and login disabled inside the cluster.

## Context and Problem Statement

Application errors must be searchable. The project calls for the ELK stack. Elasticsearch needs more memory than the laptop can spare.

## Decision Drivers

* Observability
* Footprint

## Considered Options

* ELK on EC2
* Grafana Loki
* Amazon CloudWatch Logs

## Decision Outcome

Chosen option: "ELK on EC2", because it best meets the decision drivers (observability, footprint).

We will run Filebeat, Logstash, Elasticsearch and Kibana 8.19.5 from plain manifests on EC2, with limits, marking errors in Logstash.

### Consequences

* Good, because outage errors appeared in Kibana
* Good, because logs stay inside the cluster
* Bad, because elasticsearch has no login; a NetworkPolicy is the only barrier
* Bad, because logs are lost when the environment is destroyed

### Confirmation

1,630 lines indexed within minutes; indexed errors rose from 15 to 20 in the drill; both searches imported.

## Pros and Cons of the Options

### ELK on EC2

* Good, because full-text search
* Good, because field-based saved searches
* Good, because teaches a common stack
* Bad, because about 3.5 GiB of memory limits
* Bad, because single-node, no replicas

### Grafana Loki

* Good, because much lighter
* Good, because fits with Grafana
* Bad, because the project calls for ELK
* Bad, because label-based, weaker text search

### Amazon CloudWatch Logs

* Good, because managed
* Bad, because ingestion cost
* Bad, because not portable

## More Information

Confidence: Medium.
Review by: If memory pressure appears.
Trade-offs accepted: a t3.large instead of something smaller, and login disabled inside the cluster.
Components: Elasticsearch, Logstash, Filebeat, Kibana.
Requirements addressed: REQ-07, REQ-06.
Part of the DevOps Platform architecture decision record.
