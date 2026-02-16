# Quick verification script for Kibana setup

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Kibana Setup Verification" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check Kibana pod
Write-Host "1. Checking Kibana pod..." -ForegroundColor Yellow
$kibanaPod = kubectl get pods -l app=kibana -o jsonpath='{.items[0].metadata.name}' 2>$null
if ($kibanaPod) {
    Write-Host "   ✅ Kibana pod: $kibanaPod" -ForegroundColor Green
    $status = kubectl get pod $kibanaPod -o jsonpath='{.status.phase}' 2>$null
    Write-Host "   Status: $status" -ForegroundColor $(if ($status -eq "Running") { "Green" } else { "Yellow" })
} else {
    Write-Host "   ❌ Kibana pod not found" -ForegroundColor Red
}
Write-Host ""

# Check Elasticsearch indices
Write-Host "2. Checking Elasticsearch indices..." -ForegroundColor Yellow
$indices = kubectl exec deployment/elasticsearch -- curl -s "http://localhost:9200/_cat/indices/kubernetes-logs*?v" 2>$null
if ($indices -match "kubernetes-logs") {
    Write-Host "   ✅ Log indices found:" -ForegroundColor Green
    $indices | Select-String "kubernetes-logs" | ForEach-Object { Write-Host "      $_" -ForegroundColor White }
} else {
    Write-Host "   ⚠️  No kubernetes-logs indices found yet" -ForegroundColor Yellow
    Write-Host "      Logs may not have been indexed yet. Wait a few minutes." -ForegroundColor Yellow
}
Write-Host ""

# Check Kibana service
Write-Host "3. Checking Kibana service..." -ForegroundColor Yellow
$kibanaSvc = kubectl get svc kibana -o jsonpath='{.spec.ports[0].nodePort}' 2>$null
if ($kibanaSvc) {
    Write-Host "   ✅ Kibana NodePort: $kibanaSvc" -ForegroundColor Green
    $minikubeIP = minikube ip 2>$null
    if ($minikubeIP) {
        Write-Host "   Access URL: http://$minikubeIP`:$kibanaSvc/" -ForegroundColor Cyan
    }
} else {
    Write-Host "   ❌ Kibana service not found" -ForegroundColor Red
}
Write-Host ""

# Check Elasticsearch connection
Write-Host "4. Checking Elasticsearch connection..." -ForegroundColor Yellow
$esHealth = kubectl exec deployment/elasticsearch -- curl -s "http://localhost:9200/_cluster/health" 2>$null | ConvertFrom-Json 2>$null
if ($esHealth) {
    Write-Host "   ✅ Elasticsearch cluster status: $($esHealth.status)" -ForegroundColor Green
    Write-Host "   Nodes: $($esHealth.number_of_nodes)" -ForegroundColor White
} else {
    Write-Host "   ❌ Cannot connect to Elasticsearch" -ForegroundColor Red
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Next Steps" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Access Kibana: http://$(minikube ip):30601/" -ForegroundColor Yellow
Write-Host "2. Create data view: kubernetes-logs-*" -ForegroundColor Yellow
Write-Host "3. Run dashboard creation script:" -ForegroundColor Yellow
Write-Host "   .\scripts\create-kibana-dashboards.ps1" -ForegroundColor White
Write-Host "4. Or follow the guide: KIBANA_DASHBOARDS_GUIDE.md" -ForegroundColor Yellow
Write-Host ""

