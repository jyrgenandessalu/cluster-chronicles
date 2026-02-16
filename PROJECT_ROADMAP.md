# 📜 Cluster Chronicles - Project Roadmap

## Project Overview

**Cluster Chronicles** is a comprehensive Kubernetes migration project that transforms a VM-based infrastructure into a scalable, Kubernetes-native environment using Minikube. This project demonstrates practical Kubernetes skills including deployments, networking, storage, CI/CD, monitoring, logging, and alerting.

---

## 🎯 Project Goals

- Migrate containerized applications (backend/frontend) to Kubernetes
- Implement persistent storage for CI/CD and monitoring/logging
- Set up comprehensive monitoring with Prometheus and Grafana
- Deploy EFK stack for centralized logging
- Configure 8 mandatory alerts
- Migrate CI/CD pipeline to Kubernetes
- Apply Kubernetes best practices (RBAC, namespaces, security)

---

## 📋 Implementation Phases

### **Phase 1: Local Kubernetes Setup** 🏗️

**Goal:** Set up Minikube cluster and verify basic functionality

#### Step 1.1: Install Prerequisites
- [ ] Install Minikube on local machine
- [ ] Install kubectl (Kubernetes CLI)
- [ ] Verify installations: `minikube version`, `kubectl version --client`
- [ ] (Optional) Install Lens IDE for Kubernetes visualization

#### Step 1.2: Start Minikube Cluster
- [ ] Start Minikube: `minikube start`
- [ ] Verify cluster status: `kubectl cluster-info`
- [ ] Check node status: `kubectl get nodes`
- [ ] Enable required addons (if needed):
  - [ ] `minikube addons enable ingress`
  - [ ] `minikube addons enable metrics-server` (for HPA)

#### Step 1.3: Learn Essential kubectl Commands
- [ ] Practice: `kubectl get pods`
- [ ] Practice: `kubectl get services`
- [ ] Practice: `kubectl apply -f <file>`
- [ ] Practice: `kubectl delete -f <file>`
- [ ] Practice: `kubectl logs <pod-name>`
- [ ] Practice: `kubectl describe <resource> <name>`
- [ ] Practice: `kubectl exec -it <pod-name> -- /bin/sh`

**Estimated Time:** 1-2 hours  
**Difficulty:** Easy  
**Deliverables:** Working Minikube cluster, kubectl proficiency

---

### **Phase 2: Application Manifests** 📝

**Goal:** Create Kubernetes manifests for backend and frontend applications

#### Step 2.1: Project Structure Setup
- [ ] Create organized folder structure:
  ```
  cluster-chronicles/
  ├── manifests/
  │   ├── backend/
  │   ├── frontend/
  │   ├── storage/
  │   ├── monitoring/
  │   ├── logging/
  │   └── cicd/
  ├── scripts/
  └── README.md
  ```

#### Step 2.2: Backend Deployment Manifest
- [ ] Create `manifests/backend/deployment.yaml`:
  - [ ] Single replica (1)
  - [ ] Docker image specification
  - [ ] Resource requests and limits (CPU, memory)
  - [ ] Environment variables (ConfigMap/Secret)
  - [ ] Liveness probe
  - [ ] Readiness probe
  - [ ] Startup probe (if needed)
  - [ ] Container port (5000)
  - [ ] Labels and selectors

#### Step 2.3: Backend Service Manifest
- [ ] Create `manifests/backend/service.yaml`:
  - [ ] Service type: ClusterIP (internal communication)
  - [ ] Port mapping (5000)
  - [ ] Selector matching deployment labels
  - [ ] Service name for DNS resolution

#### Step 2.4: Frontend Deployment Manifest
- [ ] Create `manifests/frontend/deployment.yaml`:
  - [ ] Two replicas (2)
  - [ ] Docker image specification
  - [ ] Resource requests and limits (CPU, memory)
  - [ ] Environment variables (backend service URL)
  - [ ] Liveness probe
  - [ ] Readiness probe
  - [ ] Container port (5000)
  - [ ] Labels and selectors

#### Step 2.5: Frontend Service Manifest
- [ ] Create `manifests/frontend/service.yaml`:
  - [ ] Service type: ClusterIP (internal) or NodePort (for testing)
  - [ ] Port mapping (5000)
  - [ ] Load balancing across 2 replicas
  - [ ] Selector matching deployment labels

#### Step 2.6: ConfigMaps and Secrets
- [ ] Create `manifests/backend/configmap.yaml`:
  - [ ] Non-sensitive configuration (HOST_VM, ROLE, etc.)
- [ ] Create `manifests/frontend/configmap.yaml`:
  - [ ] Backend service URL
  - [ ] Non-sensitive configuration
- [ ] Create `manifests/backend/secret.yaml` (if needed):
  - [ ] Sensitive data (base64 encoded)
- [ ] Create `manifests/frontend/secret.yaml` (if needed):
  - [ ] Sensitive data (base64 encoded)

**Estimated Time:** 3-4 hours  
**Difficulty:** Medium  
**Deliverables:** Complete backend and frontend manifests

---

### **Phase 3: Deploying and Networking** 🌐

**Goal:** Deploy applications and configure networking

#### Step 3.1: Build and Push Container Images
- [ ] Build backend image: `docker build -t backend:latest ./backend`
- [ ] Build frontend image: `docker build -t frontend:latest ./frontend`
- [ ] Option A: Use Minikube's Docker daemon:
  - [ ] `eval $(minikube docker-env)`
  - [ ] Build images in Minikube context
- [ ] Option B: Use local registry or image pull policy

