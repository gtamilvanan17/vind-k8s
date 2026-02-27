# Project Structure & Overview

## 📁 Directory Layout

```
vind-cluster-setup/
│
├── 📄 setup-cluster.sh              ⭐ Main automation script (850+ lines)
│   └── Full cluster management with all features
│
├── 📁 scripts/                      🔧 Helper automation scripts
│   ├── quick-setup.sh              # One-command fast setup
│   ├── batch-create.sh             # Create multiple clusters
│   └── cleanup-all.sh              # Full cleanup and resource removal
│
├── 📁 manifests/                   🚀 Sample Kubernetes deployments
│   ├── sample-app-nodeport.yaml    # Nginx on port 30080
│   ├── sample-app-loadbalancer.yaml # Nginx with LoadBalancer
│   └── argocd-application-example.yaml # ArgoCD app template
│
├── 📖 README.md                     # Complete documentation (500+ lines)
│   ├── Features overview
│   ├── Usage guide with examples
│   ├── Troubleshooting section
│   └── Architecture diagrams
│
├── 📖 INSTALL.md                    # Installation guide (400+ lines)
│   ├── System requirements
│   ├── Multiple installation methods
│   └── Verification steps
│
├── 📖 QUICK-REFERENCE.md            # Quick command reference
│   ├── Common commands
│   ├── One-liners
│   └── Troubleshooting shortcuts
│
├── 📖 CONTRIBUTING.md               # Contribution guidelines
│   ├── Development setup
│   ├── Code style guide
│   └── Pull request process
│
├── 📖 CHANGELOG.md                  # Version history
│   ├── Release notes
│   └── Feature roadmap
│
├── 📄 LICENSE                       # Apache 2.0 License
│
└── 📄 .gitignore                    # Git ignore rules
```

## 📊 File Statistics

