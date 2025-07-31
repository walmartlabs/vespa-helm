# Contributing to Vespa Helm Charts

Thank you for your interest in contributing to the Vespa Helm Charts project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Commit Convention](#commit-convention)
- [Changelog and Releases](#changelog-and-releases)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- [Helm 3.x](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) (for local testing)
- [Git](https://git-scm.com/)

### Local Development Setup

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/vespa-helm.git
   cd vespa-helm
   ```

2. **Set up a local Kubernetes cluster:**
   ```bash
   kind create cluster --name vespa-test
   ```

3. **Install dependencies:**
   ```bash
   # Install cert-manager
   helm repo add jetstack https://charts.jetstack.io
   helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --create-namespace \
     --set installCRDs=true
   
   # Install Istio (optional, for full testing)
   # See README.md for detailed Istio setup
   ```

## Development Workflow

### Making Changes

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes:**
   - Edit Helm templates in `charts/vespa/templates/`
   - Update `values.yaml` if needed
   - Update documentation

3. **Test your changes:**
   ```bash
   # Lint the charts
   make lint
   
   # Run unit tests
   make test
   
   # Render templates to check syntax
   make render
   
   # Test installation (optional)
   helm install test-vespa ./charts/vespa --dry-run
   ```

4. **Update chart version:**
   - For breaking changes: bump major version in `charts/vespa/Chart.yaml`
   - For new features: bump minor version
   - For bug fixes: bump patch version

## Commit Convention

This project uses conventional commits to automate changelog generation and releases. Please format your commits as follows:

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools

### Examples

```bash
# Good commit messages
feat(configserver): add support for custom annotations
fix(querycontainer): resolve port conflict in service template
docs: update Istio installation instructions
chore: update dependencies to latest versions

# Bad commit messages
update stuff
fix bug
added feature
```

### Breaking Changes

If your change introduces breaking changes, add `BREAKING CHANGE:` to the footer:

```
feat(values): restructure istio configuration

BREAKING CHANGE: istio.enabled is now istio.configserver.enabled
```

## Changelog and Releases

### Automated Changelog

This project uses automated changelog generation based on conventional commits:

1. **Automatic Generation**: When you push to main, the changelog is automatically updated
2. **Manual Generation**: You can run the script manually:
   ```bash
   ./scripts/generate-changelog.sh
   ```
3. **Manual Workflow**: Use GitHub Actions "Manual Changelog Update" workflow for version bumps and changelog updates

**Note**: For documentation-only changes, the changelog will still be updated to track all contributions, even if no chart version bump is required.

### Release Process

There are multiple ways to handle releases:

#### Option 1: Automatic (Recommended for chart changes)
1. **Version Bump**: Update the version in `charts/vespa/Chart.yaml`
2. **Push to Main**: Push changes to the main branch
3. **Automatic Process**: 
   - Changelog is updated automatically
   - Chart release workflow triggers on chart changes
   - GitHub release is created with packaged chart

#### Option 2: Manual Workflow (Good for any changes)
1. **Use GitHub Actions**: Go to Actions → "Manual Changelog Update"
2. **Choose update type**: 
   - `patch` - Bug fixes, documentation (0.1.0 → 0.1.1)
   - `minor` - New features (0.1.0 → 0.2.0) 
   - `major` - Breaking changes (0.1.0 → 1.0.0)
   - `no-version-bump` - Just update changelog without version change
3. **Automatic Process**: Chart version is bumped and changelog is updated

#### Option 3: Documentation/Infrastructure Only
1. **Push to Main**: Push changes without version bump
2. **Automatic Changelog**: Only the changelog is updated
3. **No Release**: No new Helm chart release is created

### Release Types

Version bumps follow semantic versioning:
- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Patch** (1.0.0 → 1.0.1): Bug fixes, backward compatible

## Testing

### Local Testing

1. **Lint charts:**
   ```bash
   make lint
   ```

2. **Run unit tests:**
   ```bash
   make test
   ```

3. **Test installation:**
   ```bash
   # Dry run
   helm install test-vespa ./charts/vespa --dry-run
   
   # Actual installation (requires cluster setup)
   helm install test-vespa ./charts/vespa
   ```

### Continuous Integration

All pull requests are automatically tested with:
- Helm chart linting
- Unit test execution
- Template rendering validation

## Pull Request Process

1. **Create a descriptive PR title** using conventional commit format:
   ```
   feat(configserver): add custom resource limits support
   ```

2. **Fill out the PR template** with:
   - Description of changes
   - Type of change
   - Testing performed
   - Release notes

3. **Ensure all checks pass:**
   - CI pipeline succeeds
   - Code review approval
   - No merge conflicts

4. **Update documentation** if needed:
   - README.md for user-facing changes
   - Chart README for configuration changes
   - Comments in templates for complex logic

### PR Labels

Labels are automatically applied based on:
- Branch names (`feature/`, `fix/`, `docs/`)
- Commit messages (conventional commit types)
- File changes (documentation, charts, etc.)

## Documentation

### Chart Documentation

- Keep `charts/vespa/README.md` up to date
- Document all values in `values.yaml` with comments
- Include examples for complex configurations

### Project Documentation

- Update main `README.md` for user-facing changes
- Add troubleshooting guides in `docs/` directory
- Keep installation instructions current

## Questions and Support

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and community support
- **Security**: For security issues, please follow responsible disclosure practices

Thank you for contributing to Vespa Helm Charts! 🚀
