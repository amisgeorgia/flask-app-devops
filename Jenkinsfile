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
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - /busybox/cat
    tty: true
    # 👇 AJOUTE CES TROIS LIGNES ICI POUR DONNER LES DROITS D'ACCÈS
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /kaniko/.docker
      name: kaniko-secret
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  - name: kaniko-secret
    emptyDir: {}
'''
    }

  }

  triggers {
        pollSCM('* * * * *')
    }

  stages {
    stage('Test') {
      steps {
        container('python') {
          sh 'pip install -r requirements.txt'
          sh 'python test.py'
        }

      }
    }

    stage('Build Image') {
      steps {
        container('kaniko') {
          sh """
            /kaniko/executor \
            --context=dir://\${WORKSPACE} \
            --dockerfile=\${WORKSPACE}/Dockerfile \
            --destination=localhost:4000/flask_hello:latest \
            --insecure \
            --skip-tls-verify
          """
        }

      }
    }

    stage('Deploy') {
      steps {
        container('kubectl') {
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

}