#### Step 3.2: Deploy Backend
- [ ] Apply backend manifests: `kubectl apply -f manifests/backend/`
- [ ] Verify deployment: `kubectl get deployment backend`
- [ ] Check pods: `kubectl get pods -l app=backend`
- [ ] Verify pod status: `kubectl describe pod <backend-pod>`
- [ ] Check logs: `kubectl logs <backend-pod>`
- [ ] Test service: `kubectl port-forward svc/backend 5000:5000`

#### Step 3.3: Deploy Frontend
- [ ] Apply frontend manifests: `kubectl apply -f manifests/frontend/`
- [ ] Verify deployment: `kubectl get deployment frontend`
- [ ] Check pods: `kubectl get pods -l app=frontend` (should show 2 replicas)
- [ ] Verify load balancing: `kubectl get endpoints frontend`
- [ ] Test service: `kubectl port-forward svc/frontend 5001:5000`

#### Step 3.4: Verify Internal Communication
- [ ] Test backend from frontend pod:
  - [ ] `kubectl exec -it <frontend-pod> -- wget -O- http://backend:5000`
- [ ] Verify DNS resolution: `kubectl exec -it <frontend-pod> -- nslookup backend`
- [ ] Test frontend from backend pod (if needed)

#### Step 3.5: Configure Ingress
- [ ] Create `manifests/frontend/ingress.yaml`:
  - [ ] Ingress resource definition
  - [ ] Host rules (e.g., `frontend.local`)
  - [ ] Path rules
  - [ ] Backend service reference
- [ ] Apply ingress: `kubectl apply -f manifests/frontend/ingress.yaml`
- [ ] Verify ingress: `kubectl get ingress`
- [ ] Get ingress IP: `kubectl get ingress frontend-ingress`
- [ ] Add host entry: Add `<ingress-ip> frontend.local` to `/etc/hosts` (or Windows hosts file)
- [ ] Test external access: `curl http://frontend.local` or browser

#### Step 3.6: Troubleshooting
- [ ] Document common issues and solutions
- [ ] Practice debugging:
  - [ ] Pod in CrashLoopBackOff
  - [ ] Pod in Pending state
  - [ ] Service not connecting
  - [ ] Ingress not routing

**Estimated Time:** 4-5 hours  
**Difficulty:** Medium  
**Deliverables:** Working backend/frontend with internal and external access

---

### **Phase 4: Persistent Storage** 💾

**Goal:** Set up persistent storage for CI/CD and monitoring/logging

#### Step 4.1: Understand Storage Concepts
- [ ] Learn PersistentVolume (PV) concepts
- [ ] Learn PersistentVolumeClaim (PVC) concepts
- [ ] Understand access modes:
  - [ ] ReadWriteOnce (RWO)
  - [ ] ReadOnlyMany (ROX)
  - [ ] ReadWriteMany (RWX)
- [ ] Learn StorageClass concepts

#### Step 4.2: Create Storage Manifests
- [ ] Create `manifests/storage/pv-cicd.yaml`:
  - [ ] PersistentVolume for CI/CD (Jenkins)
  - [ ] Storage size (e.g., 10Gi)
  - [ ] Access mode: ReadWriteOnce
  - [ ] Storage class (or manual)
  - [ ] Host path (for Minikube) or other provisioner
- [ ] Create `manifests/storage/pvc-cicd.yaml`:
  - [ ] PersistentVolumeClaim for CI/CD
  - [ ] Request size matching PV
  - [ ] Access mode: ReadWriteOnce
- [ ] Create `manifests/storage/pv-monitoring.yaml`:
  - [ ] PersistentVolume for Prometheus data
  - [ ] Storage size (e.g., 20Gi)
  - [ ] Access mode: ReadWriteOnce
- [ ] Create `manifests/storage/pvc-monitoring.yaml`:
  - [ ] PersistentVolumeClaim for Prometheus
- [ ] Create `manifests/storage/pv-logging.yaml`:
  - [ ] PersistentVolume for Elasticsearch data
  - [ ] Storage size (e.g., 30Gi)
  - [ ] Access mode: ReadWriteOnce
- [ ] Create `manifests/storage/pvc-logging.yaml`:
  - [ ] PersistentVolumeClaim for Elasticsearch

#### Step 4.3: Apply Storage Configuration
- [ ] Apply PVs: `kubectl apply -f manifests/storage/pv-*.yaml`
- [ ] Apply PVCs: `kubectl apply -f manifests/storage/pvc-*.yaml`
- [ ] Verify binding: `kubectl get pv`, `kubectl get pvc`
- [ ] Check PV status: `kubectl describe pv <pv-name>`
- [ ] Check PVC status: `kubectl describe pvc <pvc-name>`

#### Step 4.4: Test Persistent Storage
- [ ] Create test pod with PVC:
  - [ ] Mount PVC as volume
  - [ ] Write test data
  - [ ] Delete pod
  - [ ] Recreate pod with same PVC
  - [ ] Verify data persistence

**Estimated Time:** 2-3 hours  
**Difficulty:** Medium  
**Deliverables:** PVs and PVCs configured and tested

---

### **Phase 5: CI/CD Pipeline Migration** 🔄

**Goal:** Deploy CI/CD tool on Kubernetes and configure cluster interaction

#### Step 5.1: Choose CI/CD Tool
- [ ] Decision: Jenkins / GitLab CI/CD / CircleCI / Other
- [ ] Document choice and rationale

