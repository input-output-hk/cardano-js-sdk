pipeline {
  agent any

  tools {nodejs "Node 10"}

  // Lock concurrent builds due to the docker dependency
  options {
    lock resource: 'DockerJob'
    disableConcurrentBuilds()
  }

  stages {
    stage('Dependency Setup') {
      steps {
        sh 'git clone https://github.com/Sam-Jeston/cardano-byron-docker.git sl'
        sh 'cd sl && sh start.sh && cd ..'
      }
    }
    stage('Install') {
      steps {
        sh 'npm i'
      }
    }
    stage('Test') {
      steps {
        sh 'npm test'
      }
    }
  }
  post {
    always {
      sh 'cd sl && sh stop.sh && cd ..'
      sh 'rm -r sl'
    }
  }
}