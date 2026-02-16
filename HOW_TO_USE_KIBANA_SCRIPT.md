# How to Use the Kibana Dashboard Creation Script

## Quick Start

### Step 1: Open PowerShell
- Press `Win + X` and select "Windows PowerShell" or "Terminal"
- Or search for "PowerShell" in the Start menu

### Step 2: Navigate to Project Directory
```powershell
cd C:\Users\Jürgen\cluster-chronicles
```

### Step 3: Run the Script
```powershell
.\scripts\create-kibana-dashboards.ps1
```

## What the Script Does

1. **Checks Kibana Accessibility**
   - Verifies Kibana is running and accessible
   - Shows you the Kibana URL

2. **Displays Step-by-Step Instructions**
   - Shows detailed instructions for creating each dashboard
   - Lists all visualizations needed for each dashboard
   - Provides exact field names and configurations

3. **Opens Kibana in Browser**
   - Automatically opens Kibana in your default browser
   - Takes you directly to the dashboard creation page

## Alternative: Manual Steps

If you prefer not to use the script, you can:

1. **Access Kibana directly:**
   ```
   http://192.168.59.101:30601/
   ```
   (Get your Minikube IP with: `minikube ip`)

2. **Follow the guide:**
   - Open `KIBANA_DASHBOARDS_GUIDE.md`
   - Follow the step-by-step instructions

## Troubleshooting

### Script Won't Run
If you get an execution policy error:
```powershell
# Check current policy
Get-ExecutionPolicy

# If it's Restricted, run:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Script Opens but Kibana Doesn't Load
- Check if Kibana pod is running: `kubectl get pods -l app=kibana`
- Verify service: `kubectl get svc kibana`
- Get Minikube IP: `minikube ip`
- Try accessing manually: `http://<minikube-ip>:30601/`

### Need Help?
- Check `KIBANA_DASHBOARDS_GUIDE.md` for detailed instructions
- Run verification: `.\scripts\verify-kibana-setup.ps1`

