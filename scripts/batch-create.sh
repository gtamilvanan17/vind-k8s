#!/bin/bash

################################################################################
# Batch Cluster Creation Script
# Creates multiple clusters automatically
# Usage: ./batch-create.sh [number-of-clusters] [prefix-name]
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NUM_CLUSTERS="${1:-3}"
PREFIX="${2:-batch-cluster}"

echo "🔄 Batch Cluster Creation"
echo "========================"
echo "Number of clusters: $NUM_CLUSTERS"
echo "Prefix: $PREFIX"
echo ""

read -p "This will create $NUM_CLUSTERS clusters. Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

echo ""
echo "🚀 Starting batch creation..."

for ((i = 1; i <= NUM_CLUSTERS; i++)); do
    CLUSTER_NAME="${PREFIX}-${i}"
    echo ""
    echo "Creating cluster $i of $NUM_CLUSTERS: $CLUSTER_NAME"
    
    "$SCRIPT_DIR/../setup-cluster.sh" create -c "$CLUSTER_NAME"
done

echo ""
echo "✅ Batch creation complete!"
echo ""
echo "Clusters created:"
"$SCRIPT_DIR/../setup-cluster.sh" list