| File | Lines | Purpose |
|------|-------|---------|
| setup-cluster.sh | 850+ | Main automation script |
| README.md | 500+ | Complete documentation |
| INSTALL.md | 400+ | Installation guide |
| scripts/quick-setup.sh | 50+ | Fast setup helper |
| scripts/batch-create.sh | 60+ | Bulk cluster creation |
| scripts/cleanup-all.sh | 50+ | Resource cleanup |
| manifests/*.yaml | 150+ | Sample deployments |
| Documentation files | 300+ | Guides and references |
| **Total** | **~2,360+** | **Complete project** |

## 🎯 What Each Component Does

### Main Script: `setup-cluster.sh`

The heart of the project with these features:

#### 1. **Dependency Management**
```bash
# Automatically checks and installs
./setup-cluster.sh setup
```
- Docker (with daemon check)
- kubectl CLI
- vCluster tool
- Skips already installed tools
- Interactive confirmation for installations

#### 2. **Cluster Operations**
```bash
# Create clusters
./setup-cluster.sh create -c cluster-name -n 3

# List clusters
./setup-cluster.sh list

# Delete clusters
./setup-cluster.sh delete -c cluster-name

# Pause/Resume
./setup-cluster.sh pause -c cluster-name
./setup-cluster.sh resume -c cluster-name

# Connect
./setup-cluster.sh connect -c cluster-name
```

#### 3. **Application Deployment**
```bash
# Interactive mode
./setup-cluster.sh deploy -c cluster-name

# Automated - sample apps + ArgoCD
./setup-cluster.sh deploy -c cluster-name -s -a

# Individual deployments
./setup-cluster.sh deploy -c cluster-name -d  # NodePort only
./setup-cluster.sh deploy -c cluster-name -l  # LoadBalancer only
./setup-cluster.sh deploy -c cluster-name -a  # ArgoCD only
```

#### 4. **Built-in Help**
```bash
./setup-cluster.sh help      # Full help
./setup-cluster.sh version   # Version info
./setup-cluster.sh --help    # Command help
```

### Helper Scripts: `scripts/`

#### quick-setup.sh
```bash
./scripts/quick-setup.sh my-cluster [y/n]
```
- One-command rapid setup
- Creates cluster + deploys samples + installs ArgoCD

#### batch-create.sh
```bash
./scripts/batch-create.sh 5 prod-cluster
```
- Creates multiple clusters in sequence
- Perfect for multi-environment setup

#### cleanup-all.sh
```bash
./scripts/cleanup-all.sh [--remove-images]
```
- Deletes all vClusters
- Cleans up Docker resources
- Optional: Remove Docker images

### Sample Manifests: `manifests/`

#### sample-app-nodeport.yaml
- Nginx deployment (2 replicas)
- NodePort service on port 30080
- Resource limits (200m CPU, 256Mi RAM)
- Health checks configured

#### sample-app-loadbalancer.yaml
- Nginx deployment (2 replicas)
- LoadBalancer service
- Anti-affinity for pod distribution
- External traffic policy optimized

#### argocd-application-example.yaml
- Template for ArgoCD apps
- GitOps configuration example
- Ready to customize for your repos

## 📚 Documentation Overview

### README.md
**Purpose**: Complete project documentation
**Size**: 500+ lines
**Contains**:
- Project features and benefits
- Quick start guide
- Installation instructions
- Usage examples
- Command reference
- Troubleshooting guide
- Architecture diagrams
- Roadmap and future plans

### INSTALL.md
**Purpose**: Detailed installation instructions
**Size**: 400+ lines
**Contains**:
- System requirements
- macOS installation steps
- Linux installation steps (Ubuntu, CentOS, Debian)
- WSL 2 support notes
- Installation verification
- Post-installation setup
- Complete uninstallation guide
- Detailed troubleshooting

### QUICK-REFERENCE.md
**Purpose**: Fast lookup guide
**Size**: 200+ lines
**Contains**:
- Common commands
- Port reference guide
- Kubernetes operations
- ArgoCD access
- One-liners for automation
- File locations
- Quick troubleshooting

### CONTRIBUTING.md
**Purpose**: Developer guide
**Size**: 300+ lines
**Contains**:
- Code of conduct
- Development setup
- Code style guidelines
- Testing procedures
- Commit message format
- Pull request process
- Development tips

### CHANGELOG.md
**Purpose**: Version history and roadmap
**Size**: 200+ lines
**Contains**:
- Version v1.0.0 release notes
- Feature list by release
- Breaking changes
- Support timeline
- Roadmap for future versions

## 🚀 Quick Start Paths

### Path 1: Fast Setup (5 minutes)
```bash
git clone https://github.com/yourusername/vind-cluster-setup.git
cd vind-cluster-setup
./scripts/quick-setup.sh my-cluster y
```

### Path 2: Detailed Setup (15 minutes)
```bash
./setup-cluster.sh setup
./setup-cluster.sh create -c my-cluster
./setup-cluster.sh deploy -c my-cluster
./setup-cluster.sh deploy -c my-cluster -a  # Add ArgoCD later
```

### Path 3: Production Multi-Cluster (30 minutes)
```bash
./setup-cluster.sh setup
./scripts/batch-create.sh 3 prod
./setup-cluster.sh deploy -c prod-1 -s -a
./setup-cluster.sh deploy -c prod-2 -s -a
./setup-cluster.sh deploy -c prod-3 -s -a
```

## 📋 Command Cheat Sheet

```bash
# Show everything
./setup-cluster.sh help

# One-time setup
./setup-cluster.sh setup

# Create 1 cluster
./setup-cluster.sh create -c my-cluster

# Create 3 clusters
./setup-cluster.sh create -n 3 -c prod

# Deploy to cluster
./setup-cluster.sh deploy -c my-cluster -s -a

# Delete cluster
./setup-cluster.sh delete -c my-cluster

# List all clusters
./setup-cluster.sh list

# Connect to cluster
./setup-cluster.sh connect -c my-cluster

# Save resources
./setup-cluster.sh pause -c my-cluster
./setup-cluster.sh resume -c my-cluster

# Fast setup
./scripts/quick-setup.sh my-cluster

# Batch create
./scripts/batch-create.sh 5 my-cluster

# Clean everything
./scripts/cleanup-all.sh
```

## 🔐 Security Features

- ✅ Dependency verification before execution
- ✅ Docker daemon availability check
- ✅ Error handling and recovery
- ✅ Configuration isolation per cluster
- ✅ Resource limits on sample apps
- ✅ Network policies ready
- ✅ RBAC considerations in manifests

## 💾 Resource Usage

**Per Cluster** (Idle):
- CPU: ~100m
- Memory: ~256Mi
- Disk: ~2GB

**Per Cluster** (With Apps):
- CPU: ~300-400m
- Memory: ~512-768Mi
- Disk: ~2.5-3GB

## 🔗 Integration Points

- ✅ vCluster CLI: Cluster management
- ✅ Docker: Container runtime
- ✅ Kubernetes: Orchestration
- ✅ kubectl: CLI management
- ✅ Helm: ArgoCD installation
- ✅ Git: Version control ready

## 📱 Output Examples

### Help Output
```
╔════════════════════════════════════════════════════════════════════════════╗
║                    vind Cluster Setup Script v1.0.0                        ║
║        Automate vCluster creation and management with sample apps          ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE: ./setup-cluster.sh [COMMAND] [OPTIONS]
COMMANDS: setup, create, deploy, install-argocd, delete, list, pause, resume, connect
```

### Success Output
```
✓ Docker is installed (version: 20.10.21)
✓ Docker daemon is running
✓ kubectl is installed (version: 1.25)
✓ vCluster is installed (version: 0.31.0)
✓ Docker driver set as default
✓ Environment setup completed successfully!
```

### Cluster Creation Output
```
ℹ Creating cluster: my-cluster
✓ Cluster 'my-cluster' created successfully
✓ Cluster creation completed!
```

## 🎓 Learning Resources

- [vCluster Documentation](https://www.vcluster.com/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [ArgoCD Documentation](https://argoproj.github.io/cd/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

## 🤝 How to Get Help

1. **Check QUICK-REFERENCE.md** for common commands
2. **Check INSTALL.md** for setup issues
3. **Check README.md** for usage and features
4. **Run with `-v` flag**: `./setup-cluster.sh setup -v`
5. **Check logs**: `cat vind-setup.log`
6. **File an issue** on GitHub with error details

## 📈 Growth & Maintenance

This project is designed to:
- ✅ Be easily maintainable
- ✅ Support future enhancements
- ✅ Handle multiple environments
- ✅ Scale to many clusters
- ✅ Support team collaboration

---

**Ready to get started?** Run:
```bash
./setup-cluster.sh setup
```

**Want to understand more?** Read:
1. [README.md](README.md) - Overview and examples
2. [INSTALL.md](INSTALL.md) - Installation details
3. [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Command lookup

---

Generated: February 27, 2024 | Version: 1.0.0
