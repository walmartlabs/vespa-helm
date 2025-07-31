#!/bin/bash

# Generate changelog for Helm chart releases
# This script generates a changelog based on git commits since the last release

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the latest chart version
get_chart_version() {
    local chart_path="charts/vespa/Chart.yaml"
    if [[ -f "$chart_path" ]]; then
        grep "^version:" "$chart_path" | cut -d' ' -f2 | tr -d '"'
    else
        print_error "Chart.yaml not found at $chart_path"
        exit 1
    fi
}

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Generate changelog entry
generate_changelog_entry() {
    local version="$1"
    local since_tag="$2"
    local date=$(date +%Y-%m-%d)
    
    print_status "Generating changelog for version $version since $since_tag"
    
    # Get commits since last tag or since beginning if no tag
    local git_range=""
    if [[ -n "$since_tag" ]]; then
        git_range="${since_tag}..HEAD"
    else
        git_range="HEAD"
    fi
    
    # Generate the changelog entry
    cat << EOF

## [vespa-helm-$version](https://github.com/walmartlabs/vespa-helm/releases/tag/v$version) ($date)

EOF

    # Categorize commits
    local features=$(git log --oneline --grep="feat\|feature\|add" --grep="^Add" --grep="^Feature" $git_range 2>/dev/null | sed 's/^[a-f0-9]* /- /' || true)
    local fixes=$(git log --oneline --grep="fix\|bug" --grep="^Fix" --grep="^Bug" $git_range 2>/dev/null | sed 's/^[a-f0-9]* /- /' || true)
    local docs=$(git log --oneline --grep="doc\|readme" --grep="^Doc" --grep="^Update.*README" $git_range 2>/dev/null | sed 's/^[a-f0-9]* /- /' || true)
    local chores=$(git log --oneline --grep="chore\|refactor\|style" --grep="^Chore" --grep="^Refactor" $git_range 2>/dev/null | sed 's/^[a-f0-9]* /- /' || true)
    
    # Output categorized changes
    if [[ -n "$features" ]]; then
        echo "### Added"
        echo "$features"
        echo
    fi
    
    if [[ -n "$fixes" ]]; then
        echo "### Fixed"
        echo "$fixes"
        echo
    fi
    
    if [[ -n "$docs" ]]; then
        echo "### Documentation"
        echo "$docs"
        echo
    fi
    
    if [[ -n "$chores" ]]; then
        echo "### Changed"
        echo "$chores"
        echo
    fi
    
    # If no categorized commits found, list all commits
    if [[ -z "$features" && -z "$fixes" && -z "$docs" && -z "$chores" ]]; then
        echo "### Changes"
        git log --oneline $git_range 2>/dev/null | sed 's/^[a-f0-9]* /- /' || echo "- Initial release"
        echo
    fi
}

# Update CHANGELOG.md
update_changelog() {
    local version="$1"
    local temp_file=$(mktemp)
    local changelog_file="CHANGELOG.md"
    
    # Check if CHANGELOG.md exists
    if [[ ! -f "$changelog_file" ]]; then
        print_status "Creating new CHANGELOG.md"
        echo "# Changelog" > "$changelog_file"
        echo >> "$changelog_file"
        echo "All notable changes to this project will be documented in this file." >> "$changelog_file"
        echo >> "$changelog_file"
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)," >> "$changelog_file"
        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)." >> "$changelog_file"
    fi
    
    # Get the latest tag
    local latest_tag=$(get_latest_tag)
    
    # Generate new changelog entry
    local new_entry=$(generate_changelog_entry "$version" "$latest_tag")
    
    # Read existing changelog and insert new entry
    if head -n 1 "$changelog_file" | grep -q "# Changelog"; then
        # Insert after the header
        head -n 6 "$changelog_file" > "$temp_file"
        echo "$new_entry" >> "$temp_file"
        tail -n +7 "$changelog_file" >> "$temp_file"
    else
        # If no proper header, prepend to existing file
        echo "$new_entry" > "$temp_file"
        cat "$changelog_file" >> "$temp_file"
    fi
    
    # Replace the original file
    mv "$temp_file" "$changelog_file"
    
    print_status "Updated $changelog_file with version $version"
}

# Main function
main() {
    print_status "Starting changelog generation..."
    
    # Ensure we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Get current chart version
    local chart_version=$(get_chart_version)
    print_status "Current chart version: $chart_version"
    
    # Update changelog
    update_changelog "$chart_version"
    
    print_status "Changelog generation completed!"
    print_warning "Please review CHANGELOG.md and commit the changes."
}

# Run main function
main "$@"
