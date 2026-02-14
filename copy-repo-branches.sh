#!/bin/bash

# Script to copy all branches from https://github.com/hhimanshu/the-todo-app to a new repository
# Usage: ./copy-repo-branches.sh <new-repository-url>

set -e  # Exit on any error

# Source repository (can be overridden for testing)
SOURCE_REPO_URL="${SOURCE_REPO_URL:-https://github.com/hhimanshu/the-todo-app}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if new repository URL is provided (also allow env var)
if [ $# -ge 1 ]; then
    NEW_REPO_URL="$1"
fi

if [ -z "$NEW_REPO_URL" ]; then
    NEW_REPO_URL="${NEW_REPO_URL:-}"
fi

if [ -z "$NEW_REPO_URL" ]; then
    print_error "No repository URL provided!"
    echo "Usage: $0 <new-repository-url> or set NEW_REPO_URL env var"
    echo "Example: $0 git@github.com:username/new-repo.git"
    exit 1
fi

# Optional: Accept SSH private key contents via env var `SSH_KEY_CONTENT` (kept secret)
SSH_KEY_FILE=""
cleanup_ssh_key() {
    if [ -n "$SSH_KEY_FILE" ] && [ -f "$SSH_KEY_FILE" ]; then
        shred -u "$SSH_KEY_FILE" 2>/dev/null || rm -f "$SSH_KEY_FILE"
    fi
}
trap cleanup_ssh_key EXIT

if [ -n "$SSH_KEY_CONTENT" ]; then
    SSH_KEY_FILE=$(mktemp -u "$TMPDIR/sshkey.XXXXXX" 2>/dev/null || mktemp -u "/tmp/sshkey.XXXXXX")
    # Write key securely
    umask 177
    printf "%s" "$SSH_KEY_CONTENT" > "$SSH_KEY_FILE"
    chmod 600 "$SSH_KEY_FILE"
    export GIT_SSH_COMMAND="ssh -i $SSH_KEY_FILE -o UserKnownHostsFile=$HOME/.ssh/known_hosts -o StrictHostKeyChecking=yes"
    print_info "Using SSH key from SSH_KEY_CONTENT (kept in temporary file)"
fi

# Optional: Accept GITHUB_TOKEN to use HTTPS auth instead of SSH (kept secret)
if [ -n "$GITHUB_TOKEN" ]; then
    # Convert an ssh-style URL (git@github.com:owner/repo.git) to https with token
    if [[ "$NEW_REPO_URL" =~ ^git@github.com:(.+) ]]; then
        OWNER_REPO="${BASH_REMATCH[1]}"
        NEW_REPO_URL="https://$GITHUB_TOKEN@github.com/$OWNER_REPO"
        print_info "Using HTTPS URL with token for authentication"
    fi
fi

print_info "Starting repository branch copy process..."
print_info "Source repository: $SOURCE_REPO_URL"
print_info "Target repository: $NEW_REPO_URL"

# Create a temporary directory for the clone
TEMP_DIR=$(mktemp -d)
REPO_NAME="temp-todo-app-clone"
CLONE_PATH="$TEMP_DIR/$REPO_NAME"

print_info "Using temporary directory: $TEMP_DIR"

# Clone the source repository
print_info "Cloning source repository..."
if ! git clone "$SOURCE_REPO_URL" "$CLONE_PATH"; then
    print_error "Failed to clone source repository!"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Change to the cloned repository directory
cd "$CLONE_PATH"
print_success "Successfully cloned source repository"

# Step 1: Fetch all remote branches
print_info "Fetching all remote branches..."
git fetch --all

# Step 2: Get list of all remote branches (excluding HEAD pointer)
print_info "Discovering remote branches..."
REMOTE_BRANCHES=$(git branch -r | grep -v '\->' | sed 's/^[[:space:]]*origin\///' | sed 's/[[:space:]]*$//')

if [ -z "$REMOTE_BRANCHES" ]; then
    print_warning "No remote branches found!"
    REMOTE_BRANCHES="main"
fi

echo "Found branches:"
for branch in $REMOTE_BRANCHES; do
    echo "  - $branch"
done

# Step 3: Create local tracking branches for all remote branches
print_info "Creating local tracking branches..."
for branch in $REMOTE_BRANCHES; do
    if git show-ref --verify --quiet refs/heads/$branch; then
        print_warning "Branch '$branch' already exists locally"
    else
        if git checkout -b "$branch" "origin/$branch" 2>/dev/null; then
            print_success "Created local branch: $branch"
        else
            print_error "Failed to create branch: $branch"
        fi
    fi
done

# Step 4: Switch to main branch (default branch)
print_info "Switching to main branch..."
git checkout main

# Step 5: Add new remote (keep old one as backup)
print_info "Setting up new remote..."
if git remote get-url newrepo > /dev/null 2>&1; then
    print_warning "Remote 'newrepo' already exists, updating URL..."
    git remote set-url newrepo "$NEW_REPO_URL"
else
    git remote add newrepo "$NEW_REPO_URL"
    print_success "Added new remote 'newrepo'"
fi

# Step 6: Push all branches to new repository
print_info "Pushing all branches to new repository..."

# Push all local branches
LOCAL_BRANCHES=$(git branch | sed 's/^[* ] //')
PUSH_SUCCESS=0
PUSH_FAILED=0

for branch in $LOCAL_BRANCHES; do
    print_info "Pushing branch: $branch"
    if git push newrepo "$branch"; then
        print_success "✓ Pushed $branch"
        ((PUSH_SUCCESS++))
    else
        print_error "✗ Failed to push $branch"
        ((PUSH_FAILED++))
    fi
done

# Step 7: Push tags if any exist
TAGS=$(git tag)
if [ -n "$TAGS" ]; then
    print_info "Pushing tags..."
    if git push newrepo --tags; then
        print_success "✓ Pushed all tags"
    else
        print_error "✗ Failed to push tags"
    fi
else
    print_info "No tags to push"
fi

# Step 8: Clean up temporary directory
print_info "Cleaning up temporary files..."
cd /
rm -rf "$TEMP_DIR"
print_success "Cleaned up temporary directory"

# Step 9: Summary
echo ""
print_info "=== SUMMARY ==="
echo "Source repository: $SOURCE_REPO_URL"
echo "Target repository: $NEW_REPO_URL"
echo "Branches pushed successfully: $PUSH_SUCCESS"
echo "Branches failed to push: $PUSH_FAILED"

if [ $PUSH_FAILED -eq 0 ]; then
    print_success "All branches copied successfully! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Clone your new repository: git clone $NEW_REPO_URL"
    echo "2. Verify all branches: git branch -a"
    echo "3. Check all branches were copied: git ls-remote $NEW_REPO_URL"
else
    print_warning "Some branches failed to push. Check the errors above."
fi
