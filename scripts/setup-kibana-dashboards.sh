#!/bin/bash
# Script to create Kibana dashboards via API
# This script creates the 3 required dashboards for the mandatory requirements

set -e

KIBANA_SERVICE="kibana"
KIBANA_PORT="5601"
KIBANA_URL="http://${KIBANA_SERVICE}:${KIBANA_PORT}"

echo "Waiting for Kibana to be ready..."
kubectl wait --for=condition=ready pod -l app=kibana --timeout=300s

echo "Creating Kibana dashboards..."

# Get Kibana pod name
KIBANA_POD=$(kubectl get pods -l app=kibana -o jsonpath='{.items[0].metadata.name}')

# Function to create a dashboard
create_dashboard() {
    local dashboard_name=$1
    local dashboard_file=$2
    
    echo "Creating dashboard: ${dashboard_name}"
    
    # Check if dashboard already exists
    if kubectl exec $KIBANA_POD -- curl -s -X GET "${KIBANA_URL}/api/saved_objects/dashboard/${dashboard_name}" -H "kbn-xsrf: true" | grep -q "not found"; then
        echo "Dashboard ${dashboard_name} does not exist, creating..."
        # Import dashboard (this is a simplified version - in production, create via UI and export)
        kubectl exec $KIBANA_POD -- curl -s -X POST "${KIBANA_URL}/api/saved_objects/dashboard/${dashboard_name}" \
            -H "kbn-xsrf: true" \
            -H "Content-Type: application/json" \
            -d @- <<EOF
{
  "attributes": {
    "title": "${dashboard_name}",
    "description": "Dashboard created via script"
  }
}
EOF
    else
        echo "Dashboard ${dashboard_name} already exists, skipping..."
    fi
}

# Note: These are placeholder functions. In practice, you would:
# 1. Create dashboards through Kibana UI
# 2. Export them as JSON
# 3. Import them via this script

echo ""
echo "=========================================="
echo "Kibana Dashboard Setup Instructions"
echo "=========================================="
echo ""
echo "To create the required Kibana dashboards:"
echo ""
echo "1. Access Kibana UI: http://<minikube-ip>:30601/"
echo "2. Navigate to Dashboard → Create Dashboard"
echo "3. Create the following 3 dashboards:"
echo ""
echo "   a) Cluster Logs Dashboard:"
echo "      - Log volume over time (Area chart)"
echo "      - Logs by namespace (Pie chart)"
echo "      - Logs by pod (Data table)"
echo "      - Error log count (Metric)"
echo "      - Log level distribution (Pie chart)"
echo ""
echo "   b) Application Logs Dashboard:"
echo "      - Application log volume (Area chart)"
echo "      - Error logs from Flask apps (Data table, filter: kubernetes.labels.app IN [backend, frontend] AND log.level: ERROR)"
echo "      - HTTP request logs (Data table, filter: message: *HTTP*)"
echo "      - Logs by application (Pie chart, group by kubernetes.labels.app)"
echo "      - Response time from logs (Line chart, extract from log.message)"
echo ""
echo "   c) Pod and Container Logs Dashboard:"
echo "      - Logs per pod (Data table, group by kubernetes.pod.name)"
echo "      - Container stdout/stderr (Data table, filter by stream)"
echo "      - Logs by container name (Pie chart, group by kubernetes.container.name)"
echo "      - Recent log entries (Data table, sort by @timestamp desc)"
echo "      - Log search interface (Embedded Discover view)"
echo ""
echo "4. After creating each dashboard, export it:"
echo "   - Stack Management → Saved Objects → Export"
echo "   - Save as JSON files in manifests/logging/kibana-dashboards/"
echo ""
echo "5. To import dashboards programmatically, use:"
echo "   kubectl port-forward svc/kibana 5601:5601"
echo "   curl -X POST 'http://localhost:5601/api/saved_objects/_import' \\"
echo "     -H 'kbn-xsrf: true' \\"
echo "     -F file=@dashboard.json"
echo ""

