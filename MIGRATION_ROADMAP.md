# 🚀 Cluster Chronicles - Roadmap with migration

## Overview

This document outlines the migration from **sherlock-logs** (VM-based infrastructure) to **cluster-chronicles** (Kubernetes-based infrastructure). It details what was integrated, what's new, and what was left behind.

---

## 📦 What Was Integrated from sherlock-logs

### ✅ Application Code (Migrated)

#### Backend Application
- **Location:** `backend/app.py`
- **Source:** `sherlock-logs/ansible/roles/backend_container/files/app/app.py`
- **Features:**
  - Flask REST API with Prometheus metrics
  - Structured JSON logging
  - `/metrics` endpoint for Prometheus scraping
  - CPU, memory, and system metrics
  - Health check endpoints

#### Frontend Application
- **Location:** `frontend/app.py`
- **Source:** `sherlock-logs/ansible/roles/frontend_container/files/app/app.py`
- **Features:**
  - Flask web application with HTML dashboard
  - Prometheus metrics integration
  - Structured JSON logging
  - `/dashboard` endpoint with real-time metrics visualization
  - CPU, memory, and disk metrics

#### Dockerfiles
- **Backend Dockerfile:** `backend/Dockerfile`
- **Frontend Dockerfile:** `frontend/Dockerfile`
- **Source:** `sherlock-logs/ansible/roles/*_container/files/Dockerfile`
- **Status:** ✅ Copied as-is (may need Kubernetes-specific adjustments)

#### Dependencies
- **Backend:** `backend/requirements.txt`
- **Frontend:** `frontend/requirements.txt`
- **Includes:**
  - Flask
  - prometheus_client
  - psutil
  - Other Python dependencies

#### Configuration Files
- **pyrightconfig.json:** Type checking configuration (if applicable)

---

## 🆕 What's New for Kubernetes

### Kubernetes Manifests (To Be Created)

#### Application Manifests
- **`manifests/backend/`**
  - `deployment.yaml` - Backend Deployment with replicas, resource limits, probes
  - `service.yaml` - ClusterIP Service for backend
  - `configmap.yaml` - Environment variables and configuration
  - `secret.yaml` - Sensitive data (if needed)

- **`manifests/frontend/`**
  - `deployment.yaml` - Frontend Deployment with replicas, resource limits, probes
  - `service.yaml` - ClusterIP/NodePort Service for frontend
  - `configmap.yaml` - Environment variables and configuration
  - `ingress.yaml` - Ingress resource for external access

#### Storage Manifests
- **`manifests/storage/`**
  - `persistentvolume.yaml` - PV for CI/CD data persistence
  - `persistentvolumeclaim.yaml` - PVC for Jenkins/CI tools
  - `persistentvolume-monitoring.yaml` - PV for Prometheus data
  - `persistentvolume-logging.yaml` - PV for Elasticsearch data

#### Monitoring Manifests
- **`manifests/monitoring/`**
  - `prometheus-deployment.yaml` - Prometheus Deployment
  - `prometheus-service.yaml` - Prometheus Service
  - `prometheus-configmap.yaml` - Prometheus scrape configuration
  - `prometheus-pvc.yaml` - Persistent storage for metrics
  - `grafana-deployment.yaml` - Grafana Deployment
  - `grafana-service.yaml` - Grafana Service (NodePort/LoadBalancer)
  - `grafana-configmap.yaml` - Grafana dashboards and datasources
  - `grafana-pvc.yaml` - Persistent storage for Grafana
  - `node-exporter-daemonset.yaml` - Node Exporter on all nodes
  - `cadvisor-daemonset.yaml` - cAdvisor for container metrics
  - `serviceaccount.yaml` - RBAC for Prometheus scraping
  - `role.yaml` - Permissions for metrics access
  - `rolebinding.yaml` - Bind role to service account
  - `alertmanager-deployment.yaml` - Alertmanager for alert routing
  - `alertmanager-service.yaml` - Alertmanager Service
  - `alertmanager-configmap.yaml` - Alert routing rules

#### Logging Manifests
- **`manifests/logging/`**
  - `elasticsearch-statefulset.yaml` - Elasticsearch StatefulSet (3 replicas)
  - `elasticsearch-service.yaml` - Elasticsearch Service
  - `elasticsearch-pvc.yaml` - Persistent storage for indices
  - `kibana-deployment.yaml` - Kibana Deployment
  - `kibana-service.yaml` - Kibana Service
  - `fluentd-daemonset.yaml` - Fluentd/Fluent Bit for log collection
  - `fluentd-configmap.yaml` - Log parsing and routing rules
  - `filebeat-daemonset.yaml` - Alternative: Filebeat for log shipping

