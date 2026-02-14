# Environment Setup (bun.sh)

## Overview

`bun.sh` is an **environment setup and verification script** for the ll-todo-app project.

**Important:** This script is NOT related to the Bun JavaScript runtime. It's named `bun` as a reference to "build/setup script" in shell terminology.

## System Requirements

### Required
- **Bash** 4.0 or higher
- **Git** 2.20 or higher
- **Bun** 1.0 or higher (JavaScript runtime)
- **SSH client** (for GitHub authentication)

### Optional
- **GPG** (for commit signing)
- **ssh-keyscan** (for host key verification)

## What bun.sh Does

### 1. Verifies Commands
Checks that all required tools are available:
- ✓ Verifies `git`, `bash`, and `sh`
- ⚠️ Warns if optional tools are missing

### 2. Validates Repository
- Confirms `.git` directory exists
- Shows current branch
- Displays remote URL

### 3. Fixes Permissions
- Makes `copy-repo-branches.sh` executable
- Makes test scripts executable
- Ensures correct file permissions

### 4. Checks Secrets Configuration
- Verifies SSH keys exist (`~/.ssh/id_ed25519` or `~/.ssh/id_rsa`)
- Checks for `GITHUB_TOKEN` environment variable
- Provides setup guidance

### 5. Validates Workflow
- Confirms GitHub Actions workflow exists
- Shows workflow trigger information

### 6. Verifies Documentation
- Checks for README.md
- Checks for SECRETS.md
- Checks for SECRETS-QUICKSTART.md
- Checks for SECRETS-REFERENCE.md

### 7. Installs Git Hooks
- Creates `.git/hooks/pre-commit` hook
- Prevents accidental secret commits
- Detects patterns like API keys, tokens

## Running bun.sh

### First-time Setup
```bash
./bun.sh
```

### Output Example
```
[INFO] ==========================================
[INFO]   ll-todo-app Environment Setup
[INFO] ==========================================

[INFO] Project root: /path/to/ll-todo-app
[INFO] Checking required commands...
[SUCCESS] ✓ git
[SUCCESS] ✓ bash
[SUCCESS] ✓ sh
...
[SUCCESS] Environment setup complete!
```

## Troubleshooting

### "bun.sh: command not found"
Make it executable first:
```bash
chmod +x bun.sh
./bun.sh
```

### "git: command not found"
Install Git:
- macOS: `brew install git`
- Ubuntu/Debian: `apt-get install git`
- Fedora: `dnf install git`

### "Missing SSH key"
See [SECRETS.md](SECRETS.md) for SSH key setup

### "No GITHUB_TOKEN"
Optional, but see [SECRETS-QUICKSTART.md](SECRETS-QUICKSTART.md) for setup

## Pre-commit Hook

After running `bun.sh`, a git pre-commit hook is installed that prevents committing secrets.

### Hook Behavior
✅ **Allows:** Normal code commits  
❌ **Blocks:** Commits containing patterns like:
- `ghp_` (GitHub token pattern)
- `GITHUB_TOKEN=` 
- `SSH_KEY_CONTENT=`
- `-----BEGIN PRIVATE` (key markers)
- `password=`
- `secret=`

### Bypassing Hook (if needed)
```bash
git commit --no-verify
```

## File Permissions

`bun.sh` ensures these files are executable:
- `copy-repo-branches.sh` (755)
- `tests/test_copy_branches_local.sh` (755)
- `.git/hooks/pre-commit` (755)

## Platform Compatibility

| OS | Support | Notes |
|----|---------|-------|
| Linux | ✅ Full | Tested on Ubuntu 20.04+ |
| macOS | ✅ Full | Requires Bash 4.0+ (may need to upgrade) |
| Windows WSL | ✅ Full | Use WSL 2 recommended |
| Windows (native) | ⚠️ Partial | Requires Git Bash or WSL |

## Version Information

Current environment:
- **Bash version:** See `bash --version`
- **Git version:** See `git --version`
- **bun.sh version:** v1.0 (February 2026)

**Note:** This project does not require Node.js, Bun runtime, npm, or yarn.

## Related Files

- [README.md](README.md) - Project overview
- [SECRETS.md](SECRETS.md) - Secret management guide
- [SECRETS-QUICKSTART.md](SECRETS-QUICKSTART.md) - Quick setup guide
- [copy-repo-branches.sh](copy-repo-branches.sh) - Main script for copying branches

## Next Steps

After running `bun.sh`:

1. **Set up secrets** - See [SECRETS-QUICKSTART.md](SECRETS-QUICKSTART.md)
2. **Test locally** - Run `tests/test_copy_branches_local.sh`
3. **Use the script** - Run `./copy-repo-branches.sh <target-repo>`
