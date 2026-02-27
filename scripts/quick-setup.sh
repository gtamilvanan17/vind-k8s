#!/bin/bash

################################################################################
# Quick Setup Script
# One-line execution for rapid cluster setup
# Usage: ./quick-setup.sh [cluster-name] [any-additional-args]
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="${1:-vind-cluster}"
DEPLOY_SAMPLES="${2:-y}"

echo "🚀 Quick vind Cluster Setup"
echo "============================"
echo "Cluster Name: $CLUSTER_NAME"
echo "Deploy Sample Apps: $DEPLOY_SAMPLES"
echo ""

# Setup environment
echo "📦 Setting up environment..."
"$SCRIPT_DIR/setup-cluster.sh" setup

# Create cluster
echo "🔧 Creating cluster..."
"$SCRIPT_DIR/setup-cluster.sh" create -c "$CLUSTER_NAME"

# Deploy applications
if [[ "$DEPLOY_SAMPLES" == "y" ]] || [[ "$DEPLOY_SAMPLES" == "Y" ]]; then
    echo "🚀 Deploying sample applications..."
    "$SCRIPT_DIR/setup-cluster.sh" deploy -c "$CLUSTER_NAME" -s -a
fi

echo ""
echo "✅ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. View your cluster: $SCRIPT_DIR/setup-cluster.sh list"
echo "2. Connect to cluster: $SCRIPT_DIR/setup-cluster.sh connect -c $CLUSTER_NAME"
echo "3. Check services: kubectl get services -A"
echo ""
echo "Sample apps deployed in 'sample-apps' namespace"
echo "ArgoCD deployed in 'argocd' namespace"
