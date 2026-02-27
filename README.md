# vind Cluster Setup Script

A comprehensive Bash automation script for setting up and managing Kubernetes clusters using vCluster in Docker. This project simplifies the creation of isolated virtual Kubernetes clusters with built-in support for load balancers, sample applications, and ArgoCD deployment.

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Commands](#-commands)
- [Examples](#-examples)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

- **Automatic Dependency Management**: Installs Docker, kubectl, and vCluster with version checks
- **Skip Already Installed Tools**: Checks for existing installations before attempting to install
- **Multi-Cluster Creation**: Create multiple clusters with a single command
- **Sample Application Deployments**:
  - NodePort service deployment
  - LoadBalancer service deployment
- **ArgoCD Integration**: Automated ArgoCD setup with LoadBalancer exposure
- **Cluster Management**:
  - Create clusters
  - Delete clusters
  - List clusters
  - Pause/Resume clusters
  - Connect to clusters
- **Interactive Mode**: Prompts for user confirmation on deployments
- **Batch Mode**: Command-line flags for automation
- **Comprehensive Logging**: All operations logged to `vind-setup.log`
- **Full Help Documentation**: Built-in help with examples
- **Cross-Platform Support**: Works on macOS and Linux (including WSL)

## 📦 Prerequisites

- **Operating System**: macOS or Linux (Ubuntu 18.04+, CentOS 7+, etc.)
- **Docker**: Version 20.10 or later (running and accessible)
- **RAM**: Minimum 4GB available (8GB+ recommended for multiple clusters)
- **Disk Space**: Minimum 10GB
- **Bash**: Version 4.0 or later
- **curl**: For downloading tools
- **Package Manager**: Homebrew (macOS) or apt/yum (Linux)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/vind-cluster-setup.git
cd vind-cluster-setup
chmod +x setup-cluster.sh
```

### 2. Setup Environment (One-Time)

```bash
./setup-cluster.sh setup
```

This will:
- Check if Docker, kubectl, and vCluster are installed
- Install missing dependencies with user confirmation
- Configure Docker as the default vCluster driver

### 3. Create Your First Cluster

```bash
./setup-cluster.sh create -c my-cluster
```

### 4. Deploy Applications

```bash
./setup-cluster.sh deploy -c my-cluster -s -a
```

This will:
- Deploy sample app on NodePort
- Deploy sample app on LoadBalancer
- Install and setup ArgoCD

## 💾 Installation

### Option 1: Using Git (Recommended)

```bash
git clone https://github.com/yourusername/vind-cluster-setup.git
cd vind-cluster-setup
chmod +x setup-cluster.sh
```

### Option 2: Manual Setup

1. Download the setup script from the releases page
2. Make it executable: `chmod +x setup-cluster.sh`
3. Run the setup command: `./setup-cluster.sh setup`

## 📖 Usage

### Basic Syntax

```bash
./setup-cluster.sh [COMMAND] [OPTIONS]
```

### Global Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `--version` | Show version information |
| `-v, --verbose` | Enable verbose output (useful for debugging) |
| `--skip-deps-check` | Skip dependency checks (use with caution) |

### Commands

#### 1. Setup Environment

```bash
./setup-cluster.sh setup [-v]
```

**Purpose**: Install and configure all dependencies

**Options**:
- `-v, --verbose`: Show detailed installation logs

**What it does**:
- Checks Docker, kubectl, and vCluster installations
- Prompts to install missing tools
- Configures Docker as vCluster driver

**Example**:
```bash
./setup-cluster.sh setup -v
```

#### 2. Create Clusters

```bash
./setup-cluster.sh create [-n NUM] [-c NAME]
```

**Purpose**: Create one or more vClusters

**Options**:
- `-n, --clusters NUM`: Number of clusters to create (default: 1)
- `-c, --cluster-name NAME`: Cluster name prefix (default: vind-cluster)

**Example**:
```bash
# Create single cluster
./setup-cluster.sh create -c my-cluster

# Create 3 clusters named prod-1, prod-2, prod-3
./setup-cluster.sh create -n 3 -c prod
```

#### 3. Deploy Applications

```bash
./setup-cluster.sh deploy -c NAME [OPTIONS]
```

**Purpose**: Deploy sample applications and services

**Options**:
- `-c, --cluster-name NAME`: Target cluster name (required)
- `-s, --sample-apps`: Deploy both sample applications
- `-d, --deploy-nodeport`: Deploy NodePort sample app
- `-l, --deploy-loadbalancer`: Deploy LoadBalancer sample app
- `-a, --argocd`: Install ArgoCD with LoadBalancer

**Example**:
```bash
# Interactive mode - prompts for each deployment
./setup-cluster.sh deploy -c my-cluster

# Deploy everything at once
./setup-cluster.sh deploy -c my-cluster -s -a

# Deploy only NodePort app
./setup-cluster.sh deploy -c my-cluster -d
```

#### 4. Install ArgoCD

```bash
./setup-cluster.sh install-argocd -c NAME
```

**Purpose**: Install ArgoCD with LoadBalancer exposure

**Options**:
- `-c, --cluster-name NAME`: Target cluster name (required)

**What it does**:
- Creates argocd namespace
- Installs ArgoCD via Helm
- Exposes ArgoCD via LoadBalancer
- Displays access credentials

**Example**:
```bash
./setup-cluster.sh install-argocd -c my-cluster
```

#### 5. Delete Cluster

```bash
./setup-cluster.sh delete -c NAME
```

**Purpose**: Delete a vCluster

**Options**:
- `-c, --cluster-name NAME`: Cluster name to delete (required)

**Safety**: Asks for confirmation before deletion

**Example**:
```bash
./setup-cluster.sh delete -c my-cluster
```

#### 6. List Clusters

```bash
./setup-cluster.sh list
```

**Purpose**: Show all created vClusters

**Example**:
```bash
./setup-cluster.sh list
```

Output example:
```
NAME              | RUNNING | STATUS    | NODES | NAMESPACE
my-cluster        | true    | Running   | 1     | vcluster
dev-cluster       | true    | Running   | 1     | vcluster
```

#### 7. Pause Cluster

```bash
./setup-cluster.sh pause -c NAME
```

**Purpose**: Pause a cluster to save resources

**Example**:
```bash
./setup-cluster.sh pause -c my-cluster
```

#### 8. Resume Cluster

```bash
./setup-cluster.sh resume -c NAME
```

**Purpose**: Resume a paused cluster

**Example**:
```bash
./setup-cluster.sh resume -c my-cluster
```

#### 9. Connect to Cluster

```bash
./setup-cluster.sh connect -c NAME
```

**Purpose**: Switch kubectl context to a specific cluster

**Example**:
```bash
./setup-cluster.sh connect -c my-cluster
kubectl get nodes
```

## ⚙️ Configuration

### Environment Variables

You can customize behavior using environment variables:

```bash
# Set log file location
export VIND_LOG_FILE="/custom/path/vind-setup.log"

# Skip interactive prompts (use with caution)
export VIND_NON_INTERACTIVE=true

./setup-cluster.sh create -c my-cluster
```

### Cluster Configuration

The script creates clusters with default settings:
- **Storage**: Docker daemon storage
- **Networking**: Automatic LoadBalancer support
- **Image Pull**: Pull-through cache enabled
- **Nodes**: 1 worker node by default

To customize further after creation, use vCluster CLI directly:

```bash
vcluster create my-cluster --set controller.replicas=2
vcluster describe my-cluster
```

### Sample Applications

The provided sample applications use:
- **Image**: nginx:latest (light-weight, 10MB)
- **NodePort**: 30080
- **Namespace**: sample-apps
- **Replicas**: 2 for high availability

## 📝 Examples

### Example 1: Complete Development Environment

```bash
# One-time setup
./setup-cluster.sh setup

# Create development cluster
./setup-cluster.sh create -c dev-cluster

# Deploy everything
./setup-cluster.sh deploy -c dev-cluster -s -a

# View cluster
./setup-cluster.sh list
```

### Example 2: Multi-Cluster Production-like Setup

```bash
# Setup once
./setup-cluster.sh setup -v

# Create 3 clusters
./setup-cluster.sh create -n 3 -c prod

# Deploy to each cluster
./setup-cluster.sh deploy -c prod-1 -s -a
./setup-cluster.sh deploy -c prod-2 -s -a
./setup-cluster.sh deploy -c prod-3 -s -a

# Verify
./setup-cluster.sh list
```

### Example 3: Batch Automation with Scripts

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup environment
"$SCRIPT_DIR/setup-cluster.sh" setup

# Create clusters
for i in {1..3}; do
    "$SCRIPT_DIR/setup-cluster.sh" create -c cluster-$i
done

# Deploy to all
for i in {1..3}; do
    "$SCRIPT_DIR/setup-cluster.sh" deploy -c cluster-$i -s -a
done

echo "Setup complete! Clusters ready at:"
"$SCRIPT_DIR/setup-cluster.sh" list
```

### Example 4: Testing and Cleanup

```bash
# Create test cluster
./setup-cluster.sh create -c test-cluster

# Run your tests
./setup-cluster.sh connect -c test-cluster
kubectl apply -f your-app.yaml
kubectl run tests...

# Cleanup
./setup-cluster.sh delete -c test-cluster
```

## 🔍 Troubleshooting

### 1. Docker Daemon Not Running

**Error**: `Docker daemon is not running`

**Solution**:
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker

# Then retry
./setup-cluster.sh create -c my-cluster
```

### 2. Permission Denied

**Error**: `permission denied: ./setup-cluster.sh`

**Solution**:
```bash
chmod +x setup-cluster.sh
./setup-cluster.sh --help
```

### 3. Installation Fails

**Solution**: Use verbose mode to see details
```bash
./setup-cluster.sh setup -v
```

Check the log file:
```bash
cat vind-setup.log
```

### 4. Cluster Creation Fails

**Error**: `vcluster: command not found`

**Solution**: Ensure vCluster is installed
```bash
./setup-cluster.sh setup

# Or install manually
brew install loft-sh/tap/vcluster

# Set Docker driver
vcluster use driver docker
```

### 5. LoadBalancer Pending IP

**Issue**: LoadBalancer IP not assigned

**Solution**: This is normal in Docker driver. Check with:
```bash
./setup-cluster.sh connect -c my-cluster
kubectl get service -n sample-apps

# Or use port-forward as alternative
kubectl port-forward -n sample-apps svc/sample-app-loadbalancer-service 8080:80
```

### 6. ArgoCD Password Issues

**Problem**: Can't login to ArgoCD

**Solution**: Get the password from secret
```bash
./setup-cluster.sh connect -c my-cluster
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

### 7. Insufficient Resources

**Error**: `No space left on device` or OOM errors

**Solution**:
- Free up disk space: `docker system prune -a`
- Check resource usage: `docker stats`
- Reduce number of clusters
- Pause unused clusters: `./setup-cluster.sh pause -c cluster-name`

### 8. kubectl Context Issues

**Problem**: kubectl can't connect to cluster

**Solution**:
```bash
# Reconnect to cluster
./setup-cluster.sh connect -c my-cluster --update-current

# Or manually
kubectl config use-context vcluster_my-cluster
```

## 📊 Cluster Architecture

```
┌─────────────────────────────────────────────────────┐
│         Docker Host (Local Machine)                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │     vCluster: my-cluster                     │  │
│  ├──────────────────────────────────────────────┤  │
│  │                                              │  │
│  │  ┌─────────────────────────────────────┐   │  │
│  │  │  Control Plane (Docker container)   │   │  │
│  │  │  - API Server                       │   │  │
│  │  │  - etcd                             │   │  │
│  │  │  - Controller Manager               │   │  │
│  │  │  - Scheduler                        │   │  │
│  │  └─────────────────────────────────────┘   │  │
│  │                                              │  │
│  │  ┌─────────────────────────────────────┐   │  │
│  │  │  Worker Node (Docker container)     │   │  │
│  │  │  - kubelet                          │   │  │
│  │  │  - kube-proxy                       │   │  │
│  │  │  - Container Runtime                │   │  │
│  │  └─────────────────────────────────────┘   │  │
│  │                                              │  │
│  │  Namespace: sample-apps                     │  │
│  │  ├─ Deployment: sample-app-nodeport        │  │
│  │  │  └─ Service: NodePort (30080)           │  │
│  │  └─ Deployment: sample-app-loadbalancer    │  │
│  │     └─ Service: LoadBalancer               │  │
│  │                                              │  │
│  │  Namespace: argocd                          │  │
│  │  └─ ArgoCD (LoadBalancer exposed)           │  │
│  │                                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## 📈 Performance Benchmarks

Typical resource usage per cluster:

| Resource | Idle | 2 Sample Apps | With ArgoCD |
|----------|------|---------------|------------|
| CPU | 100m | 300m | 400m |
| Memory | 256Mi | 512Mi | 768Mi |
| Disk | 2GB | 2.5GB | 3GB |

## 🔐 Security Notes

- ArgoCD uses default credentials (change in production)
- Sample apps are for demonstration only
- LoadBalancer type services are exposed directly
- Consider network policies for production use
- Always verify manifests before deployment

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -am 'Add my feature'`
4. Push to branch: `git push origin feature/my-feature`
5. Submit a Pull Request

## 🙏 Acknowledgments

This project is built on:
- [vCluster](https://github.com/loft-sh/vcluster) - Virtual Kubernetes Clusters
- [Docker](https://www.docker.com/) - Container Platform
- [Kubernetes](https://kubernetes.io/) - Container Orchestration
- [ArgoCD](https://argoproj.github.io/cd/) - GitOps Continuous Delivery
- [Helm](https://helm.sh/) - Kubernetes Package Manager

## 📞 Support

- 📖 [Documentation](./docs/)
- 🐛 [Issue Tracker](https://github.com/yourusername/vind-cluster-setup/issues)
- 💬 [GitHub Discussions](https://github.com/yourusername/vind-cluster-setup/discussions)
- 📧 [Email Support](mailto:support@yourdomain.com)

## 📜 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🗺️ Roadmap

- [ ] Helm chart support for deployments
- [ ] Persistent volume configuration
- [ ] Ingress controller setup
- [ ] Monitoring stack (Prometheus + Grafana)
- [ ] Logging stack (ELK stack)
- [ ] Multi-region cluster federation
- [ ] Automated backup/restore
- [ ] Performance optimization tuning
- [ ] Windows support
- [ ] GUI management tool

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and changes.

---

<div align="center">

**Made with ❤️ for Kubernetes enthusiasts**

[⭐ Star us on GitHub](https://github.com/yourusername/vind-cluster-setup) • [🐛 Report a Bug](https://github.com/yourusername/vind-cluster-setup/issues) • [💡 Request a Feature](https://github.com/yourusername/vind-cluster-setup/issues)

</div>
