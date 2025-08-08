# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
[0;32m[INFO][0m Generating changelog for version 0.1.1 since vespa-0.1.1

## [vespa-helm-0.1.1](https://github.com/walmartlabs/vespa-helm/releases/tag/v0.1.1) (2025-08-08)

### Added
- Adding support for generating changelog
- Adding workflows for changelog and release with conventional commit (#7)

### Fixed
- Fixing release flow
- Adding workflows for changelog and release with conventional commit (#7)

## [vespa-helm-0.1.1](https://github.com/walmartlabs/vespa-helm/releases/tag/v0.1.1) (2025-07-30)

### Added
- GitHub Pages Helm chart repository setup
- Automated chart publishing via GitHub Actions
- Comprehensive Istio installation documentation for multi-cloud environments
- cert-manager prerequisite documentation and installation instructions
- kind cluster support with NodePort configuration for local development
- Table of contents and improved README structure
- Automated changelog generation using conventional commits

### Changed
- Updated README with clear prerequisites section and better organization
- Simplified Istio installation instructions for multiple cloud providers (AWS, Azure, GCP)
- Enhanced troubleshooting documentation for GitHub Pages setup
- Improved documentation formatting and removed duplicate content

### Fixed
- GitHub Actions workflow for chart-releaser with proper gh-pages branch handling
- YAML formatting issues in documentation code blocks

## [vespa-helm-0.1.0](https://github.com/walmartlabs/vespa-helm/releases/tag/v0.1.0) (2025-07-20)

### Added
- Initial release of Vespa Helm chart
- Support for Vespa deployment on Kubernetes
- Istio service mesh integration
- Configurable schemas and query profiles
- Memory-backed storage options
- Comprehensive Helm chart templates for all Vespa components

