# Contributing to vind Cluster Setup

We're excited that you're interested in contributing! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

Be respectful, inclusive, and professional. All contributors are expected to:
- Be welcoming to new contributors
- Focus on constructive feedback
- Respect diverse opinions and experiences

## Getting Started

### Prerequisites
- Bash 4.0+
- Git
- Docker
- kubectl
- vCluster CLI

### Setting Up Your Development Environment

1. **Fork the repository**:
   ```bash
   # On GitHub, click "Fork"
   ```

2. **Clone your fork**:
   ```bash
   git clone https://github.com/yourusername/vind-cluster-setup.git
   cd vind-cluster-setup
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/original/vind-cluster-setup.git
   ```

4. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-feature
   ```

## Contribution Process

### 1. Finding Issues to Work On

- Check our [GitHub Issues](https://github.com/yourusername/vind-cluster-setup/issues)
- Look for issues labeled:
  - `good-first-issue`: Great for newcomers
  - `help-wanted`: We need your input
  - `bug`: Something isn't working
  - `enhancement`: New features or improvements

### 2. Working on Your Contribution

#### Code Style Guide

- **Bash Scripts**:
  - Use 4-space indentation
  - Use meaningful variable names
  - Add comments for complex logic
  - Use shellcheck for linting:
    ```bash
    shellcheck setup-cluster.sh
    ```

- **Comments and Documentation**:
  - Use clear, concise English
  - Explain "why", not just "what"
  - Add TODO comments for future work

#### Example Bash Format

```bash
#!/bin/bash

# Clear description of what the function does
my_function() {
    local variable="$1"
    
    # Do something
    if [ -z "$variable" ]; then
        error "Variable is required"
        return 1
    fi
    
    return 0
}
```

### 3. Testing Your Changes

Before submitting, test thoroughly:

```bash
# Syntax check
bash -n setup-cluster.sh

# ShellCheck linting
shellcheck setup-cluster.sh

# Manual testing
chmod +x setup-cluster.sh
./setup-cluster.sh --help
./setup-cluster.sh setup
./setup-cluster.sh create -c test-cluster
./setup-cluster.sh list
./setup-cluster.sh delete -c test-cluster
```

### 4. Committing Your Changes

#### Commit Message Format

Use clear, descriptive commit messages:

```
[Type] Brief description (50 chars max)

Detailed explanation of changes (if needed)
- What was changed
- Why it was changed
- How it was tested

Fixes #123
```

**Types**:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code restructuring
- `test:` Test improvements
- `chore:` Maintenance tasks

**Examples**:
```
feat: add cluster pause/resume functionality

- Implements vcluster pause command wrapper
- Implements vcluster resume command wrapper
- Adds help documentation

Fixes #45

fix: correct kubectl context switching issue

Resolves a race condition where kubectl context wasn't
properly updated before deployment commands.

Tested with 10 cluster create/delete cycles.
```

### 5. Pushing and Creating Pull Request

```bash
# Push your branch
git push origin feature/my-feature

# Create PR on GitHub
# - Clear title and description
# - Reference related issues
# - Screenshot/logs if applicable
```

#### PR Description Template

```markdown
## Description
Brief description of changes

## Related Issues
Fixes #123

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Breaking change

## Testing
How did you test this?
- [ ] Setup tested on macOS
- [ ] Setup tested on Linux
- [ ] Cluster creation tested
- [ ] Deployment tested

## Checklist
- [ ] Code follows style guidelines
- [ ] README updated if needed
- [ ] CHANGELOG.md updated
- [ ] No breaking changes
```

## Reporting Issues

### Bug Reports

Include:
1. **Description**: What's the problem?
2. **Steps to Reproduce**: How do I see it?
3. **Expected Behavior**: What should happen?
4. **Actual Behavior**: What actually happens?
5. **Environment**:
   ```
   OS: macOS 13.0 / Ubuntu 22.04
   Bash version: 5.1
   Docker version: 20.10.21
   vCluster version: 0.31.0
   ```
6. **Logs**: Snippet from `vind-setup.log`

### Feature Requests

Include:
1. **Use Case**: Why do you need this?
2. **Expected Behavior**: How should it work?
3. **Example**: Show the command or workflow
4. **Alternatives**: What workarounds exist?

## Documentation

### Updating README.md

- Keep it current with new features
- Update examples if behavior changes
- Add new sections for major features
- Test all code examples

### Updating CHANGELOG.md

Add entries for your changes:
```markdown
### Added
- New feature description

### Fixed
- Bug fix description

### Changed
- Breaking change description
```

## Pull Request Review Process

1. **Automated Checks**:
   - Bash syntax validation
   - ShellCheck linting
   - Code review rules

2. **Human Review**:
   - Code quality and style
   - Functionality and correctness
   - Documentation completeness
   - Testing adequacy

3. **Feedback**:
   - Constructive comments from maintainers
   - Requests for changes or clarifications
   - Tips for improvement

4. **Approval and Merge**:
   - At least one approval required
   - All checks must pass
   - Branch auto-deleted after merge

## Development Tips

### Useful Commands for Testing

```bash
# Test script syntax
bash -n setup-cluster.sh

# Lint with ShellCheck
shellcheck setup-cluster.sh

# Run with verbose output
./setup-cluster.sh create -c test -v

# Check logs
tail -f vind-setup.log

# List all vClusters
vcluster list

# View cluster details
vcluster describe my-cluster

# Check cluster resources
kubectl get all -A
```

### Debugging

```bash
# Run script with debug mode
bash -x setup-cluster.sh command

# Add debug output in script
set -x  # Enable debugging
# ... code ...
set +x  # Disable debugging

# Check existing logs
tail -50 vind-setup.log
```

### Common Development Scenarios

#### Testing Cluster Creation

```bash
./setup-cluster.sh setup
./setup-cluster.sh create -c dev-test
./setup-cluster.sh list
./setup-cluster.sh connect -c dev-test
kubectl get nodes
./setup-cluster.sh delete -c dev-test
```

#### Testing Deployments

```bash
./setup-cluster.sh create -c deploy-test
./setup-cluster.sh deploy -c deploy-test -s -a
./setup-cluster.sh connect -c deploy-test
kubectl get all -n sample-apps
kubectl logs -n sample-apps -l app=sample-app-nodeport
```

## Release Process

Maintainers use this process for releases:

1. **Update version** in `setup-cluster.sh`
2. **Update CHANGELOG.md** with changes
3. **Create git tag**:
   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0"
   ```
4. **Push changes and tags**:
   ```bash
   git push origin main
   git push origin --tags
   ```
5. **Create GitHub Release** with:
   - Version and date
   - Change summary
   - Download links

## Getting Help

- **Issues Page**: Ask for help on GitHub Issues
- **Discussions**: Share ideas and get feedback
- **Email**: Contact maintainers directly
- **Documentation**: Check README and docs/

## Resources

- [Bash Best Practices](https://mywiki.wooledge.org/BashGuide)
- [ShellCheck](https://www.shellcheck.net/)
- [Git Workflow](https://git-scm.com/book/en/v2)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [vCluster Docs](https://www.vcluster.com/docs/)

## Recognition

Contributors will be:
- Added to the CONTRIBUTORS file
- Mentioned in release notes
- Credited in README

## Questions?

- Check existing issues and PRs
- Review documentation
- Ask maintainers if stuck
- Don't hesitate to contribute! We welcome all skill levels

Thank you for contributing! 🚀
