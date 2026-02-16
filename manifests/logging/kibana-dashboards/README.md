# Kibana Dashboards

This directory contains Kibana dashboard JSON files that can be imported into Kibana.

## Required Dashboards

1. **Cluster Logs Dashboard** - Overview of all cluster logs
2. **Application Logs Dashboard** - Application-specific logs from Flask apps
3. **Pod and Container Logs Dashboard** - Detailed pod and container logs

## Importing Dashboards

### Method 1: Via Kibana UI (Recommended)

1. Access Kibana UI at `http://<minikube-ip>:30601/`
2. Navigate to **Stack Management** → **Saved Objects**
3. Click **Import** button
4. Select the dashboard JSON file
5. Click **Import**

### Method 2: Via Kibana API

```bash
# Get Kibana pod name
KIBANA_POD=$(kubectl get pods -l app=kibana -o jsonpath='{.items[0].metadata.name}')

# Import dashboard
kubectl exec -it $KIBANA_POD -- curl -X POST "http://localhost:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  --data-binary @cluster-logs-dashboard.json
```

### Method 3: Using curl from host

```bash
# Port-forward Kibana
kubectl port-forward svc/kibana 5601:5601 &

# Import dashboard
curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  --data-binary @cluster-logs-dashboard.json
```

## Dashboard Descriptions

### Cluster Logs Dashboard
- **Log Volume Over Time**: Time series visualization of log entries
- **Logs by Namespace**: Breakdown of logs per Kubernetes namespace
- **Logs by Pod**: Breakdown of logs per pod
- **Error Log Count**: Count of error-level logs
- **Log Level Distribution**: Pie chart showing distribution of log levels (INFO, WARN, ERROR, etc.)

### Application Logs Dashboard
- **Application Log Volume**: Time series of application logs
- **Error Logs from Flask Apps**: Filtered view of ERROR level logs from backend/frontend
- **HTTP Request Logs**: Logs containing HTTP request information
- **Logs by Application**: Breakdown by backend vs frontend
- **Response Time from Logs**: Extracted response times from log entries

### Pod and Container Logs Dashboard
- **Logs per Pod**: Detailed view of logs for each pod
- **Container stdout/stderr**: Separate views for stdout and stderr streams
- **Logs by Container Name**: Breakdown by container name
- **Recent Log Entries**: Table view of most recent log entries
- **Log Search Interface**: Searchable interface for filtering logs

## Note

These dashboard JSON files are simplified examples. In a production environment, you would:
1. Create the dashboards through the Kibana UI
2. Configure visualizations with proper queries
3. Export the complete dashboard JSON
4. Store them in version control

For now, these serve as templates that can be imported and then customized in the Kibana UI.

