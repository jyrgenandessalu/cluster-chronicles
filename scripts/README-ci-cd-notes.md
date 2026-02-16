# CI/CD Pipeline Notes (Jenkins)

This project uses **Jenkins** running _inside the Kubernetes cluster_ to build Docker
images, scan them for vulnerabilities, and deploy them to the same cluster.

## Tools expected inside the Jenkins pod

The `Jenkinsfile` assumes the following CLIs are available in the Jenkins container
or its build agents:

- `docker` – build and push container images
- `trivy` – vulnerability scanning of built images
- `kubectl` – apply changes and manage rollouts in the cluster

For a local Minikube setup it is acceptable (for educational purposes) to:

- Mount the node Docker socket into the Jenkins pod and install the Docker CLI
- Install `kubectl` and `trivy` in the Jenkins image or via a custom agent image

## Registry assumptions

The pipeline expects a Docker registry (e.g. Docker Hub) and pushes images there:

- Environment variables in `Jenkinsfile`:
  - `REGISTRY` – e.g. `docker.io/<username>`
  - `BACKEND_IMAGE` – `${REGISTRY}/cluster-backend`
  - `FRONTEND_IMAGE` – `${REGISTRY}/cluster-frontend`

You must:

1. Create a registry account (e.g. Docker Hub).
2. Create a **Docker registry credential** in Jenkins with login details.
3. Configure the Jenkins global Docker daemon / login so `docker push` works from the pipeline.

## How the pipeline works (high level)

1. **Checkout**
   - Uses `checkout scm` to get this Git repo.
2. **Build images**
   - Builds `BACKEND_IMAGE:${BUILD_NUMBER}` from `./backend`.
   - Builds `FRONTEND_IMAGE:${BUILD_NUMBER}` from `./frontend`.
   - Pushes both images to the configured registry.
3. **Vulnerability scanning (Trivy)**
   - Runs `trivy image` on each built image.
   - Fails the pipeline (`--exit-code 1`) if **CRITICAL** vulnerabilities are found.
4. **Deploy to Kubernetes**
   - Uses `kubectl set image` to update:
     - `deployment/backend` container `backend`
     - `deployment/frontend` container `frontend`
   - Waits for rollouts via `kubectl rollout status`.

If any stage fails, the pipeline stops and reports which stage (build, scan, or deploy) broke.


