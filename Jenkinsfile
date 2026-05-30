pipeline {
  agent {
    kubernetes {
      label 'jenkins-agent-flask'
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci
spec:
  containers:
  - name: python
    image: python:3.12-slim
    command:
    - cat
    tty: true
  - name: docker
    image: docker:24-dind
    command:
    - cat
    tty: true
    # 👇 AJOUTE CES TROIS LIGNES ICI POUR DONNER LES DROITS D'ACCÈS
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
'''
    }

  }
  stages {
    stage('Test') {
      steps {
        container(name: 'python') {
          sh 'pip install -r requirements.txt'
          sh 'python test.py'
        }

      }
    }

    stage('Build Image') {
      steps {
        container(name: 'docker') {
          sh 'docker build -t localhost:4000/flask_hello:latest .'
          sh 'docker push localhost:4000/flask_hello:latest'
        }

      }
    }

    stage('Deploy') {
      steps {
        container(name: 'kubectl') {
          sh 'kubectl apply -f ./kubernetes/deployment.yaml'
          sh 'kubectl apply -f ./kubernetes/service.yaml'
        }

      }
    }

  }
  post {
    success {
      echo '✅ Pipeline réussi !'
    }

    failure {
      echo '❌ Pipeline en échec !'
    }

  }
  triggers {
    pollSCM('* * * * *')
  }
}