#!/bin/bash

################################################################################
# Cleanup Script
# Removes all vClusters and cleans up Docker resources
# Usage: ./cleanup-all.sh [--remove-images]
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOVE_IMAGES="${1:-false}"

if [[ "$1" == "--remove-images" ]]; then
    REMOVE_IMAGES=true
fi

echo "🗑️  vind Cluster Cleanup"
echo "====================="
echo ""

# Get all clusters
echo "📋 Fetching all clusters..."
CLUSTERS=$(grep -oP 'NAME\s+\|\s*\K.*' <(vcluster list) | awk '{print $1}' 2>/dev/null || echo "")

if [ -z "$CLUSTERS" ]; then
    echo "✅ No clusters found to clean up"
else
    echo "Found clusters:"
    echo "$CLUSTERS"
    echo ""
    
    read -p "Delete all clusters? (yes/no) " confirmation
    
    if [[ "$confirmation" == "yes" ]]; then
        while IFS= read -r cluster; do
            if [ ! -z "$cluster" ]; then
                echo "Deleting cluster: $cluster"
                vcluster delete "$cluster" 2>/dev/null || echo "Failed to delete $cluster"
            fi
        done <<< "$CLUSTERS"
        
        echo "✅ All clusters deleted"
    else
        echo "⚠️  Cleanup cancelled"
        exit 0
    fi
fi

echo ""
echo "🐳 Cleaning up Docker resources..."
docker system prune -f --volumes

if [[ "$REMOVE_IMAGES" == "true" ]]; then
    echo "Removing vCluster Docker images..."
    docker rmi $(docker images | grep -i vcluster | awk '{print $3}') 2>/dev/null || true
    echo "✅ Images removed"
fi

echo ""
echo "✅ Cleanup Complete!"