#### CI/CD Manifests
- **`manifests/cicd/`**
  - `jenkins-deployment.yaml` - Jenkins Deployment
  - `jenkins-service.yaml` - Jenkins Service (NodePort)
  - `jenkins-pvc.yaml` - Persistent storage for Jenkins data
  - `jenkins-configmap.yaml` - Jenkins configuration
  - `jenkins-serviceaccount.yaml` - Service account for Jenkins
  - `jenkins-role.yaml` - RBAC for Jenkins to deploy to cluster
  - `jenkins-rolebinding.yaml` - Bind permissions
  - `gitlab-runner-deployment.yaml` - Alternative: GitLab Runner (optional)

#### Networking
- **Ingress Controller:**
  - NGINX Ingress Controller (via Helm or manifest)
  - Ingress rules for frontend, Grafana, Kibana

#### Security
- **Network Policies:**
  - Restrict pod-to-pod communication
  - Allow only necessary traffic
  - Isolate monitoring/logging namespaces

---

## ❌ What Was Left Behind (VM-Specific)

### Infrastructure Automation (Not Migrated)

#### Vagrant Configuration
- **`Vagrantfile`** - VM definitions and networking
- **Reason:** Kubernetes uses Minikube, not VMs
- **Replacement:** `minikube start` and kubectl commands

#### Ansible Playbooks
- **`ansible/`** directory (entire structure)
  - `ansible/site.yml` - Main playbook
  - `ansible/deploy.yml` - Deployment playbook
  - `ansible/inventory.ini` - VM inventory
  - `ansible/roles/` - All Ansible roles:
    - `common/` - Common VM setup (apt, firewall, etc.)
    - `docker/` - Docker installation
    - `backend_container/` - Backend deployment (code migrated, automation not)
    - `frontend_container/` - Frontend deployment (code migrated, automation not)
    - `nginx_lb/` - NGINX load balancer setup
    - `jenkins/` - Jenkins installation and configuration
    - `monitoring/` - Prometheus, Grafana, Node Exporter, cAdvisor setup
    - `filebeat/` - Filebeat installation
    - `cadvisor/` - cAdvisor installation
    - `node_exporter/` - Node Exporter installation
    - `gitea/` - Gitea setup (if used)
- **Reason:** Kubernetes uses manifests and Helm charts, not Ansible
- **Replacement:** Kubernetes manifests and `kubectl apply`

#### VM-Specific Services
- **Systemd services** - All systemd unit files
- **UFW firewall rules** - VM-level firewall configuration
- **SSH key management** - VM SSH setup
- **VM networking** - Static IP assignments (192.168.56.x)
- **Reason:** Kubernetes handles service management, networking, and security differently

#### VM Monitoring Scripts
- **`ansible/roles/monitoring/files/create_grafana_alerts.py`**
  - **Status:** Logic can be reused, but needs Kubernetes adaptation
  - **Note:** Grafana alert provisioning may use different methods in K8s
- **`ansible/roles/monitoring/files/elasticsearch_health_exporter.py`**
  - **Status:** Can be containerized and deployed as a sidecar or separate pod
  - **Note:** Will need Kubernetes Deployment manifest

#### Documentation (Reference Only)
- **`REQUIREMENTS_TESTING.md`** - VM-specific testing procedures
- **`verify-requirements.ps1`** - PowerShell script for VM testing
- **`documentation.md`** - VM infrastructure documentation
- **`sherlock-logs-roadmap.md`** - Original project roadmap
- **Reason:** These are specific to the VM setup
- **Note:** Can be referenced for understanding requirements, but testing procedures will differ

---

## 🗺️ Kubernetes Migration Roadmap

### Phase 1: Local Kubernetes Setup ✅ (In Progress)
- [x] Create repository structure
- [x] Copy application code
- [x] Create `.gitignore` and `README.md`
- [ ] Initialize Git repository
- [ ] Set up Minikube cluster
- [ ] Verify kubectl access

### Phase 2: Application Deployment
- [ ] Create backend Deployment and Service manifests
- [ ] Create frontend Deployment and Service manifests
- [ ] Build and push container images (or use local registry)
- [ ] Deploy backend application
- [ ] Deploy frontend application
- [ ] Test application connectivity
- [ ] Configure Ingress for external access

### Phase 3: Persistent Storage
- [ ] Create PersistentVolume manifests
- [ ] Create PersistentVolumeClaim manifests
- [ ] Configure storage for CI/CD tools
- [ ] Configure storage for monitoring data
- [ ] Configure storage for logging data
- [ ] Test data persistence across pod restarts

