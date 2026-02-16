# Cluster Chronicles

Kubernetes migration of the sherlock-logs infrastructure from VM-based deployment (Vagrant/Ansible) to a fully containerized, Kubernetes-native environment using Minikube.

## Project Overview

This project demonstrates a complete Kubernetes migration, including:
- **Applications**: Flask backend (1 replica) and frontend (2 replicas)
- **CI/CD**: Jenkins pipeline with image building, vulnerability scanning, and deployment
- **Monitoring**: Prometheus + Grafana with 3 dashboards
- **Logging**: EFK stack (Elasticsearch, Fluentd, Kibana) with centralized log aggregation
- **Alerting**: 11 Prometheus alerts with Alertmanager integration
- **Security**: Network policies, RBAC, namespaces
- **Storage**: Persistent volumes for CI/CD, monitoring, and logging data

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Minikube Cluster                          │
│                                                               │
│  ┌──────────────┐    ┌──────────────┐                       │
│  │   Frontend   │───▶│   Backend    │                       │
│  │  (2 replicas)│    │ (1 replica)  │                       │
│  └──────┬───────┘    └──────┬───────┘                       │
│         │                   │                                │
│         └─────────┬─────────┘                                │
│                   │                                           │
│  ┌────────────────────────────────────────────┐             │
│  │         Ingress (frontend.local)           │             │
│  └────────────────────────────────────────────┘             │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Prometheus  │─▶│   Grafana    │  │ Alertmanager │      │
│  │  (scraping)  │  │ (dashboards) │  │  (alerts)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Elasticsearch│◀──│   Fluentd    │  │   Kibana     │      │
│  │  (indices)   │  │ (log collect)│  │ (dashboards) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐                                           │
│  │   Jenkins    │  (CI/CD pipeline)                         │
│  └──────────────┘                                           │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │Node Exporter │  │   cAdvisor    │  (metrics exporters)    │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
cluster-chronicles/
├── backend/                    # Backend Flask application
│   ├── app.py                 # Flask app with metrics endpoint
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/                   # Frontend Flask application
│   ├── app.py                  # Flask app with dashboard
│   ├── requirements.txt
│   └── Dockerfile
├── manifests/                  # Kubernetes manifests
│   ├── backend/               # Backend deployment, service, configmap
│   ├── frontend/              # Frontend deployment, service, ingress, configmap
│   ├── storage/               # PVs and PVCs (CI/CD, monitoring, logging)
│   ├── monitoring/            # Prometheus, Grafana, Alertmanager, exporters
│   ├── logging/               # Elasticsearch, Fluentd, Kibana
│   ├── cicd/                  # Jenkins deployment, RBAC
│   ├── namespaces/            # Namespace definitions
│   └── security/              # Network policies
├── scripts/                    # Setup and utility scripts
│   ├── setup-kibana-dashboards.sh
│   └── setup-elasticsearch-ilm.sh
├── Jenkinsfile                # CI/CD pipeline definition
├── documentation.md           # Detailed progress documentation
└── README.md                  # This file
```

## Prerequisites

- **Windows 10/11** (or Linux/macOS)
- **Minikube** v1.37.0+ ([Installation Guide](https://minikube.sigs.k8s.io/docs/start/))
- **kubectl** v1.34.0+ ([Installation Guide](https://kubernetes.io/docs/tasks/tools/))
- **Docker** (for building images)
- **VirtualBox** or **Hyper-V** (for Minikube VM)
- **PowerShell** or **Bash** terminal

### Installation on Windows

```powershell
# Install kubectl
winget install -e --id Kubernetes.kubectl

# Install Minikube
winget install -e --id Kubernetes.minikube

# Restart PowerShell to refresh PATH
```

## Setup Instructions

### 1. Start Minikube Cluster

```powershell
# Start Minikube (creates VM with 2 CPUs, 6GB RAM, 20GB disk)
minikube start

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster is running
kubectl get nodes
kubectl get pods -A
```

### 2. Build Application Images

```powershell
# Build images inside Minikube's Docker daemon
minikube image build -t backend:latest .\backend
minikube image build -t frontend:latest .\frontend

# Verify images
minikube image ls | grep -E "backend|frontend"
```

### 3. Deploy Infrastructure Components

```powershell
# Deploy namespaces
kubectl apply -f manifests/namespaces/

# Deploy persistent storage
kubectl apply -f manifests/storage/

# Deploy backend and frontend
kubectl apply -f manifests/backend/
kubectl apply -f manifests/frontend/

# Deploy monitoring stack
kubectl apply -f manifests/monitoring/

# Deploy logging stack
kubectl apply -f manifests/logging/

# Deploy CI/CD
kubectl apply -f manifests/cicd/

# Deploy network policies
kubectl apply -f manifests/security/
```

### 4. Configure Log Rotation (Optional)

```powershell
# Run script to configure Elasticsearch ILM
bash scripts/setup-elasticsearch-ilm.sh
```

### 5. Verify Deployment

```powershell
# Check all pods are running
kubectl get pods -A

# Check services
kubectl get svc -A