#### Step 5.2: Deploy CI/CD Tool
- [ ] Create `manifests/cicd/jenkins-deployment.yaml` (or chosen tool):
  - [ ] Deployment with 1 replica
  - [ ] Resource requests and limits
  - [ ] Mount PVC for persistent storage
  - [ ] Environment variables
  - [ ] Container port (8080 for Jenkins)
  - [ ] Liveness and readiness probes
- [ ] Create `manifests/cicd/jenkins-service.yaml`:
  - [ ] Service type: NodePort or LoadBalancer
  - [ ] Port mapping (8080)
- [ ] Create `manifests/cicd/jenkins-configmap.yaml`:
  - [ ] Jenkins configuration (if needed)

#### Step 5.3: Configure Persistent Storage
- [ ] Update Jenkins deployment to use PVC
- [ ] Verify PVC is mounted: `kubectl describe pod <jenkins-pod>`
- [ ] Test data persistence (restart pod, verify data)

#### Step 5.4: Set Up RBAC for CI/CD
- [ ] Create `manifests/cicd/jenkins-serviceaccount.yaml`:
  - [ ] ServiceAccount for Jenkins
- [ ] Create `manifests/cicd/jenkins-role.yaml`:
  - [ ] Role with permissions:
    - [ ] Create deployments
    - [ ] Create services
    - [ ] Get/List pods
    - [ ] Apply manifests
- [ ] Create `manifests/cicd/jenkins-rolebinding.yaml`:
  - [ ] Bind Role to ServiceAccount
- [ ] Apply RBAC: `kubectl apply -f manifests/cicd/`

#### Step 5.5: Configure CI/CD Tool
- [ ] Access Jenkins UI (via NodePort or port-forward)
- [ ] Install required plugins:
  - [ ] Kubernetes plugin (for Jenkins)
  - [ ] Docker plugin
  - [ ] Git plugin
- [ ] Configure Kubernetes cloud (if using Jenkins)
- [ ] Set up credentials:
  - [ ] Store secrets in Kubernetes Secrets
  - [ ] Reference secrets in Jenkins
- [ ] Configure kubectl access from CI/CD pod:
  - [ ] Mount kubeconfig or use ServiceAccount token

#### Step 5.6: Create CI/CD Pipeline
- [ ] Create pipeline definition (Jenkinsfile or GitLab CI config):
  - [ ] Build container images
  - [ ] Run tests
  - [ ] Deploy to Kubernetes
  - [ ] Use kubectl to apply manifests
- [ ] Test pipeline:
  - [ ] Trigger build
  - [ ] Verify deployment
  - [ ] Check application functionality

#### Step 5.7: Extra Requirement - Image Vulnerability Scanning
- [ ] Integrate Trivy (or Clair) into pipeline:
  - [ ] Add scanning step after image build
  - [ ] Configure to fail on critical vulnerabilities
  - [ ] Generate scan reports
- [ ] Test with vulnerable image
- [ ] Verify pipeline fails appropriately

**Estimated Time:** 6-8 hours  
**Difficulty:** Hard  
**Deliverables:** Working CI/CD pipeline on Kubernetes

---

### **Phase 6: Monitoring Stack (Prometheus & Grafana)** 📊

**Goal:** Deploy Prometheus and Grafana for comprehensive monitoring

#### Step 6.1: Deploy Prometheus
- [ ] Create `manifests/monitoring/prometheus-deployment.yaml`:
  - [ ] Deployment with 1 replica
  - [ ] Resource requests and limits
  - [ ] Mount PVC for Prometheus data
  - [ ] Container port (9090)
  - [ ] Liveness and readiness probes
- [ ] Create `manifests/monitoring/prometheus-service.yaml`:
  - [ ] Service type: NodePort or ClusterIP
  - [ ] Port mapping (9090)
- [ ] Create `manifests/monitoring/prometheus-configmap.yaml`:
  - [ ] Prometheus configuration:
    - [ ] Scrape interval (15s)
    - [ ] Scrape jobs:
      - [ ] Kubernetes nodes (node_exporter)
      - [ ] Kubernetes pods (cAdvisor)
      - [ ] Backend application
      - [ ] Frontend application
      - [ ] Kubernetes API server
    - [ ] Service discovery configuration
- [ ] Create `manifests/monitoring/prometheus-pvc.yaml`:
  - [ ] Reference to monitoring PVC
- [ ] Apply Prometheus: `kubectl apply -f manifests/monitoring/prometheus-*.yaml`
- [ ] Verify Prometheus: `kubectl get pods -l app=prometheus`
- [ ] Access Prometheus UI and verify targets

#### Step 6.2: Deploy Node Exporter
- [ ] Create `manifests/monitoring/node-exporter-daemonset.yaml`:
  - [ ] DaemonSet to run on all nodes
  - [ ] Container port (9100)
  - [ ] Host network access (if needed)
  - [ ] Resource limits
- [ ] Apply Node Exporter: `kubectl apply -f manifests/monitoring/node-exporter-daemonset.yaml`
- [ ] Verify: `kubectl get pods -l app=node-exporter`
- [ ] Update Prometheus config to scrape node_exporter

#### Step 6.3: Deploy cAdvisor
- [ ] Create `manifests/monitoring/cadvisor-daemonset.yaml`:
  - [ ] DaemonSet to run on all nodes
  - [ ] Container port (8080)
  - [ ] Host paths for container metrics
  - [ ] Resource limits
- [ ] Apply cAdvisor: `kubectl apply -f manifests/monitoring/cadvisor-daemonset.yaml`
- [ ] Verify: `kubectl get pods -l app=cadvisor`
- [ ] Update Prometheus config to scrape cAdvisor

