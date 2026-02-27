#!/bin/bash

################################################################################
# vind Cluster Setup Script
# Automates the installation and management of vCluster in Docker environments
# Features: Cluster creation, sample app deployment, ArgoCD setup, cluster deletion
################################################################################

set -E
trap 'error_handler $? $LINENO' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/vind-setup.log"
VERSION="1.0.0"
DOCKER_MIN_VERSION="20.10"
KUBECTL_MIN_VERSION="1.24"
VCLUSTER_MIN_VERSION="0.31.0"

################################################################################
# Logging and Error Handling
################################################################################

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

info() {
    echo -e "${BLUE}ℹ${NC} $@" | tee -a "${LOG_FILE}"
}

success() {
    echo -e "${GREEN}✓${NC} $@" | tee -a "${LOG_FILE}"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $@" | tee -a "${LOG_FILE}"
}

error() {
    echo -e "${RED}✗${NC} $@" | tee -a "${LOG_FILE}"
}

error_handler() {
    local line_number=$2
    error "An error occurred on line ${line_number}"
    exit 1
}

################################################################################
# Help Function
################################################################################

show_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    vind Cluster Setup Script v1.0.0                        ║
║        Automate vCluster creation and management with sample apps          ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./setup-cluster.sh [COMMAND] [OPTIONS]

COMMANDS:
    setup           Setup environment and install dependencies
    create          Create new vCluster instances
    deploy          Deploy sample applications
    install-argocd  Install and setup ArgoCD on cluster
    delete          Delete vCluster instances
    list            List all vClusters
    pause           Pause a cluster
    resume          Resume a paused cluster
    connect         Connect to a specific cluster
    help            Show this help message
    version         Show version information

OPTIONS:
    -n, --clusters <NUM>        Number of clusters to create (default: 1)
    -c, --cluster-name <NAME>   Cluster name prefix (default: vind-cluster)
    -s, --sample-apps           Deploy both sample applications
    -a, --argocd                Install and setup ArgoCD
    -d, --deploy-nodeport       Deploy sample app on NodePort
    -l, --deploy-loadbalancer   Deploy sample app on LoadBalancer
    --skip-deps-check           Skip dependency checks (use with caution)
    -v, --verbose               Enable verbose output
    -h, --help                  Show this help message

EXAMPLES:
    # Full setup with everything
    ./setup-cluster.sh setup -v

    # Create 3 clusters named 'prod-cluster-1', 'prod-cluster-2', etc.
    ./setup-cluster.sh create -n 3 -c prod-cluster

    # Create cluster and deploy sample apps + ArgoCD
    ./setup-cluster.sh create -c my-cluster && ./setup-cluster.sh deploy -c my-cluster -s -a

    # Delete specific cluster
    ./setup-cluster.sh delete -c my-cluster

    # List all clusters
    ./setup-cluster.sh list

    # Connect to cluster
    ./setup-cluster.sh connect -c my-cluster

FEATURES:
    ✓ Automatic dependency installation (Docker, kubectl, vCluster)
    ✓ Duplicate installation checks
    ✓ Interactive prompts for deployments
    ✓ Sample app deployments (NodePort & LoadBalancer)
    ✓ ArgoCD installation with LoadBalancer exposure
    ✓ Comprehensive logging
    ✓ Cluster management (create, delete, pause, resume, list)

REQUIREMENTS:
    • macOS or Linux
    • 4GB minimum available RAM
    • 10GB disk space
    • Bash 4.0+

DOCUMENTATION:
    See README.md for detailed documentation and troubleshooting.

EOF
}

show_version() {
    cat << EOF
vind Cluster Setup Script v${VERSION}

Built on vCluster with Docker support
License: Apache 2.0

EOF
}

################################################################################
# Dependency Check and Installation Functions
################################################################################

check_command_exists() {
    if command -v "$1" &> /dev/null; then
        return 0
    fi
    return 1
}

get_command_version() {
    local cmd=$1
    case $cmd in
        docker)
            docker --version | sed 's/.*version //; s/,.*//' | cut -d' ' -f1
            ;;
        kubectl)
            kubectl version --client --short 2>/dev/null | grep -oP 'v\K[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        vcluster)
            vcluster version 2>/dev/null | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