### Phase 4: Monitoring Stack
- [ ] Deploy Prometheus (Deployment + Service + ConfigMap)
- [ ] Deploy Grafana (Deployment + Service + ConfigMap)
- [ ] Deploy Node Exporter (DaemonSet)
- [ ] Deploy cAdvisor (DaemonSet)
- [ ] Configure Prometheus scrape jobs
- [ ] Set up Grafana datasources
- [ ] Import Grafana dashboards
- [ ] Configure Grafana alerts
- [ ] Deploy Alertmanager (optional)

### Phase 5: Logging Stack
- [ ] Deploy Elasticsearch (StatefulSet for multi-node)
- [ ] Deploy Kibana (Deployment + Service)
- [ ] Deploy Fluentd/Fluent Bit (DaemonSet)
- [ ] Configure log collection and parsing
- [ ] Set up Kibana index patterns
- [ ] Create Kibana dashboards
- [ ] Test log aggregation

### Phase 6: CI/CD Pipeline
- [ ] Deploy Jenkins (Deployment + Service + PVC)
- [ ] Configure Jenkins for Kubernetes
- [ ] Set up Jenkins pipelines
- [ ] Configure RBAC for Jenkins
- [ ] Test automated deployments
- [ ] (Optional) Set up GitLab Runner or other CI/CD tools

### Phase 7: Networking & Security
- [ ] Set up Ingress Controller (NGINX)
- [ ] Configure Ingress rules
- [ ] Set up Network Policies
- [ ] Configure RBAC (ServiceAccounts, Roles, RoleBindings)
- [ ] Test network isolation
- [ ] Verify security policies

### Phase 8: Testing & Validation
- [ ] Test application functionality
- [ ] Verify monitoring metrics collection
- [ ] Verify log aggregation
- [ ] Test alerting system
- [ ] Test CI/CD pipeline
- [ ] Load testing
- [ ] Disaster recovery testing (pod/node failures)

### Phase 9: Documentation & Cleanup
- [ ] Update README with setup instructions
- [ ] Document Kubernetes-specific procedures
- [ ] Create troubleshooting guide
- [ ] Document differences from VM setup
- [ ] Clean up unused resources

---

## 🔄 Key Differences: VM vs Kubernetes

| Aspect | VM-Based (sherlock-logs) | Kubernetes (cluster-chronicles) |
|--------|-------------------------|--------------------------------|
| **Infrastructure** | 6 VMs (Vagrant) | 1 Minikube cluster |
| **Networking** | Static IPs (192.168.56.x) | ClusterIP, NodePort, LoadBalancer, Ingress |
| **Service Management** | Systemd services | Kubernetes Deployments/StatefulSets |
| **Storage** | VM disk volumes | PersistentVolumes/PersistentVolumeClaims |
| **Configuration** | Ansible playbooks | Kubernetes manifests (YAML) |
| **Scaling** | Manual VM creation | `kubectl scale` or HPA |
| **Load Balancing** | NGINX on dedicated VM | Ingress Controller or Service |
| **Monitoring** | Node Exporter per VM | Node Exporter DaemonSet |
| **Logging** | Filebeat per VM | Fluentd/Fluent Bit DaemonSet |
| **CI/CD** | Jenkins on VM | Jenkins in Pod with PVC |
| **Deployment** | `vagrant provision` | `kubectl apply -f manifests/` |

---

## 📝 Notes

### Application Code Compatibility
- ✅ Flask applications are container-agnostic and work in Kubernetes
- ✅ Prometheus metrics endpoints remain the same
- ✅ Logging format (JSON) remains the same
- ⚠️ Environment variables may need adjustment (Kubernetes ConfigMaps/Secrets)
- ⚠️ Health check endpoints should be configured as Kubernetes probes

### Monitoring & Logging
- ✅ Prometheus scrape configuration will be similar
- ✅ Grafana dashboards can be imported as-is
- ⚠️ Alert rules may need adjustment for Kubernetes labels
- ✅ Elasticsearch configuration remains similar
- ⚠️ Log collection paths change (container logs vs VM logs)

### CI/CD
- ✅ Jenkins pipelines can be adapted
- ⚠️ Deployment targets change from VMs to Kubernetes
- ⚠️ Need to configure `kubectl` access from Jenkins pod
- ⚠️ Container image building may use different registries

---

## 🎯 Success Criteria

The migration is complete when:
- [ ] All applications run in Kubernetes
- [ ] Monitoring stack collects metrics from all pods
- [ ] Logging stack aggregates logs from all pods
- [ ] CI/CD pipeline deploys to Kubernetes
- [ ] All persistent data survives pod restarts
- [ ] External access works via Ingress
- [ ] Alerts fire correctly
- [ ] Documentation is complete

---

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) (optional, for advanced setup)
- [EFK Stack on Kubernetes](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)

---

**Last Updated:** 2025-01-17  
**Status:** Migration in progress - Phase 1 complete