#### Step 6.4: Configure Service Discovery
- [ ] Update Prometheus config to use Kubernetes service discovery:
  - [ ] `kubernetes_sd_configs` for pods
  - [ ] `kubernetes_sd_configs` for services
  - [ ] Relabeling rules for proper target identification
- [ ] Verify all targets are discovered in Prometheus UI

#### Step 6.5: Deploy Grafana
- [ ] Create `manifests/monitoring/grafana-deployment.yaml`:
  - [ ] Deployment with 1 replica
  - [ ] Resource requests and limits
  - [ ] Mount PVC for Grafana data
  - [ ] Container port (3000)
  - [ ] Environment variables (admin credentials)
  - [ ] Liveness and readiness probes
- [ ] Create `manifests/monitoring/grafana-service.yaml`:
  - [ ] Service type: NodePort or LoadBalancer
  - [ ] Port mapping (3000)
- [ ] Create `manifests/monitoring/grafana-configmap.yaml`:
  - [ ] Grafana datasources (Prometheus)
  - [ ] Dashboard provisioning
- [ ] Create `manifests/monitoring/grafana-pvc.yaml`:
  - [ ] Reference to monitoring PVC
- [ ] Apply Grafana: `kubectl apply -f manifests/monitoring/grafana-*.yaml`
- [ ] Verify: `kubectl get pods -l app=grafana`
- [ ] Access Grafana UI and configure Prometheus datasource

#### Step 6.6: Create Grafana Dashboards
- [ ] **Cluster Performance Dashboard:**
  - [ ] Node CPU usage
  - [ ] Node memory usage
  - [ ] Node disk usage
  - [ ] Pod count per namespace
  - [ ] Resource utilization graphs
- [ ] **Pod and Container Dashboard:**
  - [ ] Pod CPU usage per pod
  - [ ] Pod memory usage per pod
  - [ ] Container restart counts
  - [ ] Network traffic per pod
  - [ ] Pod status overview
- [ ] **Application Performance Dashboard:**
  - [ ] HTTP request rate (from Flask apps)
  - [ ] HTTP request duration
  - [ ] Error rates
  - [ ] Custom application metrics
  - [ ] Response time percentiles
- [ ] Import/export dashboards as JSON
- [ ] Save dashboards to ConfigMap for persistence

#### Step 6.7: Custom Metrics Integration
- [ ] Verify Flask apps expose `/metrics` endpoint
- [ ] Update Prometheus config to scrape application metrics
- [ ] Verify metrics appear in Prometheus
- [ ] Add application metrics to Grafana dashboards

**Estimated Time:** 8-10 hours  
**Difficulty:** Hard  
**Deliverables:** Prometheus and Grafana fully configured with dashboards

---

### **Phase 7: Logging Stack (EFK)** 📋

**Goal:** Deploy Elasticsearch, Fluentd/Fluent Bit, and Kibana for centralized logging

#### Step 7.1: Deploy Elasticsearch
- [ ] Create `manifests/logging/elasticsearch-statefulset.yaml`:
  - [ ] StatefulSet with 3 replicas (for multi-node cluster)
  - [ ] Resource requests and limits
  - [ ] Mount PVC for Elasticsearch data
  - [ ] Container port (9200)
  - [ ] Environment variables (cluster name, node roles)
  - [ ] Init containers (if needed for setup)
  - [ ] Liveness and readiness probes
- [ ] Create `manifests/logging/elasticsearch-service.yaml`:
  - [ ] Headless service (ClusterIP with clusterIP: None)
  - [ ] Port mapping (9200)
  - [ ] Service for client access
- [ ] Create `manifests/logging/elasticsearch-pvc.yaml`:
  - [ ] PVC template in StatefulSet
  - [ ] Reference to logging PVC
- [ ] Apply Elasticsearch: `kubectl apply -f manifests/logging/elasticsearch-*.yaml`
- [ ] Verify: `kubectl get pods -l app=elasticsearch`
- [ ] Check cluster health: `kubectl exec -it <es-pod> -- curl http://localhost:9200/_cluster/health`

#### Step 7.2: Deploy Fluentd/Fluent Bit
- [ ] Create `manifests/logging/fluentd-daemonset.yaml`:
  - [ ] DaemonSet to run on all nodes
  - [ ] Resource limits
  - [ ] Volume mounts:
    - [ ] `/var/log` (host logs)
    - [ ] `/var/lib/docker/containers` (container logs)
    - [ ] `/var/log/pods` (Kubernetes pod logs)
  - [ ] ConfigMap mount for configuration
- [ ] Create `manifests/logging/fluentd-configmap.yaml`:
  - [ ] Fluentd configuration:
    - [ ] Input sources (files, containers)
    - [ ] Parsing rules (JSON, syslog, etc.)
    - [ ] Output to Elasticsearch
    - [ ] Log routing and filtering
- [ ] Apply Fluentd: `kubectl apply -f manifests/logging/fluentd-*.yaml`
- [ ] Verify: `kubectl get pods -l app=fluentd`
- [ ] Check logs: `kubectl logs <fluentd-pod>`

#### Step 7.3: Configure Log Collection
- [ ] Update Fluentd config to collect:
  - [ ] System logs (syslog, journald)
  - [ ] Container logs (stdout/stderr)
  - [ ] Application logs (from Flask apps)
  - [ ] Kubernetes events
- [ ] Configure log parsing:
  - [ ] JSON logs from Flask apps
  - [ ] Plain text logs
  - [ ] Multi-line logs
