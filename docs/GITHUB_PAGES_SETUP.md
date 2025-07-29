# Setting up GitHub Pages for Helm Chart Repository

This document explains how to enable GitHub Pages for the Vespa Helm chart repository.

## Prerequisites
- Repository admin access to `walmartlabs/vespa-helm`
- GitHub Pages feature available (should be available for public repos)

## Setup Steps

### 1. Push the Workflow Files
**IMPORTANT**: The GitHub Actions workflow files must be pushed to the repository first.

**Option A: If you have admin access (can bypass branch protection):**
```bash
# Add and commit the workflow files
git add .github/workflows/release.yml .github/cr.yaml docs/
git commit -m "Add GitHub Pages Helm chart repository setup"
git push origin main
```

**Option B: If you have branch protection rules (recommended approach):**
```bash
# Create a feature branch
git checkout -b setup-helm-repository

# Add and commit the workflow files
git add .github/workflows/release.yml .github/cr.yaml docs/
git commit -m "Add GitHub Pages Helm chart repository setup"

# Push the feature branch
git push origin setup-helm-repository

# Then create a Pull Request on GitHub:
# 1. Go to https://github.com/walmartlabs/vespa-helm
# 2. Click "Compare & pull request" (should appear after pushing)
# 3. Add title: "Setup GitHub Pages Helm chart repository"
# 4. Add description explaining the changes
# 5. Click "Create pull request"
# 6. Review and merge the PR
```

**Note**: If you're a repository admin and the commit was already pushed (you'll see "Bypassed rule violations"), you can proceed to the next step.

### 2. Enable GitHub Pages
1. Go to your repository on GitHub: https://github.com/walmartlabs/vespa-helm
2. Click on **Settings** tab
3. Scroll down to **Pages** section in the left sidebar
4. Under **Source**, select **GitHub Actions**
5. Click **Save**

### 3. Enable GitHub Actions
1. Go to the **Actions** tab in your repository
2. If Actions are disabled, click **Enable GitHub Actions**
3. Ensure **Read and write permissions** are enabled:
   - Go to **Settings** → **Actions** → **General**
   - Under **Workflow permissions**, select **Read and write permissions**
   - Check **Allow GitHub Actions to create and approve pull requests**
   - Click **Save**

### 4. Trigger the First Release
The workflow will automatically run when you push changes to charts, but you can also trigger it manually:

1. Go to **Actions** tab
2. Select **Release Charts** workflow (this should now be visible after pushing the workflow files)
3. Click **Run workflow**
4. Choose the `main` branch
5. Click **Run workflow**

### 5. Verify Setup
After the workflow completes:

1. Check that a `gh-pages` branch was created
2. Visit https://walmartlabs.github.io/vespa-helm to see the chart repository
3. Test the repository:
   ```bash
   helm repo add vespa https://walmartlabs.github.io/vespa-helm
   helm repo update
   helm search repo vespa
   ```

## How It Works

1. **Release Workflow**: When changes are pushed to the `charts/` directory, the workflow:
   - Packages the Helm chart
   - Creates a GitHub release with the chart package
   - Updates the Helm repository index
   - Deploys to GitHub Pages

2. **Chart Versioning**: Charts are released based on the version in `Chart.yaml`
   - Increment the version number for new releases
   - Follow semantic versioning (e.g., 0.1.0 → 0.1.1 → 0.2.0)

3. **Automatic Updates**: The repository index is automatically updated when:
   - Chart version changes
   - New charts are added
   - Chart metadata is modified

## Troubleshooting

### Workflow Fails
- Check that GitHub Actions have write permissions
- Ensure the Chart.yaml version is incremented for releases
- Verify no syntax errors in chart files

### Pages Not Accessible
- Confirm GitHub Pages is enabled and set to "GitHub Actions"
- Check that the workflow completed successfully
- Wait a few minutes for DNS propagation

### Charts Not Listed
- Ensure chart version was incremented
- Check that the workflow ran after chart changes
- Verify Chart.yaml syntax is correct

## Testing Changes

Before pushing to main, test your changes locally:

```bash
# Lint the chart
make lint

# Run tests
make test

# Render templates
make render

# Package the chart locally
helm package charts/vespa/
```
