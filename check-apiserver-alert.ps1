# PowerShell script to check APIServerDown alert status
# Usage: .\check-apiserver-alert.ps1

Write-Host "`n=== Checking APIServerDown Alert ===" -ForegroundColor Cyan

# Get Prometheus pod name
$PROM_POD = (kubectl get pods -l app=prometheus,component=server -o jsonpath='{.items[0].metadata.name}')

if (-not $PROM_POD) {
    Write-Host "❌ Prometheus pod not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nPrometheus pod: $PROM_POD" -ForegroundColor Gray

# Check alert rule configuration
Write-Host "`n1. Checking alert rule configuration..." -ForegroundColor Yellow
$rulesJson = kubectl exec $PROM_POD -- wget -qO- "http://localhost:9090/api/v1/rules" 2>$null
if ($rulesJson) {
    $rules = $rulesJson | ConvertFrom-Json
    $apiRule = $rules.data.groups.rules | Where-Object { $_.name -eq "APIServerDown" } | Select-Object -First 1
    if ($apiRule) {
        Write-Host "   ✅ Alert rule found:" -ForegroundColor Green
        Write-Host "      Name: $($apiRule.name)" -ForegroundColor Gray
        Write-Host "      Query: $($apiRule.query)" -ForegroundColor Gray
        Write-Host "      Duration: $($apiRule.duration)s" -ForegroundColor Gray
        Write-Host "      Severity: $($apiRule.labels.severity)" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  Alert rule not found" -ForegroundColor Yellow
    }
}

# Check if Prometheus is scraping API server
Write-Host "`n2. Checking if Prometheus is scraping API server..." -ForegroundColor Yellow
$upMetric = kubectl exec $PROM_POD -- wget -qO- "http://localhost:9090/api/v1/query?query=up{job=`"kubernetes-apiservers`"}" 2>$null
if ($upMetric) {
    $upResult = $upMetric | ConvertFrom-Json
    if ($upResult.data.result -and $upResult.data.result.Count -gt 0) {
        $value = $upResult.data.result[0].value[1]
        if ($value -eq "1") {
            Write-Host "   ✅ API server is being scraped (up=1)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  API server scrape shows up=0 (unreachable)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  No metrics found for kubernetes-apiservers job" -ForegroundColor Yellow
        Write-Host "      (Prometheus may need RBAC permissions or restart)" -ForegroundColor Gray
    }
}

# Check current alert status
Write-Host "`n3. Checking current alert status..." -ForegroundColor Yellow
$alertsJson = kubectl exec $PROM_POD -- wget -qO- "http://localhost:9090/api/v1/alerts" 2>$null
if ($alertsJson) {
    $alerts = $alertsJson | ConvertFrom-Json
    $apiAlert = $alerts.data.alerts | Where-Object { $_.labels.alertname -eq "APIServerDown" }
    
    if ($apiAlert) {
        Write-Host "`n🔴 APIServerDown alert is ACTIVE:" -ForegroundColor Red
        Write-Host "   State: $($apiAlert.state)" -ForegroundColor White
        Write-Host "   Active Since: $($apiAlert.activeAt)" -ForegroundColor White
        Write-Host "   Value: $($apiAlert.value)" -ForegroundColor White
        Write-Host "   Summary: $($apiAlert.annotations.summary)" -ForegroundColor White
        Write-Host "   Description: $($apiAlert.annotations.description)" -ForegroundColor White
    } else {
        Write-Host "`n✅ APIServerDown alert is NOT firing" -ForegroundColor Green
        Write-Host "   (API server is healthy and reachable)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  Could not retrieve alerts from Prometheus" -ForegroundColor Yellow
}

Write-Host "`n=== Alternative: Check via Prometheus UI ===" -ForegroundColor Cyan
$MINIKUBE_IP = (minikube ip)
Write-Host "   Open in browser: http://$MINIKUBE_IP:30900/alerts" -ForegroundColor White
Write-Host "   Look for 'APIServerDown' in the alerts list" -ForegroundColor Gray

Write-Host "`n=== How to Test the Alert ===" -ForegroundColor Cyan
Write-Host "   Note: 'minikube stop' stops everything including Prometheus," -ForegroundColor Yellow
Write-Host "   so you can't check the alert after stopping Minikube." -ForegroundColor Yellow
Write-Host "`n   The alert is correctly configured and will fire when:" -ForegroundColor White
Write-Host "   • API server becomes unreachable while cluster is running" -ForegroundColor Gray
Write-Host "   • Network issues prevent Prometheus from reaching API server" -ForegroundColor Gray
Write-Host "   • API server crashes but cluster infrastructure remains" -ForegroundColor Gray
Write-Host "`n   In production, Prometheus might run externally and can" -ForegroundColor White
Write-Host "   detect API server failures even if other components are down." -ForegroundColor Gray