- [ ] Configure log routing to Elasticsearch:
  - [ ] Index naming (e.g., `kubernetes-logs-YYYY.MM.DD`)
  - [ ] Index templates
  - [ ] Document mapping

#### Step 7.4: Deploy Kibana
- [ ] Create `manifests/logging/kibana-deployment.yaml`:
  - [ ] Deployment with 1 replica
  - [ ] Resource requests and limits
  - [ ] Container port (5601)
  - [ ] Environment variables (Elasticsearch URL)
  - [ ] Liveness and readiness probes
- [ ] Create `manifests/logging/kibana-service.yaml`:
  - [ ] Service type: NodePort or LoadBalancer
  - [ ] Port mapping (5601)
- [ ] Apply Kibana: `kubectl apply -f manifests/logging/kibana-*.yaml`
- [ ] Verify: `kubectl get pods -l app=kibana`
- [ ] Access Kibana UI and configure Elasticsearch connection

#### Step 7.5: Configure Kibana
- [ ] Create index patterns:
  - [ ] `kubernetes-logs-*`
  - [ ] `application-logs-*`
  - [ ] `system-logs-*`
- [ ] Set default index pattern
- [ ] Verify log ingestion: Check Discover tab

#### Step 7.6: Create Kibana Dashboards
- [ ] **Cluster Logs Dashboard:**
  - [ ] Log volume over time
  - [ ] Logs by namespace
  - [ ] Logs by pod
  - [ ] Error log count
  - [ ] Log level distribution
- [ ] **Application Logs Dashboard:**
  - [ ] Application log volume
  - [ ] Error logs from Flask apps
  - [ ] HTTP request logs
  - [ ] Logs by application (backend/frontend)
  - [ ] Response time from logs
- [ ] **Pod and Container Logs Dashboard:**
  - [ ] Logs per pod
  - [ ] Container stdout/stderr
  - [ ] Logs by container name
  - [ ] Recent log entries
  - [ ] Log search interface
- [ ] Export dashboards as JSON
- [ ] Save dashboards for persistence

#### Step 7.7: Configure Log Rotation and Retention
- [ ] Set up Elasticsearch index lifecycle management:
  - [ ] Hot phase (recent logs)
  - [ ] Warm phase (older logs)
  - [ ] Delete phase (after retention period)
- [ ] Configure index templates with retention policies
- [ ] Set up automated index rotation (daily/weekly)
- [ ] Monitor disk usage

**Estimated Time:** 8-10 hours  
**Difficulty:** Hard  
**Deliverables:** EFK stack fully configured with dashboards

---

### **Phase 8: Alerting System** 🚨

**Goal:** Configure 8 mandatory alerts using Prometheus and Alertmanager

#### Step 8.1: Deploy Alertmanager
- [ ] Create `manifests/monitoring/alertmanager-deployment.yaml`:
  - [ ] Deployment with 1 replica
  - [ ] Resource limits
  - [ ] Container port (9093)
  - [ ] Liveness and readiness probes
- [ ] Create `manifests/monitoring/alertmanager-service.yaml`:
  - [ ] Service type: ClusterIP
  - [ ] Port mapping (9093)
- [ ] Create `manifests/monitoring/alertmanager-configmap.yaml`:
  - [ ] Alert routing rules
  - [ ] Notification channels (email, Slack, etc.)
  - [ ] Grouping and throttling rules
- [ ] Apply Alertmanager: `kubectl apply -f manifests/monitoring/alertmanager-*.yaml`
- [ ] Configure Prometheus to use Alertmanager

#### Step 8.2: Configure Prometheus Alert Rules
- [ ] Create `manifests/monitoring/prometheus-alertrules.yaml`:
  - [ ] Alert rule definitions
  - [ ] PromQL queries for each alert
  - [ ] Alert labels and annotations

#### Step 8.3: Node-Related Alerts

**Alert 1: Node CPU Usage > 80% for 5 minutes**
- [ ] Create alert rule:
  - [ ] Query: `100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80`
  - [ ] Duration: 5 minutes
  - [ ] Labels: severity=warning, component=node
  - [ ] Annotations: description, summary
- [ ] Test alert:
  - [ ] `kubectl run stress-test --image=polinux/stress -- stress-ng --cpu 8 --timeout 360s`
  - [ ] Verify alert fires in Prometheus/Alertmanager
  - [ ] Clean up: `kubectl delete pod stress-test`

**Alert 2: Node Available Disk Space < 20%**
- [ ] Create alert rule:
  - [ ] Query: `(node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 20`
  - [ ] Duration: 1 minute
  - [ ] Labels: severity=critical, component=node
- [ ] Test alert:
  - [ ] `kubectl exec -it <node-pod> -- fallocate -l 10G /tmp/large_file.img`
  - [ ] Verify alert fires
  - [ ] Clean up: `kubectl exec -it <node-pod> -- rm /tmp/large_file.img`

**Alert 3: Node Memory Usage > 90% for 5 minutes**
- [ ] Create alert rule:
  - [ ] Query: `(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90`
  - [ ] Duration: 5 minutes
  - [ ] Labels: severity=critical, component=node
- [ ] Test alert:
  - [ ] `kubectl run stress-mem --image=polinux/stress -- stress-ng --vm 2 --vm-bytes 4G --timeout 360s`
  - [ ] Verify alert fires
  - [ ] Clean up: `kubectl delete pod stress-mem`

#### Step 8.4: Pod and Container-Related Alerts

**Alert 4: Pod Restarts > 3 in 15 minutes**
- [ ] Create alert rule:
  - [ ] Query: `sum by (pod, namespace) (increase(kube_pod_container_status_restarts_total[15m])) > 3`
  - [ ] Duration: 1 minute
  - [ ] Labels: severity=warning, component=pod
