#!/bin/bash

set -e 

DOWNLOAD_DIR="/tmp/github-actions-airgap-full-repos"
ARCHIVE_NAME="github-actions-airgap-full-repos.tar.gz"

# Remove any previous downloads and create a clean working directory
rm -rf "$DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Function to clone a full repository with all history and tags
clone_action() {
    local repo_url="$1"
    local version_tag="$2"
    local dir_name="$3"

    git clone "$repo_url" "$dir_name"
    cd "$dir_name"
    git checkout "tags/$version_tag" -b "airgap-main"
    cd ..
}

# Core actions
clone_action "https://github.com/actions/checkout.git" "v4" "checkout"
clone_action "https://github.com/actions/upload-artifact.git" "v4" "upload-artifact"
clone_action "https://github.com/actions/download-artifact.git" "v4" "download-artifact"
clone_action "https://github.com/actions/cache.git" "v4" "cache"

# Setup actions for programming languages
clone_action "https://github.com/actions/setup-node.git" "v4" "setup-node"
clone_action "https://github.com/actions/setup-python.git" "v5" "setup-python"
clone_action "https://github.com/actions/setup-go.git" "v5" "setup-go"
clone_action "https://github.com/actions/setup-java.git" "v4" "setup-java"
clone_action "https://github.com/actions/setup-dotnet.git" "v4" "setup-dotnet"

# Docker-related actions
clone_action "https://github.com/docker/setup-buildx-action.git" "v3" "docker-setup-buildx-action"
clone_action "https://github.com/docker/build-push-action.git" "v6" "docker-build-push-action"
clone_action "https://github.com/docker/login-action.git" "v3" "docker-login-action"

# Security, release, and utility actions
clone_action "https://github.com/github/codeql-action.git" "v3" "codeql-action"
clone_action "https://github.com/actions/first-interaction.git" "v1.3.0" "first-interaction"
clone_action "https://github.com/ncipollo/release-action.git" "v1.13.0" "release-action"
clone_action "https://github.com/softprops/action-gh-release.git" "v2" "action-gh-release"
clone_action "https://github.com/actions/github-script.git" "v7" "github-script"
clone_action "https://github.com/actions/configure-pages.git" "v5" "configure-pages"
clone_action "https://github.com/actions/deploy-pages.git" "v4" "deploy-pages"
clone_action "https://github.com/calibreapp/image-actions.git" "main" "image-actions"
clone_action "https://github.com/actions/labeler.git" "v5" "labeler"
clone_action "https://github.com/actions/stale.git" "v9" "stale"

# Create compressed archive with all repositories
cd /tmp
tar -czf "$ARCHIVE_NAME" "$(basename "$DOWNLOAD_DIR")"

TOTAL_SIZE=$(du -sh "$ARCHIVE_NAME" | cut -f1)
SUCCESSFUL_ACTIONS=$(find "$DOWNLOAD_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)

