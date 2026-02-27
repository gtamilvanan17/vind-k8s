# Installation Guide

## Table of Contents

- [System Requirements](#system-requirements)
- [Installation Methods](#installation-methods)
- [Verification](#verification)
- [Post-Installation](#post-installation)
- [Uninstallation](#uninstallation)
- [Troubleshooting](#troubleshooting)

## System Requirements

### Operating System

| OS | Version | Status |
|----|---------|--------|
| macOS | 10.14+ | ✅ Tested |
| Ubuntu | 18.04+ | ✅ Tested |
| CentOS | 7+ | ✅ Tested |
| Debian | 10+ | ✅ Tested |
| WSL 2 | Any | ✅ Supported |

### Hardware Requirements

- **Minimum**:
  - 2 CPU cores
  - 4GB RAM
  - 10GB disk space

- **Recommended** (for multiple clusters):
  - 4+ CPU cores
  - 8GB+ RAM
  - 20GB+ disk space

### Software Requirements

- **Bash**: 4.0 or later
- **curl**: For downloading tools
- **Package Manager**: 
  - Homebrew (macOS)
  - apt or yum (Linux)

## Installation Methods

### Method 1: Quick Install (Recommended)

The fastest way to get started:

```bash
# Clone the repository
git clone https://github.com/yourusername/vind-cluster-setup.git
cd vind-cluster-setup

# Make scripts executable
chmod +x setup-cluster.sh scripts/*.sh

# Run installation
./setup-cluster.sh setup

# Optional: Create your first cluster
./setup-cluster.sh create -c my-cluster
```

### Method 2: Step-by-Step Installation

For more control over the installation:

#### On macOS:

```bash
# 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Docker
brew install docker

# 3. Start Docker
open -a Docker

# 4. Install kubectl
brew install kubectl

# 5. Install vCluster
brew tap loft-sh/tap
brew install vcluster

# 6. Set Docker driver
vcluster use driver docker

# 7. Clone vind setup scripts
git clone https://github.com/yourusername/vind-cluster-setup.git
cd vind-cluster-setup
chmod +x setup-cluster.sh scripts/*.sh
```

#### On Linux (Ubuntu/Debian):

```bash
# 1. Update package manager
sudo apt-get update

# 2. Install Docker
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
newgrp docker  # Apply group changes

# 3. Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# 4. Install kubectl
sudo apt-get install -y kubectl

# 5. Install vCluster
curl -s -L "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" -o vcluster
sudo install -c -m 0755 vcluster /usr/local/bin
rm vcluster

# 6. Set Docker driver
vcluster use driver docker

# 7. Clone vind setup scripts
git clone https://github.com/yourusername/vind-cluster-setup.git
cd vind-cluster-setup
chmod +x setup-cluster.sh scripts/*.sh
```

#### On Linux (CentOS/RHEL):

```bash
# 1. Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# 2. Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 3. Install vCluster
curl -s -L "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" -o vcluster
sudo install -c -m 0755 vcluster /usr/local/bin
rm vcluster

# 4. Set Docker driver
vcluster use driver docker

# 5. Clone vind setup scripts
git clone https://github.com/yourusername/vind-cluster-setup.git
cd vind-cluster-setup
chmod +x setup-cluster.sh scripts/*.sh
```

### Method 3: Docker Container Installation

Run the scripts inside Docker:

```bash
# Build container
docker build -t vind-setup .

# Run setup
docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -v ~/.kube:/root/.kube \
           -it vind-setup ./setup-cluster.sh setup
```

## Verification

Verify that everything is installed correctly:

```bash
# Check script accessibility
./setup-cluster.sh --version
# Output: vind Cluster Setup Script v1.0.0

# Check Docker
docker --version
# Output: Docker version 20.10.x...

# Check kubectl
kubectl version --client
# Output: Client Version: v1.25.x...

# Check vCluster
vcluster version
# Output: vcluster version v0.31.x...
```

### Quick Test

```bash
# Navigate to the installation directory
cd /path/to/vind-cluster-setup

# Test help command
./setup-cluster.sh help

# Create test cluster
./setup-cluster.sh create -c test-cluster

# Verify cluster
vcluster list

# Cleanup
./setup-cluster.sh delete -c test-cluster
```

## Post-Installation

### 1. Initial Setup

Run the setup command once:

```bash
./setup-cluster.sh setup
```

This will:
- Verify all dependencies
- Install missing tools (with confirmation)
- Configure Docker driver for vCluster

### 2. Configure kubectl

Ensure kubectl can access your clusters:

```bash
# Test kubectl
kubectl cluster-info

# If it fails, run setup again
./setup-cluster.sh setup
```

### 3. Optional: Add to PATH

For system-wide access:

```bash
# macOS/Linux
sudo cp setup-cluster.sh /usr/local/bin/vind-setup
sudo chmod +x /usr/local/bin/vind-setup

# Now you can run from anywhere
vind-setup create -c my-cluster
```

### 4. Create Alias (Optional)

Add to your shell profile (~/.bash_profile or ~/.zshrc):

```bash
# Add alias
alias vind='/path/to/vind-cluster-setup/setup-cluster.sh'

# Source the file
source ~/.bash_profile  # or ~/.zshrc
```

## Uninstallation

### Option 1: Keep Clusters (Full Cleanup)

```bash
# Delete all clusters first
./setup-cluster.sh cleanup-all

# Then remove the installation
rm -rf /path/to/vind-cluster-setup
```

### Option 2: Keep Installation (Remove Clusters Only)

```bash
# Delete all clusters
./setup-cluster.sh cleanup-all
```

### Option 3: Full Removal (Including Docker Images)

```bash
# Delete clusters with image cleanup
./scripts/cleanup-all.sh --remove-images

# Remove setup scripts
rm -rf /path/to/vind-cluster-setup

# Optional: Remove tools
brew uninstall kubernetes-cli vcluster  # macOS
sudo apt-get remove -y kubectl  # Linux (Docker can be kept for other uses)
```

### Option 4: Remove tools entirely

```bash
# macOS
brew uninstall docker kubernetes-cli vcluster
brew cask uninstall docker

# Ubuntu/Debian
sudo apt-get remove -y docker.io kubectl
sudo apt-get autoremove -y

# CentOS/RHEL
sudo yum remove -y docker kubectl
```

## Troubleshooting

### Docker Not Found

**Error**: `Docker is not installed` or `Docker daemon is not running`

**Solution**:
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker

# Verify
docker ps
```

### kubectl Not Found

**Error**: `kubectl: command not found`

**Solution**:
```bash
# macOS
brew install kubernetes-cli

# Linux
sudo apt-get install -y kubectl

# Verify
kubectl version --client
```

### vCluster Installation Failed

**Error**: `vcluster: command not found` after installation

**Solution**:
```bash
# Verify installation
which vcluster

# If not found, add to PATH
export PATH=$PATH:/usr/local/bin

# Then test
vcluster version
```

### Permission Denied

**Error**: `permission denied: ./setup-cluster.sh`

**Solution**:
```bash
# Make executable
chmod +x setup-cluster.sh scripts/*.sh

# Verify
ls -la setup-cluster.sh
# Should show: -rwxr-xr-x
```

### Script Won't Execute

**Error**: `Bad interpreter` or `^M: command not found`

**Cause**: Line ending issues (Windows CRLF vs Unix LF)

**Solution**:
```bash
# Convert line endings
dos2unix setup-cluster.sh

# Or using sed
sed -i 's/\r$//' setup-cluster.sh

# Make executable again
chmod +x setup-cluster.sh
```

### Insufficient Disk Space

**Error**: `No space left on device`

**Solution**:
```bash
# Free up Docker resources
docker system prune -a

# Check disk usage
df -h

# Remove old clusters
./setup-cluster.sh list
./setup-cluster.sh delete -c old-cluster
```

### Insufficient Memory

**Error**: Container/pod starts but crashes due to OOM

**Solution**:
1. Close other applications
2. Reduce cluster count
3. Use pause/resume for unused clusters:
   ```bash
   ./setup-cluster.sh pause -c cluster-name
   ```

### vCluster Version Mismatch

**Error**: vCluster version too old

**Solution**:
```bash
# Upgrade vCluster
brew upgrade vcluster  # macOS

# Linux - download latest
curl -s -L "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" -o vcluster
sudo install -c -m 0755 vcluster /usr/local/bin

# Verify
vcluster version
```

### Network Issues

**Problem**: Can't access LoadBalancer services

**Solution**:
```bash
# Check service status
./setup-cluster.sh connect -c my-cluster
kubectl get svc -A

# Use port-forward as workaround
kubectl port-forward -n sample-apps svc/service-name 8080:80
```

## Getting Help

If you're still having issues:

1. **Check the logs**:
   ```bash
   cat vind-setup.log
   ```

2. **Run in verbose mode**:
   ```bash
   ./setup-cluster.sh create -v
   ```

3. **Check system compatibility**:
   ```bash
   bash --version
   echo $OSTYPE
   ```

4. **File an issue** on GitHub with:
   - Error message
   - OS and version
   - Installation method used
   - Relevant log excerpts

---

For more information, see [README.md](README.md) and [TROUBLESHOOTING.md](TROUBLESHOOTING.md) (if available).