- [ ] Test alert:
  - [ ] `kubectl run test-pod --image=alpine --restart=Always -- /bin/sh -c "sleep 10; exit 1"`
  - [ ] Wait for restarts
  - [ ] Verify alert fires
  - [ ] Clean up: `kubectl delete pod test-pod`

**Alert 5: Container Memory Usage > 80% of Limit**
- [ ] Create alert rule:
  - [ ] Query: `(container_memory_usage_bytes{name!=""} / container_spec_memory_limit_bytes{name!=""}) * 100 > 80`
  - [ ] Duration: 5 minutes
  - [ ] Labels: severity=warning, component=container
- [ ] Test alert:
  - [ ] Create pod with memory limit: `kubectl run memory-test --image=ubuntu --limits=memory=512Mi -- stress-ng --vm 1 --vm-bytes 450M --timeout 360s`
  - [ ] Verify alert fires
  - [ ] Clean up: `kubectl delete pod memory-test`

**Alert 6: Pod in Pending State > 5 minutes**
- [ ] Create alert rule:
  - [ ] Query: `kube_pod_status_phase{phase="Pending"} > 0`
  - [ ] Duration: 5 minutes
  - [ ] Labels: severity=warning, component=pod
- [ ] Test alert:
  - [ ] Create pod with insufficient resources: `kubectl apply -f manifests/test/insufficient-resources-pod.yaml`
  - [ ] Verify pod stays in Pending
  - [ ] Verify alert fires
  - [ ] Clean up: `kubectl delete pod <pod-name>`

#### Step 8.5: Cluster-Related Alerts

**Alert 7: Kubernetes API Server Unreachable**
- [ ] Create alert rule:
  - [ ] Query: `up{job="kubernetes-apiservers"} == 0`
  - [ ] Duration: 1 minute
  - [ ] Labels: severity=critical, component=cluster
- [ ] Test alert:
  - [ ] Disrupt Minikube API server: `minikube stop` (or similar)
  - [ ] Verify alert fires
  - [ ] Restore: `minikube start`

#### Step 8.6: Monitoring and Logging System Alerts

**Alert 8: Elasticsearch Cluster Status Yellow or Red**
- [ ] Create alert rule:
  - [ ] Query: `elasticsearch_cluster_health_status{job="elasticsearch_exporter"} < 3`
  - [ ] Duration: 1 minute
  - [ ] Labels: severity=warning, component=logging
  - [ ] Note: May need custom exporter or direct Elasticsearch query
- [ ] Test alert:
  - [ ] Stop one Elasticsearch pod: `kubectl delete pod <es-pod-1>`
  - [ ] Wait for cluster to go yellow
  - [ ] Verify alert fires
  - [ ] Restore: Wait for pod to restart or manually restart

**Alert 9: Fluentd Log Collection Errors**
- [ ] Create alert rule:
  - [ ] Query: `fluentd_output_errors_total > 0` or similar
  - [ ] Duration: 5 minutes
  - [ ] Labels: severity=warning, component=logging
  - [ ] Note: May need to expose Fluentd metrics
- [ ] Test alert:
  - [ ] Misconfigure Fluentd (incorrect log paths)
  - [ ] Verify errors occur
  - [ ] Verify alert fires
  - [ ] Fix configuration

#### Step 8.7: Configure Alert Grouping and Throttling
- [ ] Set up alert grouping in Alertmanager:
  - [ ] Group alerts by severity
  - [ ] Group alerts by component
- [ ] Configure throttling:
  - [ ] Prevent alert spam
  - [ ] Set repeat interval
- [ ] Test alert notifications

**Estimated Time:** 6-8 hours  
**Difficulty:** Hard  
**Deliverables:** All 8 alerts configured and tested

---

### **Phase 9: Extra Requirements** ⭐

**Goal:** Implement image vulnerability scanning and HPA

#### Step 9.1: Image Vulnerability Scanning
- [ ] Integrate Trivy (or Clair) into CI/CD pipeline:
  - [ ] Add Trivy scan step after image build
  - [ ] Configure scan to check for critical/high vulnerabilities
  - [ ] Fail pipeline if critical vulnerabilities found
  - [ ] Generate scan reports (JSON, HTML)
  - [ ] Store reports as artifacts
- [ ] Test with vulnerable image:
  - [ ] Use known vulnerable base image
  - [ ] Verify pipeline fails
- [ ] Document scanning process in README

#### Step 9.2: Horizontal Pod Autoscaling (HPA)
- [ ] Enable metrics-server (if not already):
  - [ ] `minikube addons enable metrics-server`
  - [ ] Verify: `kubectl top nodes`, `kubectl top pods`
- [ ] Create `manifests/frontend/hpa.yaml`:
  - [ ] HPA resource for frontend deployment
  - [ ] Min replicas: 2
  - [ ] Max replicas: 5
  - [ ] Target CPU utilization: 70%
  - [ ] Scale behavior configuration
- [ ] Apply HPA: `kubectl apply -f manifests/frontend/hpa.yaml`
- [ ] Verify HPA: `kubectl get hpa frontend-hpa`
- [ ] Test autoscaling:
  - [ ] Generate load: `kubectl run load-test --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://frontend:5000; done"`
  - [ ] Monitor HPA: `kubectl get hpa frontend-hpa -w`
  - [ ] Verify pods scale up: `kubectl get pods -l app=frontend -w`
  - [ ] Stop load and verify scale down
  - [ ] Clean up: `kubectl delete pod load-test`

