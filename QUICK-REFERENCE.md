# Quick Reference Guide

## Common Commands

### Setup & Installation

```bash
# One-time setup
./setup-cluster.sh setup

# Verbose setup (for debugging)
./setup-cluster.sh setup -v
```

### Cluster Management

```bash
# Create single cluster
./setup-cluster.sh create -c my-cluster

# Create multiple clusters
./setup-cluster.sh create -n 3 -c prod

# List all clusters
./setup-cluster.sh list

# Connect to cluster
./setup-cluster.sh connect -c my-cluster

# Pause cluster (save resources)
./setup-cluster.sh pause -c my-cluster

# Resume cluster
./setup-cluster.sh resume -c my-cluster

# Delete cluster
./setup-cluster.sh delete -c my-cluster
```

### Application Deployment

```bash
# Interactive deployment (prompts for each)
./setup-cluster.sh deploy -c my-cluster

# Deploy everything (NodePort + LoadBalancer + ArgoCD)
./setup-cluster.sh deploy -c my-cluster -s -a

# Deploy specific services
./setup-cluster.sh deploy -c my-cluster -d              # NodePort only
./setup-cluster.sh deploy -c my-cluster -l              # LoadBalancer only
./setup-cluster.sh deploy -c my-cluster -a              # ArgoCD only
```

### Quick Setup Scripts

```bash
# Fast setup with all features
./scripts/quick-setup.sh my-cluster

# Create multiple clusters at once
./scripts/batch-create.sh 5 my-cluster

# Clean up everything
./scripts/cleanup-all.sh
./scripts/cleanup-all.sh --remove-images  # Also remove Docker images
```

## Important Ports

| Service | Service Type | Port | Access |
|---------|-------------|------|--------|
| Sample App 1 | NodePort | 30080 | http://localhost:30080 |
| Sample App 2 | LoadBalancer | 80 | Dynamic (check with kubectl) |
| ArgoCD | LoadBalancer | 80 | Dynamic (check with kubectl) |

## Kubernetes Operations

Once connected to a cluster:

```bash
# Get cluster info
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# View services
kubectl get svc -A
kubectl get svc -n sample-apps

# View deployments
kubectl get deployments -n sample-apps
kubectl describe deployment sample-app-nodeport -n sample-apps

# View pods
kubectl get pods -n sample-apps
kubectl logs -f pod-name -n sample-apps

# Access services
kubectl port-forward -n sample-apps svc/my-service 8080:80

# Watch resources
kubectl get all -n sample-apps --watch
```

## ArgoCD Access

After deployment:

```bash
# Get LoadBalancer IP/hostname
kubectl get svc -n argocd argocd-server

# Get default credentials
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Login
# Username: admin
# Password: (from command above)
# URL: http://<LoadBalancer-IP>
```

## Troubleshooting Shortcuts

```bash
# Check logs
cat vind-setup.log

# Verify installation
./setup-cluster.sh --version

# Test Docker
docker ps
docker system prune

# Test kubectl
kubectl config current-context
kubectl config get-contexts

# Test vCluster
vcluster list
vcluster describe my-cluster

# Debug specific cluster
vcluster connect my-cluster --update-current
kubectl get all -A
```

## Environment Variables (Optional)

```bash
# Set custom log location
export VIND_LOG_FILE="/custom/path/vind-setup.log"

# Non-interactive mode (use with caution)
export VIND_NON_INTERACTIVE=true
```

## Resource Cleanup

```bash
# Free disk space
docker system prune -a --volumes

# Remove all clusters and images
./scripts/cleanup-all.sh --remove-images

# Remove specific cluster
./setup-cluster.sh delete -c cluster-name
```

## Performance Tips

```bash
# Pause unused clusters to save RAM
./setup-cluster.sh pause -c dev-cluster

# Check resource usage
docker stats

# Monitor cluster
./setup-cluster.sh connect -c my-cluster
kubectl top nodes
kubectl top pods -A
```

## File Locations

```
vind-cluster-setup/
├── setup-cluster.sh          # Main script
├── README.md                 # Full documentation
├── INSTALL.md               # Installation guide
├── CHANGELOG.md             # Version history
├── LICENSE                  # Apache 2.0 License
├── CONTRIBUTING.md          # Contribution guide
├── Quick-Reference.md       # This file
├── vind-setup.log          # Generated log file
├── scripts/
│   ├── quick-setup.sh       # Fast setup
│   ├── batch-create.sh      # Bulk creation
│   └── cleanup-all.sh       # Full cleanup
└── manifests/
    ├── sample-app-nodeport.yaml
    ├── sample-app-loadbalancer.yaml
    └── argocd-application-example.yaml
```

## One-Liners

```bash
# Full setup: dependencies + cluster creation + apps + argocd
./setup-cluster.sh setup && ./setup-cluster.sh create -c prod && ./setup-cluster.sh deploy -c prod -s -a

# Create and immediately connect
./setup-cluster.sh create -c my-app && ./setup-cluster.sh connect -c my-app

# List and describe cluster
./setup-cluster.sh list && vcluster describe my-cluster

# Delete all clusters
vcluster list | grep -oP 'NAME\s+\|\s*\K\S+' | tail -n +2 | xargs -I {} ./setup-cluster.sh delete -c {}
```

## Getting Help

```bash
# Show full help
./setup-cluster.sh help

# Show version
./setup-cluster.sh version

# Show help for specific command
./setup-cluster.sh create --help

# View logs
tail -50 vind-setup.log
tail -f vind-setup.log  # Follow logs

# Check script syntax
bash -n setup-cluster.sh

# Run with debugging
bash -x setup-cluster.sh command
```

## Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|----------|
| Docker not running | `open -a Docker` (macOS) or `sudo systemctl start docker` (Linux) |
| kubectl not found | `brew install kubernetes-cli` (macOS) or `sudo apt-get install -y kubectl` |
| vCluster not found | Run `./setup-cluster.sh setup` |
| Permission denied | `chmod +x setup-cluster.sh scripts/*.sh` |
| No space left | `docker system prune -a` |
| Out of memory | Close other apps or pause unused clusters |
| LoadBalancer pending | Normal in Docker - use `kubectl port-forward` |

---

**Need more help?** Check [README.md](README.md) or [INSTALL.md](INSTALL.md)
