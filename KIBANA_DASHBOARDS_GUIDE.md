# Kibana Dashboards Creation Guide

## Quick Start

1. **Run the helper script:**
   ```powershell
   .\scripts\create-kibana-dashboards.ps1
   ```

2. **Or access Kibana directly:**
   - URL: `http://192.168.59.101:30601/` (replace with your Minikube IP)
   - Get Minikube IP: `minikube ip`

## Prerequisites

Before creating dashboards, ensure:
- ✅ Kibana is running: `kubectl get pods -l app=kibana`
- ✅ Elasticsearch has logs: `kubectl exec deployment/elasticsearch -- curl -s "http://localhost:9200/_cat/indices/kubernetes-logs*?v"`
- ✅ Data view exists: `kubernetes-logs-*` with time field `@timestamp`

## Dashboard 1: Cluster Logs Dashboard

### Purpose
Overview of all cluster logs by namespace, pod, and log level.

### Visualizations to Create

1. **Log Volume Over Time** (Area Chart)
   - Data view: `kubernetes-logs-*`
   - X-axis: `@timestamp` (Date Histogram, interval: Auto)
   - Y-axis: Count
   - Filter: None

2. **Logs by Namespace** (Pie Chart)
   - Data view: `kubernetes-logs-*`
   - Slice by: `kubernetes.namespace_name` (Terms, Top 10)
   - Size: Count

3. **Logs by Pod** (Data Table)
   - Data view: `kubernetes-logs-*`
   - Rows: `kubernetes.pod_name` (Terms, Top 20)
   - Metric: Count

4. **Error Log Count** (Metric)
   - Data view: `kubernetes-logs-*`
   - Filter: `log.level: ERROR`
   - Metric: Count

5. **Log Level Distribution** (Pie Chart)
   - Data view: `kubernetes-logs-*`
   - Slice by: `log.level` (Terms)
   - Size: Count

### Steps
1. Go to Dashboard → Create Dashboard
2. Create each visualization (click "Create visualization")
3. Add all 5 visualizations to the dashboard
4. Save as: **"Cluster Logs Dashboard"**

## Dashboard 2: Application Logs Dashboard

### Purpose
Application-specific logs from Flask backend and frontend.

### Visualizations to Create

1. **Application Log Volume** (Area Chart)
   - Data view: `kubernetes-logs-*`
   - Filter: `kubernetes.labels.app: (backend OR frontend)`
   - X-axis: `@timestamp` (Date Histogram)
   - Y-axis: Count

2. **Error Logs from Flask Apps** (Data Table)
   - Data view: `kubernetes-logs-*`
   - Filter: `kubernetes.labels.app: (backend OR frontend) AND log.level: ERROR`
   - Columns: `@timestamp`, `kubernetes.pod_name`, `log.level`, `message`
   - Sort by: `@timestamp` (Descending)

3. **HTTP Request Logs** (Data Table)
   - Data view: `kubernetes-logs-*`
   - Filter: `message: *HTTP*`
   - Columns: `@timestamp`, `kubernetes.pod_name`, `message`
   - Sort by: `@timestamp` (Descending)

4. **Logs by Application** (Pie Chart)
   - Data view: `kubernetes-logs-*`
   - Filter: `kubernetes.labels.app: (backend OR frontend)`
   - Slice by: `kubernetes.labels.app` (Terms)
   - Size: Count

5. **Response Time from Logs** (Line Chart)
   - Data view: `kubernetes-logs-*`
   - Filter: `message: *response_time*` OR `message: *duration*`
   - X-axis: `@timestamp` (Date Histogram)
   - Y-axis: Extract numeric value from `message` field (if available)
   - Note: This may require custom parsing if response times aren't in a separate field

### Steps
1. Go to Dashboard → Create Dashboard
2. Create each visualization
3. Add all 5 visualizations to the dashboard
4. Save as: **"Application Logs Dashboard"**

