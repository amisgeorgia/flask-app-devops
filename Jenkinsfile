pipeline {
    agent {
        kubernetes {
            inheritFrom 'default'
            yaml """
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
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  - name: kaniko-secret
    emptyDir: {}
"""
        }
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {

        stage('Test') {
            steps {
                container('python') {
                    sh "pip install -r requirements.txt"
                    sh "python test.py"
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
                    sh "kubectl apply -f ./kubernetes/deployment.yaml"
                    sh "kubectl apply -f ./kubernetes/service.yaml"
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