**Estimated Time:** 3-4 hours  
**Difficulty:** Medium  
**Deliverables:** Image scanning in CI/CD, HPA configured and tested

---

### **Phase 10: Security and Best Practices** 🔒

**Goal:** Implement Kubernetes security best practices

#### Step 10.1: Namespace Management
- [ ] Create namespaces:
  - [ ] `kubectl create namespace production`
  - [ ] `kubectl create namespace monitoring`
  - [ ] `kubectl create namespace logging`
  - [ ] `kubectl create namespace cicd`
- [ ] Organize resources by namespace:
  - [ ] Move deployments to appropriate namespaces
  - [ ] Update service references
  - [ ] Update ingress rules
- [ ] Set default namespace: `kubectl config set-context --current --namespace=<namespace>`

#### Step 10.2: RBAC Configuration
- [ ] Review existing ServiceAccounts:
  - [ ] Ensure each component has dedicated ServiceAccount
  - [ ] Follow principle of least privilege
- [ ] Create Roles and RoleBindings:
  - [ ] Component-specific roles
  - [ ] Namespace-scoped permissions
- [ ] Document RBAC setup

#### Step 10.3: Network Policies
- [ ] Create `manifests/security/network-policy-backend.yaml`:
  - [ ] Allow ingress only from frontend
  - [ ] Allow egress to monitoring (Prometheus)
  - [ ] Deny all other traffic
- [ ] Create `manifests/security/network-policy-frontend.yaml`:
  - [ ] Allow ingress from ingress controller
  - [ ] Allow egress to backend
  - [ ] Allow egress to monitoring
- [ ] Create `manifests/security/network-policy-monitoring.yaml`:
  - [ ] Allow ingress from all pods (for scraping)
  - [ ] Allow egress to Elasticsearch (for logging)
- [ ] Apply network policies: `kubectl apply -f manifests/security/`
- [ ] Test network isolation:
  - [ ] Verify allowed traffic works
  - [ ] Verify denied traffic is blocked

#### Step 10.4: Secrets Management
- [ ] Audit all manifests for secrets:
  - [ ] Ensure no plain-text passwords
  - [ ] Ensure no hardcoded API keys
  - [ ] Ensure no SSH keys in manifests
- [ ] Convert sensitive data to Kubernetes Secrets:
  - [ ] Create secrets: `kubectl create secret generic <name> --from-literal=key=value`
  - [ ] Update deployments to reference secrets
  - [ ] Mount secrets as volumes or environment variables
- [ ] Document secret management process

#### Step 10.5: Resource Management
- [ ] Review all resource requests and limits:
  - [ ] Ensure all pods have requests
  - [ ] Ensure all pods have limits
  - [ ] Verify limits are reasonable
- [ ] Test resource constraints:
  - [ ] Verify pods respect limits
  - [ ] Test OOMKilled scenario
  - [ ] Document behavior

#### Step 10.6: Security Scanning
- [ ] Run `kubectl` security audit:
  - [ ] Check for security best practices
  - [ ] Use tools like `kube-score` or `kubeaudit`
- [ ] Fix identified issues
- [ ] Document security measures

**Estimated Time:** 4-5 hours  
**Difficulty:** Medium  
**Deliverables:** Security best practices implemented

---

### **Phase 11: Testing and Validation** ✅

**Goal:** Comprehensive testing of all components

#### Step 11.1: Application Testing
- [ ] Test backend functionality:
  - [ ] Health checks
  - [ ] Metrics endpoint
  - [ ] API endpoints
- [ ] Test frontend functionality:
  - [ ] Web interface
  - [ ] Backend communication
  - [ ] Dashboard
- [ ] Test load balancing:
  - [ ] Verify traffic distributes across frontend replicas
  - [ ] Test session persistence (if applicable)

#### Step 11.2: Monitoring Testing
- [ ] Verify Prometheus targets:
  - [ ] All targets are up
  - [ ] Metrics are being scraped
  - [ ] No scrape errors
- [ ] Test Grafana dashboards:
  - [ ] All dashboards load correctly
  - [ ] Data is displayed
  - [ ] Queries are correct
- [ ] Test custom metrics:
  - [ ] Application metrics appear
  - [ ] Metrics are accurate

#### Step 11.3: Logging Testing
- [ ] Verify log collection:
  - [ ] Logs appear in Elasticsearch
  - [ ] All sources are collected
  - [ ] Log parsing is correct
- [ ] Test Kibana dashboards:
  - [ ] All dashboards load
  - [ ] Logs are searchable
  - [ ] Filters work correctly
- [ ] Test log retention:
  - [ ] Old logs are rotated
  - [ ] Disk usage is managed

#### Step 11.4: CI/CD Testing
- [ ] Test full pipeline:
  - [ ] Code commit triggers build
  - [ ] Image is built
  - [ ] Vulnerability scan runs
  - [ ] Deployment succeeds
  - [ ] Application is updated
- [ ] Test rollback:
  - [ ] Deploy broken version
  - [ ] Verify rollback works
- [ ] Test secrets:
  - [ ] Secrets are not exposed
  - [ ] Secrets are used correctly

#### Step 11.5: Alert Testing
- [ ] Test all 8 alerts:
  - [ ] Each alert fires correctly
  - [ ] Alert notifications work
  - [ ] Alert resolution works
- [ ] Test alert grouping:
  - [ ] Related alerts are grouped
  - [ ] Throttling prevents spam

#### Step 11.6: Disaster Recovery Testing
- [ ] Test pod failures:
  - [ ] Delete pod, verify restart
  - [ ] Verify data persistence
