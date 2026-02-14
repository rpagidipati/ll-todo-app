# Secrets Quick Reference

## TL;DR - Setup in 5 Minutes

### Option 1: SSH Key (Recommended)

```bash
# 1. Generate key if you don't have one
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519 -N ""

# 2. Add public key to GitHub
# https://github.com/settings/ssh/new
cat ~/.ssh/id_ed25519.pub  # Copy this

# 3. Add private key to repository secrets
# https://github.com/rpagidipati/ll-todo-app/settings/secrets/actions
# Name: SSH_KEY_CONTENT
# Value: (paste output of: cat ~/.ssh/id_ed25519)
```

### Option 2: GitHub Token

```bash
# 1. Create token at https://github.com/settings/tokens
# - Scopes: repo
# - Expiration: 90 days
# - Save the token

# 2. Add to repository secrets
# https://github.com/rpagidipati/ll-todo-app/settings/secrets/actions
# Name: GITHUB_TOKEN
# Value: ghp_xxxxxxxxxxxxx
```

## Using Secrets

### In GitHub Actions
Already configured in workflow - no action needed after step above.

### Locally
```bash
# Option 1: SSH
export SSH_KEY_CONTENT="$(cat ~/.ssh/id_ed25519)"
./copy-repo-branches.sh git@github.com:youruser/yourrepo.git

# Option 2: Token
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"
./copy-repo-branches.sh git@github.com:youruser/yourrepo.git
```

## Verify Setup

1. Go to: https://github.com/rpagidipati/ll-todo-app/settings/secrets/actions
2. Should show `SSH_KEY_CONTENT` OR `GITHUB_TOKEN` (not both needed)
3. Trigger workflow: Actions tab > Copy Branches to Target Repo > Run workflow

## Files with Secrets References
- `.github/workflows/copy-branches.yml` - Passes to workflow
- `copy-repo-branches.sh` - Uses via environment variables
- `SECRETS.md` - Full setup guide
- `SECRETS-REFERENCE.md` - Technical reference

## Zero Hardcoded Secrets
✅ Verified no passwords, keys, or tokens in any files except examples with `_xxx` placeholders

## More Help
See `SECRETS.md` for detailed instructions and troubleshooting.
