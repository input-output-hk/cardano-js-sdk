/*
#!/bin/bash

# Load NVM as jenkins user
. ~/.nvm/nvm.sh

#!/bin/bash
set -e

Cleanup() {
  cd sl && sh stop.sh && cd ..
  rm -r sl
}

trap Cleanup EXIT

# Clone the cardano-sl directory
git clone https://github.com/Sam-Jeston/cardano-byron-docker.git sl

# Install node modules
npm i

# Start the local nodes
cd sl && sh start.sh && cd ..

# Run the test suite
npm test
*/
pipeline {
    agent any

    tools {nodejs "Node 10"}

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
        post {
          always {
            sh 'cd sl && sh stop.sh && cd ..'
            sh 'rm -r sl'
          }
        }
    }
}