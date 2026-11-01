// CI pipeline: lint the scripts and Dockerfiles, then build both images.
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
  }

  stages {
    stage('Lint') {
      steps {
        sh 'shellcheck scripts/*.sh'
        sh 'shfmt -d -i 2 scripts/*.sh'
        sh 'hadolint docker/server.Dockerfile docker/client.Dockerfile ci/jenkins/Dockerfile'
      }
    }

    stage('Build images') {
      steps {
        sh 'docker build -f docker/server.Dockerfile -t "$SERVER_IMAGE:$GIT_COMMIT" .'
        sh 'docker build -f docker/client.Dockerfile --build-arg API_URL=/api -t "$CLIENT_IMAGE:$GIT_COMMIT" .'
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
