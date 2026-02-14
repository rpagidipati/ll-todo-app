# ll-todo-app

A todo application repository with multiple branches for feature development.

## Prerequisites

- **Bash** 4.0+ (for running scripts)
- **Git** 2.20+ (for version control)  
- **SSH key** (for GitHub authentication)
- **Bun** 1.0+ (optional, for package management and script running)
- Optional: **GPG** (for commit signing)

Note: This project uses bash shell scripts. Bun is an optional runtime that can be used to run scripts via `bun run`, but all scripts work standalone in bash.

## Quick Start

Initialize your environment:

```bash
./bun.sh
```

This will verify all requirements and set up git hooks for security.

### Using Bun (Optional)

With Bun installed, you can run scripts via NPM-style commands:

```bash
bun run setup       # ./bun.sh
bun run test        # tests/test_copy_branches_local.sh
bun run copy-branches  # ./copy-repo-branches.sh <target-repo>
```

Or run scripts directly:

```bash
./bun.sh
./copy-repo-branches.sh git@github.com:youruser/yourrepo.git
```

Secrets and testing
-------------------

This repository includes `copy-repo-branches.sh`, a script to copy all branches from a source repo to a target repo. For security the script supports passing secrets via environment variables rather than embedding keys in files.

- To provide an SSH private key (kept secret), set `SSH_KEY_CONTENT` to the full private key contents. The script will write it to a temporary file with secure permissions and use it for `git` operations, then shred the file on exit.
- Alternatively set `GITHUB_TOKEN` to use HTTPS authentication; the script will convert `git@github.com:owner/repo.git` into an HTTPS URL containing the token for the push step.

Storing secrets
---------------

- On CI (GitHub Actions) store `SSH_KEY_CONTENT` and `GITHUB_TOKEN` in the repository's Secrets and pass them as environment variables to the job.
- Locally, avoid committing keys. Use your OS keyring, an SSH agent, or export variables in your shell session for testing only.

Tests
-----

A local test is provided at `tests/test_copy_branches_local.sh`. It:

- Creates a temporary non-network `source` git repo with a few branches.
- Creates a bare `target` repo locally.
- Runs `copy-repo-branches.sh` using a `file://` URL for the target (no network or secrets required).

Run the test:

```bash
chmod +x tests/test_copy_branches_local.sh
tests/test_copy_branches_local.sh
```

If you want to run the real copy to GitHub, add your SSH key to GitHub and either:

1. Add your private key as `SSH_KEY_CONTENT` (CI-friendly). Example (local):

```bash
export SSH_KEY_CONTENT="$(cat ~/.ssh/id_ed25519)"
./copy-repo-branches.sh git@github.com:youruser/yourrepo.git
```

2. Or set `GITHUB_TOKEN` (short-lived PAT) and run:

```bash
export GITHUB_TOKEN=ghp_xxx
./copy-repo-branches.sh git@github.com:youruser/yourrepo.git
```

The script will not persist keys to the repository.
