# PowerShell script to help create Kibana dashboards
# This script provides step-by-step guidance and can verify the setup

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Kibana Dashboard Creation Helper" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Get Minikube IP
$MINIKUBE_IP = minikube ip
$KIBANA_URL = "http://${MINIKUBE_IP}:30601"

Write-Host "Kibana URL: $KIBANA_URL" -ForegroundColor Green
Write-Host ""

# Check if Kibana is accessible
Write-Host "Checking Kibana accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$KIBANA_URL/api/status" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Kibana is accessible!" -ForegroundColor Green
} catch {
    Write-Host "❌ Kibana is not accessible. Please check:" -ForegroundColor Red
    Write-Host "   1. Kibana pod is running: kubectl get pods -l app=kibana" -ForegroundColor Yellow
    Write-Host "   2. Service is available: kubectl get svc kibana" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Step-by-Step Dashboard Creation Guide" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Open Kibana in your browser:" -ForegroundColor Yellow
Write-Host "   $KIBANA_URL" -ForegroundColor White
Write-Host ""

Write-Host "2. First, ensure you have a data view configured:" -ForegroundColor Yellow
Write-Host "   - Go to: Stack Management → Data Views" -ForegroundColor White
Write-Host "   - Click 'Create data view'" -ForegroundColor White
Write-Host "   - Name: kubernetes-logs-*" -ForegroundColor White
Write-Host "   - Index pattern: kubernetes-logs-*" -ForegroundColor White
Write-Host "   - Time field: @timestamp" -ForegroundColor White
Write-Host "   - Click 'Create data view'" -ForegroundColor White
Write-Host ""

Write-Host "3. Create Dashboard 1: Cluster Logs Dashboard" -ForegroundColor Yellow
Write-Host "   - Go to: Dashboard → Create Dashboard" -ForegroundColor White
Write-Host "   - Click 'Create visualization'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 1: Log Volume Over Time" -ForegroundColor Cyan
Write-Host "     - Choose: Area chart" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - X-axis: @timestamp (Date Histogram)" -ForegroundColor White
Write-Host "     - Y-axis: Count" -ForegroundColor White
Write-Host "     - Save as: 'Log Volume Over Time'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 2: Logs by Namespace" -ForegroundColor Cyan
Write-Host "     - Choose: Pie chart" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Slice by: kubernetes.namespace_name (Terms)" -ForegroundColor White
Write-Host "     - Size: Count" -ForegroundColor White
Write-Host "     - Save as: 'Logs by Namespace'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 3: Logs by Pod" -ForegroundColor Cyan
Write-Host "     - Choose: Data table" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Rows: kubernetes.pod_name (Terms)" -ForegroundColor White
Write-Host "     - Metric: Count" -ForegroundColor White
Write-Host "     - Save as: 'Logs by Pod'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 4: Error Log Count" -ForegroundColor Cyan
Write-Host "     - Choose: Metric" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Filter: log.level: ERROR" -ForegroundColor White
Write-Host "     - Metric: Count" -ForegroundColor White
Write-Host "     - Save as: 'Error Log Count'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 5: Log Level Distribution" -ForegroundColor Cyan
Write-Host "     - Choose: Pie chart" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Slice by: log.level (Terms)" -ForegroundColor White
Write-Host "     - Size: Count" -ForegroundColor White
Write-Host "     - Save as: 'Log Level Distribution'" -ForegroundColor White
Write-Host ""
Write-Host "   Now add all visualizations to dashboard:" -ForegroundColor Yellow
Write-Host "     - Click 'Add' → 'Existing'" -ForegroundColor White
Write-Host "     - Add all 5 visualizations" -ForegroundColor White
Write-Host "     - Save dashboard as: 'Cluster Logs Dashboard'" -ForegroundColor White
Write-Host ""

Write-Host "4. Create Dashboard 2: Application Logs Dashboard" -ForegroundColor Yellow
Write-Host "   - Go to: Dashboard → Create Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 1: Application Log Volume" -ForegroundColor Cyan
Write-Host "     - Choose: Area chart" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Filter: kubernetes.labels.app: (backend OR frontend)" -ForegroundColor White
Write-Host "     - X-axis: @timestamp (Date Histogram)" -ForegroundColor White
Write-Host "     - Y-axis: Count" -ForegroundColor White
Write-Host "     - Save as: 'Application Log Volume'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 2: Error Logs from Flask Apps" -ForegroundColor Cyan
Write-Host "     - Choose: Data table" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Filter: kubernetes.labels.app: (backend OR frontend) AND log.level: ERROR" -ForegroundColor White
Write-Host "     - Columns: @timestamp, kubernetes.pod_name, log.level, message" -ForegroundColor White
Write-Host "     - Save as: 'Error Logs from Flask Apps'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 3: HTTP Request Logs" -ForegroundColor Cyan
Write-Host "     - Choose: Data table" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Filter: message: *HTTP*" -ForegroundColor White
Write-Host "     - Columns: @timestamp, kubernetes.pod_name, message" -ForegroundColor White
Write-Host "     - Save as: 'HTTP Request Logs'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 4: Logs by Application" -ForegroundColor Cyan
Write-Host "     - Choose: Pie chart" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Filter: kubernetes.labels.app: (backend OR frontend)" -ForegroundColor White
Write-Host "     - Slice by: kubernetes.labels.app (Terms)" -ForegroundColor White
Write-Host "     - Size: Count" -ForegroundColor White
Write-Host "     - Save as: 'Logs by Application'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 5: Response Time from Logs" -ForegroundColor Cyan
Write-Host "     - Choose: Line chart" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Filter: message: *response_time*" -ForegroundColor White
Write-Host "     - X-axis: @timestamp (Date Histogram)" -ForegroundColor White
Write-Host "     - Y-axis: Extract numeric value from message field" -ForegroundColor White
Write-Host "     - Save as: 'Response Time from Logs'" -ForegroundColor White
Write-Host ""
Write-Host "   Add all visualizations and save as: 'Application Logs Dashboard'" -ForegroundColor Yellow
Write-Host ""

Write-Host "5. Create Dashboard 3: Pod and Container Logs Dashboard" -ForegroundColor Yellow
Write-Host "   - Go to: Dashboard → Create Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 1: Logs per Pod" -ForegroundColor Cyan
Write-Host "     - Choose: Data table" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Rows: kubernetes.pod_name (Terms)" -ForegroundColor White
Write-Host "     - Metric: Count" -ForegroundColor White
Write-Host "     - Save as: 'Logs per Pod'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 2: Container stdout/stderr" -ForegroundColor Cyan
Write-Host "     - Choose: Data table" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Filter: stream: (stdout OR stderr)" -ForegroundColor White
Write-Host "     - Rows: stream (Terms)" -ForegroundColor White
Write-Host "     - Columns: kubernetes.container_name" -ForegroundColor White
Write-Host "     - Save as: 'Container stdout/stderr'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 3: Logs by Container Name" -ForegroundColor Cyan
Write-Host "     - Choose: Pie chart" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Slice by: kubernetes.container_name (Terms)" -ForegroundColor White
Write-Host "     - Size: Count" -ForegroundColor White
Write-Host "     - Save as: 'Logs by Container Name'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 4: Recent Log Entries" -ForegroundColor Cyan
Write-Host "     - Choose: Data table" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Sort by: @timestamp (Descending)" -ForegroundColor White
Write-Host "     - Columns: @timestamp, kubernetes.pod_name, kubernetes.container_name, message" -ForegroundColor White
Write-Host "     - Limit: 100" -ForegroundColor White
Write-Host "     - Save as: 'Recent Log Entries'" -ForegroundColor White
Write-Host ""
Write-Host "   Visualization 5: Log Search Interface" -ForegroundColor Cyan
Write-Host "     - Add: Lens visualization" -ForegroundColor White
Write-Host "     - Choose: Data table" -ForegroundColor White
Write-Host "     - Data view: kubernetes-logs-*" -ForegroundColor White
Write-Host "     - Make it searchable/filterable" -ForegroundColor White
Write-Host "     - Save as: 'Log Search Interface'" -ForegroundColor White
Write-Host ""
Write-Host "   Add all visualizations and save as: 'Pod and Container Logs Dashboard'" -ForegroundColor Yellow
Write-Host ""

Write-Host "6. Export Dashboards (Optional)" -ForegroundColor Yellow
Write-Host "   - Go to: Stack Management → Saved Objects" -ForegroundColor White
Write-Host "   - Select all 3 dashboards" -ForegroundColor White
Write-Host "   - Click 'Export'" -ForegroundColor White
Write-Host "   - Save JSON files to: manifests/logging/kibana-dashboards/" -ForegroundColor White
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Quick Access Links" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Kibana Home: $KIBANA_URL" -ForegroundColor Green
Write-Host "Data Views: $KIBANA_URL/app/management/kibana/dataViews" -ForegroundColor Green
Write-Host "Dashboards: $KIBANA_URL/app/dashboards" -ForegroundColor Green
Write-Host "Create Dashboard: $KIBANA_URL/app/dashboards/create" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to open Kibana in your browser..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process $KIBANA_URL

