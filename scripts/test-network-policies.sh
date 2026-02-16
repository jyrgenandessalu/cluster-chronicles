#!/bin/bash
# Test script to verify network policies are working correctly

set -e

echo "=========================================="
echo "Testing Network Policies"
echo "=========================================="
echo ""

# Get pod names
BACKEND_POD=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].metadata.name}')
FRONTEND_POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}')

echo "Backend Pod: $BACKEND_POD"
echo "Frontend Pod: $FRONTEND_POD"
echo ""

# Test 1: Frontend can reach backend (should work)
echo "Test 1: Frontend → Backend (should work)"
if kubectl exec $FRONTEND_POD -- python -c "import urllib.request; urllib.request.urlopen('http://backend:5000/').read()" 2>/dev/null; then
    echo "✅ PASS: Frontend can reach backend"
else
    echo "❌ FAIL: Frontend cannot reach backend"
fi
echo ""

# Test 2: Backend can reach Prometheus (should work)
echo "Test 2: Backend → Prometheus (should work)"
if kubectl exec $BACKEND_POD -- python -c "import urllib.request; urllib.request.urlopen('http://prometheus:9090/api/v1/status/config').read()" 2>/dev/null; then
    echo "✅ PASS: Backend can reach Prometheus"
else
    echo "❌ FAIL: Backend cannot reach Prometheus"
fi
echo ""

# Test 3: Check network policies are applied
echo "Test 3: Network Policies Applied"
POLICIES=$(kubectl get networkpolicies --no-headers | wc -l)
if [ "$POLICIES" -ge 3 ]; then
    echo "✅ PASS: $POLICIES network policies found"
    kubectl get networkpolicies
else
    echo "❌ FAIL: Expected at least 3 network policies, found $POLICIES"
fi
echo ""

echo "=========================================="
echo "Network Policy Test Complete"
echo "=========================================="