- [ ] Test node failures:
  - [ ] Stop Minikube node
  - [ ] Verify pods reschedule
- [ ] Test storage persistence:
  - [ ] Delete pod with PVC
  - [ ] Recreate pod
  - [ ] Verify data persists

**Estimated Time:** 6-8 hours  
**Difficulty:** Medium  
**Deliverables:** All components tested and validated

---

### **Phase 12: Documentation** 📚

**Goal:** Complete project documentation

#### Step 12.1: Update README
- [ ] Project overview:
  - [ ] What the project does
  - [ ] Architecture diagram
  - [ ] Key features
- [ ] Setup instructions:
  - [ ] Prerequisites
  - [ ] Minikube installation
  - [ ] kubectl installation
  - [ ] Step-by-step setup
- [ ] Usage guide:
  - [ ] How to deploy
  - [ ] How to access services
  - [ ] Common commands
- [ ] Additional features:
  - [ ] Image vulnerability scanning
  - [ ] HPA configuration
  - [ ] Bonus functionality (if any)

#### Step 12.2: Create Architecture Documentation
- [ ] Draw architecture diagram:
  - [ ] Cluster components
  - [ ] Networking flow
  - [ ] Data flow
- [ ] Document design decisions:
  - [ ] Why StatefulSet for Elasticsearch
  - [ ] Why DaemonSet for Node Exporter
  - [ ] Service type choices
  - [ ] Storage choices

#### Step 12.3: Create Troubleshooting Guide
- [ ] Common issues:
  - [ ] Pod in CrashLoopBackOff
  - [ ] Pod in Pending state
  - [ ] Service not connecting
  - [ ] Ingress not working
  - [ ] Storage not mounting
- [ ] Debugging commands:
  - [ ] `kubectl describe`
  - [ ] `kubectl logs`
  - [ ] `kubectl exec`
  - [ ] `kubectl get events`

#### Step 12.4: Document Kubernetes Concepts
- [ ] Explain key concepts:
  - [ ] Pods, Deployments, Services
  - [ ] Namespaces, RBAC
  - [ ] PVs, PVCs
  - [ ] Ingress, Network Policies
  - [ ] Probes, Resource limits
- [ ] Explain design choices:
  - [ ] Why specific resource types
  - [ ] Why specific configurations

#### Step 12.5: Code Comments
- [ ] Add comments to manifests:
  - [ ] Explain complex configurations
  - [ ] Document resource choices
- [ ] Add comments to scripts:
  - [ ] Explain script purpose
  - [ ] Document parameters

**Estimated Time:** 4-5 hours  
**Difficulty:** Easy  
**Deliverables:** Complete documentation

---

## 📊 Progress Tracking

### Overall Progress
- [ ] Phase 1: Local Kubernetes Setup
- [ ] Phase 2: Application Manifests
- [ ] Phase 3: Deploying and Networking
- [ ] Phase 4: Persistent Storage
- [ ] Phase 5: CI/CD Pipeline Migration
- [ ] Phase 6: Monitoring Stack
- [ ] Phase 7: Logging Stack
- [ ] Phase 8: Alerting System
- [ ] Phase 9: Extra Requirements
- [ ] Phase 10: Security and Best Practices
- [ ] Phase 11: Testing and Validation
- [ ] Phase 12: Documentation

### Mandatory Requirements Checklist
- [ ] Minikube cluster set up
- [ ] Backend deployment (1 replica)
- [ ] Frontend deployment (2 replicas)
- [ ] Services configured
- [ ] Ingress configured
- [ ] Persistent storage (PVs/PVCs)
- [ ] CI/CD tool deployed
- [ ] Prometheus deployed and scraping
- [ ] Grafana deployed with 3 dashboards
- [ ] EFK stack deployed
- [ ] Kibana with 3 dashboards
- [ ] 8 alerts configured and tested
- [ ] Image vulnerability scanning
- [ ] HPA configured
- [ ] RBAC configured
- [ ] Network policies configured
- [ ] Namespaces organized
- [ ] Secrets managed properly
- [ ] Resource limits defined
- [ ] Documentation complete

---

## 🎯 Success Criteria

The project is complete when:
- ✅ All applications run in Kubernetes
- ✅ All services are accessible (internal and external)
- ✅ Persistent storage works correctly
- ✅ CI/CD pipeline deploys to Kubernetes
- ✅ Monitoring stack collects all metrics
- ✅ Logging stack aggregates all logs
- ✅ All 8 alerts fire correctly
- ✅ Image scanning works in CI/CD
- ✅ HPA scales pods automatically
- ✅ Security best practices are followed
- ✅ Documentation is complete and clear

---

## 📝 Notes

### Time Estimates
- **Total Estimated Time:** 60-80 hours
- **Breakdown:**
  - Setup and basics: 10-15 hours
  - Application deployment: 10-12 hours
  - Monitoring and logging: 20-25 hours
  - CI/CD and alerts: 12-15 hours
  - Security and testing: 10-12 hours
  - Documentation: 4-5 hours

### Difficulty Levels
- **Easy:** Basic kubectl commands, simple manifests
- **Medium:** Complex configurations, networking, storage
- **Hard:** Service discovery, alerting, CI/CD integration

### Key Learning Points
- Kubernetes architecture and components
- Declarative configuration with YAML
- Service discovery and networking
- Persistent storage management
- Monitoring and observability
- Log aggregation
- CI/CD in Kubernetes
- Security best practices

---

**Last Updated:** 2025-01-17  
**Status:** Ready to begin Phase 1

