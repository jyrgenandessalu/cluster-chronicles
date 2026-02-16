#!/bin/bash
# Script to configure Elasticsearch Index Lifecycle Management (ILM) for log rotation and retention

set -e

ELASTICSEARCH_SERVICE="elasticsearch"
ELASTICSEARCH_PORT="9200"
ES_URL="http://${ELASTICSEARCH_SERVICE}:${ELASTICSEARCH_PORT}"

echo "Waiting for Elasticsearch to be ready..."
kubectl wait --for=condition=ready pod -l app=elasticsearch --timeout=300s

echo "Configuring Elasticsearch ILM policy..."

# Get Elasticsearch pod name
ES_POD=$(kubectl get pods -l app=elasticsearch -o jsonpath='{.items[0].metadata.name}')

# Create ILM policy
echo "Creating ILM policy: kubernetes-logs-policy"
kubectl exec $ES_POD -- curl -s -X PUT "${ES_URL}/_ilm/policy/kubernetes-logs-policy" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_size": "10GB",
            "max_age": "1d"
          },
          "set_priority": {
            "priority": 100
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "set_priority": {
            "priority": 50
          },
          "allocate": {
            "number_of_replicas": 0
          }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
EOF

# Create index template with ILM policy
echo "Creating index template: kubernetes-logs-template"
kubectl exec $ES_POD -- curl -s -X PUT "${ES_URL}/_index_template/kubernetes-logs-template" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "index_patterns": ["kubernetes-logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.lifecycle.name": "kubernetes-logs-policy",
      "index.lifecycle.rollover_alias": "kubernetes-logs"
    }
  },
  "priority": 200
}
EOF

# Verify ILM policy
echo ""
echo "Verifying ILM policy..."
kubectl exec $ES_POD -- curl -s -X GET "${ES_URL}/_ilm/policy/kubernetes-logs-policy" | python3 -m json.tool

echo ""
echo "=========================================="
echo "Elasticsearch ILM Configuration Complete"
echo "=========================================="
echo ""
echo "Policy Details:"
echo "  - Hot Phase: Logs kept for 1 day or until 10GB, then rolled over"
echo "  - Warm Phase: After 7 days, reduce replicas to 0"
echo "  - Delete Phase: Logs deleted after 30 days"
echo ""
echo "To check ILM status:"
echo "  kubectl exec $ES_POD -- curl -s '${ES_URL}/_ilm/explain/kubernetes-logs-*' | python3 -m json.tool"
echo ""

