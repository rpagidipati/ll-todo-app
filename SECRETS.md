# Managing Secrets

This document explains how to securely manage secrets required for this repository's CI/CD workflows and local script execution.

## Overview

The repository uses **environment variables** to pass sensitive credentials instead of hardcoding them. Secrets are never committed to the repository.

**Required Secrets:**
- `SSH_KEY_CONTENT` - SSH private key for authentication (ed25519 or RSA)
- `GITHUB_TOKEN` - GitHub Personal Access Token for HTTPS authentication

Choose **ONE** authentication method (SSH or HTTPS), not both.

## GitHub Secrets Setup

### 1. SSH Key Method (Recommended)

#### Generate SSH Key (if you don't have one)

```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519 -N ""
```

#### Add Public Key to GitHub

1. Copy your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

2. Go to GitHub: **Settings > SSH and GPG keys > New SSH key**

3. Paste the public key and save

#### Add Private Key to Repository Secrets

1. Go to: **GitHub repo > Settings > Secrets and variables > Actions**

2. Click **New repository secret**

3. Name: `SSH_KEY_CONTENT`

4. Value: Paste the **full contents** of your private key:
   ```bash
   cat ~/.ssh/id_ed25519
   ```
   (Include `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

5. Save

### 2. GitHub Token Method (Alternative)

#### Generate Personal Access Token

1. Go to: **GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)**

2. Click **Generate new token > Generate new token (classic)**

3. Give it a name: `ll-todo-app-ci`

4. Set expiration: Choose **90 days** or suitable timeframe

5. Select scopes:
   - ✅ `repo` - Full control of private repositories

6. Click **Generate token**

7. **Copy the token immediately** (you won't see it again)

#### Add Token to Repository Secrets

1. Go to: **GitHub repo > Settings > Secrets and variables > Actions**

2. Click **New repository secret**

3. Name: `GITHUB_TOKEN`

4. Value: Paste the token

5. Save

## Local Usage

### Using SSH Key Locally

```bash
export SSH_KEY_CONTENT="$(cat ~/.ssh/id_ed25519)"
./copy-repo-branches.sh git@github.com:youruser/yourrepo.git
```

### Using GitHub Token Locally

```bash
export GITHUB_TOKEN="your_personal_access_token"
./copy-repo-branches.sh git@github.com:youruser/yourrepo.git
```

The script will convert the ssh URL to HTTPS and use the token.

## GitHub Actions Workflow

The workflow at `.github/workflows/copy-branches.yml` uses repository secrets:

```yaml
env:
  SSH_KEY_CONTENT: ${{ secrets.SSH_KEY_CONTENT }}
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Secrets are:
- ✅ Never logged or printed
- ✅ Automatically masked in workflow logs
- ✅ Only accessible to authorized users
- ✅ Not stored in repository files

## Security Best Practices

### ✓ DO:
- Store long-lived credentials (SSH keys) in GitHub Secrets
- Use short-lived Personal Access Tokens (90 days) when possible
- Review who has access to repository secrets (Settings > Collaborators)
- Rotate tokens and keys periodically
- Use separate SSH keys for CI if possible

### ✗ DON'T:
- Commit private keys to the repository
- Add secrets directly in workflow files
- Share tokens via email or chat
- Use user's personal SSH keys in shared CI systems
- Check `.ssh/` directories into git

## Verifying Secrets Are Configured

1. Go to: **GitHub repo > Settings > Secrets and variables > Actions**

2. You should see:
   - `SSH_KEY_CONTENT` OR
   - `GITHUB_TOKEN`

3. Secrets are masked and cannot be viewed after creation (by design)

4. To verify a secret works, trigger the workflow manually:
   - Go to **Actions tab > Copy Branches to Target Repo**
   - Click **Run workflow**
   - It will fail if secrets are not configured or invalid

## Revoking Secrets

### SSH Key
1. Remove from GitHub: **Settings > SSH and GPG keys > Delete**
2. Generate a new key and upload it
3. Update the secret in repository

### GitHub Token
1. Go to: **GitHub > Settings > Developer settings > PATs > Tokens (classic)**
2. Find your token and click **Delete**
3. Generate a new token
4. Update the secret in repository

## Troubleshooting

### Workflow fails: "Permission denied (publickey)"
- Verify SSH public key is added to your GitHub account
- Verify `SSH_KEY_CONTENT` secret contains the full private key (including `-----BEGIN ... -----END` lines)

### Workflow fails: "fatal: Authentication failed"
- Verify `GITHUB_TOKEN` secret is set and valid
- Check token expiration hasn't passed
- Verify token has `repo` scope

### Script works locally but fails in GitHub Actions
- Ensure running with same secret locally: `export SSH_KEY_CONTENT="$(cat ~/.ssh/id_ed25519)"`
- Check file permissions: `chmod 600 ~/.ssh/id_ed25519`

## References

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [SSH Keys in GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
