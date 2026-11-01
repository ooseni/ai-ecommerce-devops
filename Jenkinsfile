// CI pipeline: lint, scan for secrets and known vulnerabilities, build both images
// and scan them. Nothing below a failed stage runs.
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
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/*.json', allowEmptyArchive: true
      cleanWs()
    }
  }
}
