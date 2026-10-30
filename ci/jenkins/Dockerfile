# Jenkins controller for the CI pipeline. It drives the host's Docker Engine
# through the mounted socket and carries the lint and security tools, each
# copied from its official image at a pinned version.
FROM aquasec/trivy:0.76.1 AS trivy
FROM zricethezav/gitleaks:v8.30.1 AS gitleaks
FROM hadolint/hadolint:v2.15.1 AS hadolint
FROM mvdan/shfmt:v3.14.1 AS shfmt

FROM jenkins/jenkins:2.580.2-lts-jdk21

USER root
# Docker CLI with the Compose and Buildx plugins, from Docker's apt repository.
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl jq shellcheck \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin docker-buildx-plugin \
  && rm -rf /var/lib/apt/lists/*

COPY --from=trivy /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=gitleaks /usr/bin/gitleaks /usr/local/bin/gitleaks
COPY --from=hadolint /bin/hadolint /usr/local/bin/hadolint
COPY --from=shfmt /bin/shfmt /usr/local/bin/shfmt

USER jenkins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