compare_versions() {
    local version1=$1
    local version2=$2
    
    if [[ "$version1" == "$version2" ]]; then
        return 0
    fi
    
    local IFS=.
    local i ver1=($version1) ver2=($version2)
    
    for ((i = 0; i < ${#ver1[@]} && i < ${#ver2[@]}; i++)); do
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 0
        elif ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 1
        fi
    done
    
    if ((${#ver1[@]} > ${#ver2[@]})); then
        return 0
    fi
    return 1
}

check_docker() {
    info "Checking Docker installation..."
    
    if check_command_exists docker; then
        local version=$(get_command_version docker)
        success "Docker is installed (version: $version)"
        
        if ! docker ps &> /dev/null; then
            error "Docker daemon is not running. Please start Docker and try again."
            exit 1
        fi
        success "Docker daemon is running"
        return 0
    else
        warn "Docker is not installed"
        return 1
    fi
}

check_kubectl() {
    info "Checking kubectl installation..."
    
    if check_command_exists kubectl; then
        local version=$(get_command_version kubectl)
        success "kubectl is installed (version: $version)"
        return 0
    else
        warn "kubectl is not installed"
        return 1
    fi
}

check_vcluster() {
    info "Checking vCluster installation..."
    
    if check_command_exists vcluster; then
        local version=$(get_command_version vcluster)
        success "vCluster is installed (version: $version)"
        return 0
    else
        warn "vCluster is not installed"
        return 1
    fi
}

install_docker() {
    info "Installing Docker..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            info "Installing Docker via Homebrew..."
            brew install docker
            success "Docker installed successfully"
        else
            error "Homebrew not found. Please install Homebrew first: https://brew.sh"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        info "Installing Docker via package manager..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y docker.io
        elif command -v yum &> /dev/null; then
            sudo yum install -y docker
        else
            error "Unsupported package manager. Please install Docker manually."
            exit 1
        fi
        success "Docker installed successfully"
    else
        error "Unsupported operating system"
        exit 1
    fi
}

install_kubectl() {
    info "Installing kubectl..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install kubectl
            success "kubectl installed successfully"
        else
            error "Homebrew not found. Please install Homebrew first: https://brew.sh"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v curl &> /dev/null; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            rm kubectl
            success "kubectl installed successfully"
        else
            error "curl not found. Please install curl first."
            exit 1
        fi
    fi
}

install_vcluster() {
    info "Installing vCluster..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install loft-sh/tap/vcluster
            success "vCluster installed successfully"
        else
            error "Homebrew not found. Please install Homebrew first: https://brew.sh"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v curl &> /dev/null; then
            curl -s -L "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" -o vcluster
            sudo install -c -m 0755 vcluster /usr/local/bin
            rm vcluster
            success "vCluster installed successfully"
        else
            error "curl not found. Please install curl first."
            exit 1
        fi
    fi
    
    # Set Docker as default driver
    info "Configuring vCluster to use Docker driver..."
    vcluster use driver docker
    success "Docker driver set as default"
}

setup_environment() {
    info "Starting environment setup..."
    
    local docker_installed=true
    local kubectl_installed=true
    local vcluster_installed=true
    
    check_docker || docker_installed=false
    check_kubectl || kubectl_installed=false
    check_vcluster || vcluster_installed=false
    
    if [ "$docker_installed" = false ]; then
        warn "Docker not found in system"
        read -p "Install Docker? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_docker
        else
            error "Docker is required. Installation cancelled."
            exit 1
        fi
    fi
    
    if [ "$kubectl_installed" = false ]; then
        warn "kubectl not found in system"
        read -p "Install kubectl? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_kubectl
        else
            error "kubectl is required. Installation cancelled."
            exit 1
        fi
    fi
    
    if [ "$vcluster_installed" = false ]; then
        warn "vCluster not found in system"
        read -p "Install vCluster? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_vcluster
        else
            error "vCluster is required. Installation cancelled."
            exit 1
        fi
    fi
    
    success "Environment setup completed successfully!"
}

################################################################################
# Cluster Management Functions
################################################################################

create_clusters() {
    local num_clusters=${1:-1}
    local cluster_prefix=${2:-"vind-cluster"}
    
    info "Creating ${num_clusters} cluster(s) with prefix '${cluster_prefix}'..."
    
    for ((i = 1; i <= num_clusters; i++)); do
        local cluster_name="${cluster_prefix}-${i}"
        
        info "Creating cluster: ${cluster_name}"
        
        if vcluster list | grep -q "$cluster_name"; then
            warn "Cluster '${cluster_name}' already exists. Skipping..."
        else
            vcluster create "$cluster_name" --expose
            
            if [ $? -eq 0 ]; then
                success "Cluster '${cluster_name}' created successfully"
            else
                error "Failed to create cluster '${cluster_name}'"
            fi
        fi
    done
    
    success "Cluster creation completed!"
}

list_clusters() {
    info "Listing all vClusters..."
    vcluster list
}

delete_cluster() {
    local cluster_name=$1
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    info "Deleting cluster: ${cluster_name}"
    
    read -p "Are you sure you want to delete '${cluster_name}'? (yes/no) " -r
    if [[ $REPLY == "yes" ]]; then
        vcluster delete "$cluster_name"
        success "Cluster '${cluster_name}' deleted successfully"
    else
        warn "Deletion cancelled"
    fi
}

pause_cluster() {
    local cluster_name=$1
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    info "Pausing cluster: ${cluster_name}"
    vcluster pause "$cluster_name"
    success "Cluster '${cluster_name}' paused"
}

resume_cluster() {
    local cluster_name=$1
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    info "Resuming cluster: ${cluster_name}"
    vcluster resume "$cluster_name"
    success "Cluster '${cluster_name}' resumed"
}

connect_cluster() {
    local cluster_name=$1
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    info "Connecting to cluster: ${cluster_name}"
    vcluster connect "$cluster_name"
}

################################################################################
# Application Deployment Functions
################################################################################

deploy_sample_app_nodeport() {
    local cluster_name=$1
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    info "Deploying sample app on NodePort for cluster: ${cluster_name}"
    
    # Connect to cluster
    vcluster connect "$cluster_name" --update-current &> /dev/null
    
    # Create namespace
    kubectl create namespace sample-apps 2>/dev/null || true
    
    # Deploy sample app
    cat << 'NODEPORT_MANIFEST' | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: sample-apps
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app-nodeport
  namespace: sample-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app-nodeport
  template:
    metadata:
      labels:
        app: sample-app-nodeport
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-nodeport-service
  namespace: sample-apps
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: sample-app-nodeport
NODEPORT_MANIFEST

    if [ $? -eq 0 ]; then
        success "Sample app deployed on NodePort (Port: 30080)"
        info "Access the app at: http://localhost:30080"
    else
        error "Failed to deploy sample app on NodePort"
    fi
}

deploy_sample_app_loadbalancer() {
    local cluster_name=$1
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    info "Deploying sample app on LoadBalancer for cluster: ${cluster_name}"
    
    # Connect to cluster
    vcluster connect "$cluster_name" --update-current &> /dev/null
    
    # Create namespace
    kubectl create namespace sample-apps 2>/dev/null || true
    
    # Deploy sample app
    cat << 'LB_MANIFEST' | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: sample-apps
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app-loadbalancer
  namespace: sample-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app-loadbalancer
  template:
    metadata:
      labels:
        app: sample-app-loadbalancer
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-loadbalancer-service
  namespace: sample-apps
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: sample-app-loadbalancer
LB_MANIFEST

    if [ $? -eq 0 ]; then
        success "Sample app deployed on LoadBalancer"
        info "Waiting for LoadBalancer IP to be assigned..."
        kubectl get service -n sample-apps sample-app-loadbalancer-service --watch
    else
        error "Failed to deploy sample app on LoadBalancer"
    fi
}

install_argocd() {
    local cluster_name=$1
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    info "Installing ArgoCD on cluster: ${cluster_name}"
    
    # Connect to cluster
    vcluster connect "$cluster_name" --update-current &> /dev/null
    
    # Create namespace
    kubectl create namespace argocd 2>/dev/null || true
    
    # Add Helm repo for ArgoCD
    info "Adding ArgoCD Helm repository..."
    helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
    helm repo update
    
    # Install ArgoCD via Helm (more reliable than manual manifests)
    info "Installing ArgoCD via Helm..."
    helm install argocd argo/argo-cd \
        --namespace argocd \
        --set server.service.type=LoadBalancer \
        --set server.insecure=true \
        --values - << 'EOF'
server:
  service:
    type: LoadBalancer
  insecure: true
  config:
    url: http://localhost
  extraArgs:
    - --port=8080
configs:
  secret:
    argocdServerAdminPassword: '$2a$10$YvSJr0s7d3l4jxc5K9H5teD5ZoWKcYzX5G7l8X5e5O5X5X5X5X5X5'
EOF

    if [ $? -eq 0 ]; then
        success "ArgoCD installed successfully"
        
        # Wait for LoadBalancer to get an IP
        info "Waiting for LoadBalancer IP assignment..."
        sleep 10
        
        local lb_ip=$(kubectl get service -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        local lb_hostname=$(kubectl get service -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
        
        if [ -n "$lb_ip" ]; then
            success "ArgoCD is accessible at: http://${lb_ip}"
        elif [ -n "$lb_hostname" ]; then
            success "ArgoCD is accessible at: http://${lb_hostname}"
        else
            warn "LoadBalancer IP/Hostname not yet assigned. Please check with:"
            warn "kubectl get service -n argocd argocd-server"
        fi
        
        # Get default password
        local password=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d)
        info "Default username: admin"
        info "Default password: ${password}"
    else
        error "Failed to install ArgoCD"
    fi
}

deploy_applications() {
    local cluster_name=$1
    local deploy_nodeport=${2:-false}
    local deploy_loadbalancer=${3:-false}
    local deploy_argocd=${4:-false}
    
    if [ -z "$cluster_name" ]; then
        error "Cluster name is required"
        exit 1
    fi
    
    if [ "$deploy_nodeport" = false ] && [ "$deploy_loadbalancer" = false ] && [ "$deploy_argocd" = false ]; then
        # Interactive mode
        read -p "Deploy sample app on NodePort? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            deploy_sample_app_nodeport "$cluster_name"
        fi
        
        read -p "Deploy sample app on LoadBalancer? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            deploy_sample_app_loadbalancer "$cluster_name"
        fi
        
        read -p "Install ArgoCD? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_argocd "$cluster_name"
        fi
    else
        [ "$deploy_nodeport" = true ] && deploy_sample_app_nodeport "$cluster_name"
        [ "$deploy_loadbalancer" = true ] && deploy_sample_app_loadbalancer "$cluster_name"
        [ "$deploy_argocd" = true ] && install_argocd "$cluster_name"
    fi
}

################################################################################
# Main Function
################################################################################

main() {
    # Initialize log file
    {
        echo "======================================"
        echo "vind Cluster Setup Script - Execution Log"
        echo "Started at: $(date)"
        echo "======================================"
    } >> "${LOG_FILE}"
    
    # Parse arguments
    local command=""
    local num_clusters=1
    local cluster_name="vind-cluster"
    local deploy_nodeport=false
    local deploy_loadbalancer=false
    local deploy_argocd=false
    local skip_deps_check=false
    local verbose=false
    
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            setup)
                command="setup"
                shift
                ;;
            create)
                command="create"
                shift
                ;;
            deploy)
                command="deploy"
                shift
                ;;
            install-argocd)
                command="install-argocd"
                shift
                ;;
            delete)
                command="delete"
                shift
                ;;
            list)
                command="list"
                shift
                ;;
            pause)
                command="pause"
                shift
                ;;
            resume)
                command="resume"
                shift
                ;;
            connect)
                command="connect"
                shift
                ;;
            version)
                show_version
                exit 0
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -n|--clusters)
                num_clusters="$2"
                shift 2
                ;;
            -c|--cluster-name)
                cluster_name="$2"
                shift 2
                ;;
            -s|--sample-apps)
                deploy_nodeport=true
                deploy_loadbalancer=true
                shift
                ;;
            -a|--argocd)
                deploy_argocd=true
                shift
                ;;
            -d|--deploy-nodeport)
                deploy_nodeport=true
                shift
                ;;
            -l|--deploy-loadbalancer)
                deploy_loadbalancer=true
                shift
                ;;
            --skip-deps-check)
                skip_deps_check=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                set -x
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Execute command
    case $command in
        setup)
            setup_environment
            ;;
        create)
            create_clusters "$num_clusters" "$cluster_name"
            ;;
        deploy)
            deploy_applications "$cluster_name" "$deploy_nodeport" "$deploy_loadbalancer" "$deploy_argocd"
            ;;
        install-argocd)
            install_argocd "$cluster_name"
            ;;
        delete)
            delete_cluster "$cluster_name"
            ;;
        list)
            list_clusters
            ;;
        pause)
            pause_cluster "$cluster_name"
            ;;
        resume)
            resume_cluster "$cluster_name"
            ;;
        connect)
            connect_cluster "$cluster_name"
            ;;
        *)
            if [ -z "$command" ]; then
                show_help
            else
                error "Unknown command: $command"
                show_help
                exit 1
            fi
            ;;
    esac
    
    # Log completion
    echo "Completed at: $(date)" >> "${LOG_FILE}"
}

# Run main function
main "$@"