## Dashboard 3: Pod and Container Logs Dashboard

### Purpose
Detailed view of logs per pod and container.

### Visualizations to Create

1. **Logs per Pod** (Data Table)
   - Data view: `kubernetes-logs-*`
   - Rows: `kubernetes.pod_name` (Terms, Top 50)
   - Metric: Count
   - Additional columns: `kubernetes.namespace_name`

2. **Container stdout/stderr** (Data Table)
   - Data view: `kubernetes-logs-*`
   - Filter: `stream: (stdout OR stderr)`
   - Rows: `stream` (Terms)
   - Columns: `kubernetes.container_name`
   - Metric: Count

3. **Logs by Container Name** (Pie Chart)
   - Data view: `kubernetes-logs-*`
   - Slice by: `kubernetes.container_name` (Terms, Top 20)
   - Size: Count

4. **Recent Log Entries** (Data Table)
   - Data view: `kubernetes-logs-*`
   - Sort by: `@timestamp` (Descending)
   - Columns: `@timestamp`, `kubernetes.pod_name`, `kubernetes.container_name`, `log.level`, `message`
   - Limit: 100 rows

5. **Log Search Interface** (Lens Visualization)
   - Data view: `kubernetes-logs-*`
   - Type: Data table
   - Make it searchable/filterable
   - Include filters for: pod name, namespace, container name, log level

### Steps
1. Go to Dashboard → Create Dashboard
2. Create each visualization
3. Add all 5 visualizations to the dashboard
4. Save as: **"Pod and Container Logs Dashboard"**

## Exporting Dashboards

After creating all dashboards:

1. Go to: **Stack Management → Saved Objects**
2. Filter by: **Dashboard**
3. Select all 3 dashboards:
   - Cluster Logs Dashboard
   - Application Logs Dashboard
   - Pod and Container Logs Dashboard
4. Click **Export**
5. Save the JSON file to: `manifests/logging/kibana-dashboards/`

## Verification

After creating dashboards, verify they work:

1. **Check dashboards list:**
   - Go to Dashboard → View all dashboards
   - You should see all 3 dashboards

2. **Test each dashboard:**
   - Open each dashboard
   - Verify visualizations load data
   - Check filters work correctly

3. **Verify data:**
   ```powershell
   # Check if logs are being indexed
   kubectl exec deployment/elasticsearch -- curl -s "http://localhost:9200/_cat/indices/kubernetes-logs*?v"
   
   # Check log count
   kubectl exec deployment/elasticsearch -- curl -s "http://localhost:9200/kubernetes-logs-*/_count"
   ```

## Troubleshooting

### No data in visualizations
- Check if data view is correct: `kubernetes-logs-*`
- Verify logs are being indexed: Check Elasticsearch indices
- Check time range: Set to "Last 24 hours" or "Last 7 days"

### Fields not available
- Go to Stack Management → Data Views → `kubernetes-logs-*`
- Click "Refresh field list"
- Wait for fields to populate

### Dashboard not saving
- Check browser console for errors
- Ensure you're logged in to Kibana
- Try refreshing the page

## Quick Reference

**Kibana URLs:**
- Home: `http://<minikube-ip>:30601/`
- Dashboards: `http://<minikube-ip>:30601/app/dashboards`
- Create Dashboard: `http://<minikube-ip>:30601/app/dashboards/create`
- Data Views: `http://<minikube-ip>:30601/app/management/kibana/dataViews`
- Saved Objects: `http://<minikube-ip>:30601/app/management/kibana/objects`

**Common Fields:**
- `@timestamp` - Log timestamp
- `kubernetes.pod_name` - Pod name
- `kubernetes.namespace_name` - Namespace
- `kubernetes.container_name` - Container name
- `kubernetes.labels.app` - Application label (backend/frontend)
- `log.level` - Log level (INFO, WARN, ERROR)
- `message` - Log message
- `stream` - stdout/stderr

