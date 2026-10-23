# AI-Powered E-Commerce DevOps Platform

Cloud-native delivery platform for a MERN e-commerce app: CI/CD with Jenkins, Docker, Kubernetes (k3s) and Helm, AWS infrastructure built with Terraform and Ansible, monitoring with Prometheus and Grafana, logging with ELK, DevSecOps scans, and AI-assisted incident analysis.

## The problem

Shipping an online shop by hand is slow and risky: servers are configured manually, releases cause downtime, secrets leak into code, and when something breaks at 2 a.m. nobody knows where to look.

## The solution

One connected pipeline that takes every change from a pull request to a running, monitored deployment:

- **Build and test** on every push (Jenkins, plus a basic GitHub Actions check)
- **Scan** for leaked secrets, vulnerable dependencies and image CVEs (gitleaks, npm audit, Trivy)
- **Package** the app as container images in GitHub Container Registry
- **Provision** AWS infrastructure as code (Terraform) and configure it (Ansible)
- **Deploy** to Kubernetes with Helm, using rolling and blue-green releases
- **Observe** metrics (Prometheus, Grafana) and logs (Elasticsearch, Logstash, Kibana)
- **Diagnose** incidents with an AI tool that reads the error logs

## Roadmap

- ⬜ **M0 Foundation**: toolchain, repository, branch protection, secret scanning, app import
- ⬜ **M1 App analysis and Bash**: run the app natively, document it, automation scripts
- ⬜ **M2 Containers**: Dockerfiles, Nginx reverse proxy, Docker Compose
- ⬜ **M3 CI/CD and DevSecOps**: Jenkins pipeline, security scans, images pushed to GHCR
- ⬜ **M4 Kubernetes and Helm**: manifests and a Helm chart deployed to a local k3d cluster
- ⬜ **M5 Infrastructure as code**: Terraform and Ansible build a k3s server on AWS EC2
- ⬜ **M6 Observability**: Prometheus and Grafana metrics, ELK log pipeline
- ⬜ **M7 AI incident analysis**: log-driven diagnosis and a blue-green release
- ⬜ **M8 Report**: architecture diagram, documentation, v1.0.0 release

## License

Released under the [MIT License](LICENSE).