# Check ingress
kubectl get ingress
```

## Usage

### Accessing Services

Get Minikube IP:
```powershell
minikube ip
# Example output: 192.168.59.101
```

#### Application Access

1. **Frontend** (via Ingress):
   - Add to `C:\Windows\System32\drivers\etc\hosts`:
     ```
     192.168.59.101  frontend.local
     ```
   - Access: `http://frontend.local/`

2. **Backend** (internal only):
   ```powershell
   kubectl port-forward svc/backend 5000:5000
   # Access: http://localhost:5000
   ```

#### Monitoring Access

1. **Prometheus**:
   ```powershell
   kubectl port-forward svc/prometheus 9090:9090
   # Access: http://localhost:9090
   ```
   Or via NodePort: `http://<minikube-ip>:30900`

2. **Grafana**:
   ```powershell
   kubectl port-forward svc/grafana 3000:3000
   # Access: http://localhost:3000 (admin/admin)
   ```
   Or via NodePort: `http://<minikube-ip>:30300`

3. **Alertmanager**:
   ```powershell
   kubectl port-forward svc/alertmanager 9093:9093
   # Access: http://localhost:9093
   ```
   Or via NodePort: `http://<minikube-ip>:30903`

#### Logging Access

1. **Kibana**:
   ```powershell
   kubectl port-forward svc/kibana 5601:5601
   # Access: http://localhost:5601
   ```
   Or via NodePort: `http://<minikube-ip>:30601`

2. **Elasticsearch** (API):
   ```powershell
   kubectl port-forward svc/elasticsearch 9200:9200
   # Access: http://localhost:9200
   ```

#### CI/CD Access

1. **Jenkins**:
   ```powershell
   kubectl port-forward svc/jenkins 8080:8080
   # Access: http://localhost:8080
   ```
   Or via NodePort: `http://<minikube-ip>:32080`

### Common kubectl Commands

```powershell
# View all resources
kubectl get all -A

# View pods
kubectl get pods
kubectl get pods -l app=backend
kubectl get pods -l app=frontend

# View logs
kubectl logs -l app=backend
kubectl logs -l app=frontend --tail=50

# Describe resources
kubectl describe pod <pod-name>
kubectl describe svc backend

# Execute commands in pods
kubectl exec -it <pod-name> -- /bin/sh

# Scale deployments
kubectl scale deployment frontend --replicas=3

# View events
kubectl get events --sort-by='.lastTimestamp'

# Check resource usage
kubectl top nodes
kubectl top pods
```

### Setting Up Kibana Dashboards

The 3 required Kibana dashboards need to be created through the Kibana UI:

1. Access Kibana: `http://<minikube-ip>:30601/`
2. Navigate to **Dashboard** → **Create Dashboard**
3. Create these dashboards:
   - **Cluster Logs Dashboard**: Log volume, logs by namespace/pod, error counts
   - **Application Logs Dashboard**: Application-specific logs, HTTP requests, errors
   - **Pod and Container Logs Dashboard**: Per-pod logs, container streams, recent entries
4. See `scripts/setup-kibana-dashboards.sh` for detailed instructions

## Features

### Core Features

- ✅ **Kubernetes-native deployments** with proper resource management
- ✅ **Persistent storage** (PVs/PVCs) for CI/CD, monitoring, and logging
- ✅ **Comprehensive monitoring** with Prometheus and Grafana (3 dashboards)
- ✅ **Centralized logging** with EFK stack (Elasticsearch, Fluentd, Kibana)
- ✅ **Automated CI/CD pipeline** (Jenkins with Gitea integration)
- ✅ **Alerting system** (11 Prometheus alerts with Alertmanager)
- ✅ **Network policies** for pod-to-pod communication security
- ✅ **RBAC** configured for CI/CD and logging components
- ✅ **Namespaces** organized by component type

### Monitoring Dashboards

1. **Cluster Performance Dashboard**: Node CPU, memory, disk usage
2. **Pod and Container Dashboard**: Per-pod/container resource usage
3. **Application Performance Dashboard**: HTTP request metrics from Flask apps

### Alerting

11 configured alerts covering:
- Node metrics (CPU, memory, disk)
- Pod/container health (restarts, pending state)
- Application availability
- Monitoring system health
- Logging system health (Elasticsearch, Fluentd)

### Security

- **Network Policies**: Restrict pod-to-pod communication
- **RBAC**: ServiceAccounts, Roles, RoleBindings for least privilege
- **Namespaces**: Logical separation of components
- **Secrets Management**: No plaintext secrets in manifests

## Troubleshooting

### Pod in CrashLoopBackOff

```powershell
# Check pod logs
kubectl logs <pod-name>

# Describe pod for events
kubectl describe pod <pod-name>

# Check resource constraints
kubectl top pod <pod-name>
```

### Pod in Pending State

```powershell
# Check why pod can't be scheduled
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes
kubectl describe node minikube

# Check PVC binding
kubectl get pvc
kubectl describe pvc <pvc-name>
```

### Service Not Connecting

```powershell
# Verify service endpoints
kubectl get endpoints <service-name>

# Test DNS resolution
kubectl run -it --rm debug --image=busybox -- nslookup <service-name>

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>
```

### Storage Issues

```powershell
# Check PV/PVC binding
kubectl get pv
kubectl get pvc

# Check pod volume mounts
kubectl describe pod <pod-name> | grep -A 10 Mounts
```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)


