pipeline {
    agent any

    environment {
        // For local Minikube, skip registry push. Images are available locally.
        // To push to Docker Hub, set SKIP_PUSH=false and configure Docker Hub credentials in Jenkins.
        SKIP_PUSH       = 'true'  // Set to 'false' to enable Docker Hub push
        REGISTRY       = 'docker.io/jurgen123'   // e.g. docker.io/jurgen
        BACKEND_IMAGE  = "${env.REGISTRY}/cluster-backend"
        FRONTEND_IMAGE = "${env.REGISTRY}/cluster-frontend"

        // Minimal severity policy: fail on CRITICAL vulns.
        TRIVY_SEVERITY = 'CRITICAL'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend Image') {
            steps {
                sh '''
                  set -e
                  TAG=${BUILD_NUMBER:-latest}
                  echo "Building backend image: ${BACKEND_IMAGE}:${TAG}"
                  docker build -t ${BACKEND_IMAGE}:${TAG} ./backend
                  if [ "${SKIP_PUSH}" != "true" ]; then
                    echo "Pushing ${BACKEND_IMAGE}:${TAG} to registry..."
                    docker push ${BACKEND_IMAGE}:${TAG}
                  else
                    echo "Skipping push (local build mode)"
                  fi
                  echo "${BACKEND_IMAGE}:${TAG}" > backend-image.txt
                '''
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh '''
                  set -e
                  TAG=${BUILD_NUMBER:-latest}
                  echo "Building frontend image: ${FRONTEND_IMAGE}:${TAG}"
                  docker build -t ${FRONTEND_IMAGE}:${TAG} ./frontend
                  if [ "${SKIP_PUSH}" != "true" ]; then
                    echo "Pushing ${FRONTEND_IMAGE}:${TAG} to registry..."
                    docker push ${FRONTEND_IMAGE}:${TAG}
                  else
                    echo "Skipping push (local build mode)"
                  fi
                  echo "${FRONTEND_IMAGE}:${TAG}" > frontend-image.txt
                '''
            }
        }

        stage('Vulnerability Scan (Trivy)') {
            steps {
                sh '''
                  set -e
                  TAG=${BUILD_NUMBER:-latest}
                  BACKEND="${BACKEND_IMAGE}:${TAG}"
                  FRONTEND="${FRONTEND_IMAGE}:${TAG}"

                  echo "Scanning backend image ${BACKEND}"
                  trivy image --severity ${TRIVY_SEVERITY} --exit-code 1 "${BACKEND}"

                  echo "Scanning frontend image ${FRONTEND}"
                  trivy image --severity ${TRIVY_SEVERITY} --exit-code 1 "${FRONTEND}"
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                  set -e
                  TAG=${BUILD_NUMBER:-latest}
                  BACKEND="${BACKEND_IMAGE}:${TAG}"
                  FRONTEND="${FRONTEND_IMAGE}:${TAG}"

                  echo "Updating backend deployment image to ${BACKEND}"
                  kubectl set image deployment/backend backend=${BACKEND} --record || kubectl apply -f manifests/backend/

                  echo "Updating frontend deployment image to ${FRONTEND}"
                  kubectl set image deployment/frontend frontend=${FRONTEND} --record || kubectl apply -f manifests/frontend/

                  echo "Deployments after update:"
                  kubectl rollout status deployment/backend
                  kubectl rollout status deployment/frontend
                '''
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed – check above logs for failing stage (build, scan, or deploy).'
        }
        success {
            echo 'Pipeline succeeded – images built, scanned, and rolled out to Kubernetes.'
        }
    }
}


