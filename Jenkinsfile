// CI pipeline: lint, scan for secrets and known vulnerabilities, build both images,
// scan them, smoke-test them in a throwaway stack, and publish them to GHCR.
// Nothing below a failed stage runs.
pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  environment {
    SERVER_IMAGE = 'ghcr.io/ooseni/mern-shop-server'
    CLIENT_IMAGE = 'ghcr.io/ooseni/mern-shop-client'
    IMAGE_SOURCE = 'https://github.com/ooseni/ai-ecommerce-devops'
  }

  stages {
    stage('Lint') {
      steps {
        sh 'shellcheck scripts/*.sh'
        sh 'shfmt -d -i 2 scripts/*.sh'
        sh 'hadolint docker/server.Dockerfile docker/client.Dockerfile ci/jenkins/Dockerfile'
      }
    }

    // Any secret in the history fails the build, whatever its age.
    stage('Secret scan') {
      steps {
        sh 'gitleaks git --redact --no-banner .'
      }
    }

    // Gates on new critical findings; see ci/security-baseline.env.
    stage('Dependency audit') {
      steps {
        sh 'mkdir -p reports'
        sh 'scripts/npm-audit.sh application/server reports/npm-server.json'
        sh 'scripts/npm-audit.sh application/client reports/npm-client.json'
        sh 'scripts/security-gate.sh npm reports/npm-server.json npm_server'
        sh 'scripts/security-gate.sh npm reports/npm-client.json npm_client'
      }
    }

    stage('Build images') {
      steps {
        sh 'docker build -f docker/server.Dockerfile --label org.opencontainers.image.source="$IMAGE_SOURCE" -t "$SERVER_IMAGE:$GIT_COMMIT" .'
        sh 'docker build -f docker/client.Dockerfile --label org.opencontainers.image.source="$IMAGE_SOURCE" --build-arg API_URL=/api -t "$CLIENT_IMAGE:$GIT_COMMIT" .'
      }
    }

    stage('Image scan') {
      steps {
        sh 'trivy image --quiet --scanners vuln --severity CRITICAL,HIGH --format json -o reports/trivy-server.json "$SERVER_IMAGE:$GIT_COMMIT"'
        sh 'trivy image --quiet --scanners vuln --severity CRITICAL,HIGH --format json -o reports/trivy-client.json "$CLIENT_IMAGE:$GIT_COMMIT"'
        sh 'scripts/security-gate.sh trivy reports/trivy-server.json trivy_server'
        sh 'scripts/security-gate.sh trivy reports/trivy-client.json trivy_client'
      }
    }

    stage('Smoke test') {
      steps {
        sh 'scripts/ci-smoke.sh'
      }
    }

    // Only the long-lived branches publish. The tag is the commit SHA, so an image
    // in the registry always traces back to one commit that passed every stage above.
    stage('Push to GHCR') {
      when {
        anyOf {
          branch 'develop'
          branch 'main'
        }
      }
      environment {
        DOCKER_CONFIG = "${env.WORKSPACE_TMP}/docker"
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'ghcr', usernameVariable: 'GHCR_USER', passwordVariable: 'GHCR_TOKEN')]) {
          sh 'echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin'
        }
        sh 'docker push "$SERVER_IMAGE:$GIT_COMMIT"'
        sh 'docker push "$CLIENT_IMAGE:$GIT_COMMIT"'
      }
      post {
        always {
          sh 'docker logout ghcr.io'
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/*.json', allowEmptyArchive: true
      cleanWs()
    }
  }
}
