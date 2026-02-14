#!/usr/bin/env bash

# ll-todo-app Environment Setup Script
# Initializes and verifies the project environment

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output functions
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

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="ll-todo-app"
REQUIRED_COMMANDS=("git" "bash" "sh")
OPTIONAL_COMMANDS=("ssh-keyscan" "gpg")

print_info "=========================================="
print_info "  $PROJECT_NAME Environment Setup"
print_info "=========================================="
echo ""

# Check if running in correct directory
if [ ! -f "$SCRIPT_DIR/.gitignore" ]; then
    print_error "Script must be run from project root directory"
    exit 1
fi

print_info "Project root: $SCRIPT_DIR"
echo ""

# Verify required commands
print_info "Checking required commands..."
MISSING_REQUIRED=0
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        print_success "✓ $cmd"
    else
        print_error "✗ $cmd (REQUIRED)"
        MISSING_REQUIRED=1
    fi
done

if [ $MISSING_REQUIRED -eq 1 ]; then
    print_error "Missing required commands. Please install them and try again."
    exit 1
fi

echo ""

# Check optional commands
print_info "Checking optional commands..."
for cmd in "${OPTIONAL_COMMANDS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        print_success "✓ $cmd"
    else
        print_warning "⚠ $cmd (optional)"
    fi
done

echo ""

# Verify git repository
print_info "Verifying git repository..."
if [ -d "$SCRIPT_DIR/.git" ]; then
    CURRENT_BRANCH=$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    REMOTE_URL=$(git -C "$SCRIPT_DIR" config --get remote.origin.url 2>/dev/null || echo "not configured")
    print_success "git repository initialized"
    print_info "  Branch: $CURRENT_BRANCH"
    print_info "  Remote: $REMOTE_URL"
else
    print_error "Not a git repository"
    exit 1
fi

echo ""

# Check file permissions
print_info "Checking file permissions..."
SCRIPTS_TO_CHECK=("copy-repo-branches.sh")
SCRIPTS_OK=0
for script in "${SCRIPTS_TO_CHECK[@]}"; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        if [ -x "$SCRIPT_DIR/$script" ]; then
            print_success "✓ $script (executable)"
        else
            print_warning "⚠ $script (not executable, fixing...)"
            chmod +x "$SCRIPT_DIR/$script"
            print_success "✓ $script (executable)"
        fi
    fi
done

echo ""

# Check test scripts
print_info "Checking test scripts..."
if [ -f "$SCRIPT_DIR/tests/test_copy_branches_local.sh" ]; then
    if [ ! -x "$SCRIPT_DIR/tests/test_copy_branches_local.sh" ]; then
        chmod +x "$SCRIPT_DIR/tests/test_copy_branches_local.sh"
    fi
    print_success "✓ test_copy_branches_local.sh"
else
    print_warning "⚠ tests/test_copy_branches_local.sh not found"
fi

echo ""

# Verify secrets environment
print_info "Checking secrets configuration..."
if [ -n "$SSH_KEY_CONTENT" ]; then
    print_success "✓ SSH_KEY_CONTENT is set (from environment)"
elif [ -f "$HOME/.ssh/id_ed25519" ]; then
    print_success "✓ SSH key found at ~/.ssh/id_ed25519"
    print_info "  To use in scripts: export SSH_KEY_CONTENT=\"\$(cat ~/.ssh/id_ed25519)\""
elif [ -f "$HOME/.ssh/id_rsa" ]; then
    print_success "✓ SSH key found at ~/.ssh/id_rsa"
    print_info "  To use in scripts: export SSH_KEY_CONTENT=\"\$(cat ~/.ssh/id_rsa)\""
else
    print_warning "⚠ No SSH key found. See SECRETS.md for setup"
fi

if [ -n "$GITHUB_TOKEN" ]; then
    print_success "✓ GITHUB_TOKEN is set (from environment)"
elif [ -n "$GH_TOKEN" ]; then
    print_success "✓ GH_TOKEN is set (alternate GitHub CLI token)"
else
    print_info "  GITHUB_TOKEN not set (optional, see SECRETS.md)"
fi

echo ""

# Check GitHub Actions workflow
print_info "Checking GitHub Actions configuration..."
if [ -f "$SCRIPT_DIR/.github/workflows/copy-branches.yml" ]; then
    print_success "✓ Workflow file exists: .github/workflows/copy-branches.yml"
    print_info "  Trigger: workflow_dispatch (manual trigger)"
    print_info "  Required secrets: SSH_KEY_CONTENT or GITHUB_TOKEN"
else
    print_warning "⚠ Workflow file not found"
fi

echo ""

# Check documentation
print_info "Checking documentation..."
DOCS=("README.md" "SECRETS.md" "SECRETS-QUICKSTART.md" "SECRETS-REFERENCE.md")
for doc in "${DOCS[@]}"; do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        print_success "✓ $doc"
    else
        print_warning "⚠ $doc (missing)"
    fi
done

echo ""

# Git hooks setup (optional)
print_info "Setting up git hooks..."
if [ ! -d "$SCRIPT_DIR/.git/hooks" ]; then
    mkdir -p "$SCRIPT_DIR/.git/hooks"
fi

# Create pre-commit hook to prevent secrets
cat > "$SCRIPT_DIR/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash
# Prevent committing potential secrets

PATTERNS=(
    "ghp_[A-Za-z0-9_]*"           # GitHub PAT
    "GITHUB_TOKEN"                 # Token reference
    "SSH_KEY_CONTENT"              # SSH key reference
    "-----BEGIN.*PRIVATE"          # Private key markers
    "password[ ]*="                # Password assignments
    "secret[ ]*="                  # Secret assignments
)

for pattern in "${PATTERNS[@]}"; do
    if git diff --cached | grep -qi "$pattern"; then
        echo "⚠️  Pre-commit hook: Potential secret detected in staged changes"
        echo "    Pattern: $pattern"
        echo "    Use 'git diff --cached' to review changes"
        echo "    If this is intentional, use 'git commit --no-verify'"
        exit 1
    fi
done

exit 0
EOF

chmod +x "$SCRIPT_DIR/.git/hooks/pre-commit"
print_success "✓ Pre-commit hook installed"

echo ""

# Summary
print_info "=========================================="
print_success "Environment setup complete!"
print_info "=========================================="
echo ""

echo "Next steps:"
echo ""
echo "1. Configure GitHub Secrets (if using GitHub Actions):"
echo "   - Settings > Secrets and variables > Actions"
echo "   - Add SSH_KEY_CONTENT or GITHUB_TOKEN"
echo "   - See SECRETS-QUICKSTART.md for details"
echo ""
echo "2. Run scripts locally:"
echo "   - export SSH_KEY_CONTENT=\"\$(cat ~/.ssh/id_ed25519)\""
echo "   - ./copy-repo-branches.sh git@github.com:youruser/yourrepo.git"
echo ""
echo "3. Test locally without network:"
echo "   - tests/test_copy_branches_local.sh"
echo ""
echo "4. View documentation:"
echo "   - README.md - Project overview"
echo "   - SECRETS-QUICKSTART.md - 5-minute setup"
echo "   - SECRETS.md - Detailed guide"
echo "   - SECRETS-REFERENCE.md - Technical reference"
echo ""

print_success "All checks passed!"
