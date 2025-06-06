pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "meitarturgeman/messages-api"
        IMAGE_TAG = "latest"
        K8S_NAMESPACE = "default"
        DEPLOYMENT_NAME = "myapp-deployment"
    }
    stages {
        stage('test') {
            steps {
                echo "Running tests with pytest..."
                sh "pip install --no-cache-dir -r requirements.txt"
                sh "pip install pytest"
                sh "pytest tests/"
            }
        }
        stage('build image') {
            steps {
                script {
                    echo "Building docker image..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    }
                }
            }
        }
        stage('deploy to kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    withEnv(["KUBECONFIG=$KUBECONFIG_FILE"]) {
                        sh """
                        kubectl set image deployment/${DEPLOYMENT_NAME} messages-api=${DOCKER_IMAGE}:${IMAGE_TAG} -n ${K8S_NAMESPACE}
                        kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${K8S_NAMESPACE}
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            echo "Pipeline completed successfully!"
            echo "Flask app deployed to Kubernetes."
        }
        failure {
            echo "Pipeline failed. Please check the logs for details."
        }
    }
}