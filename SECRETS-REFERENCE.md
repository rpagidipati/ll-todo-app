# Secret References Summary

This document maps all secret/sensitive data references in the repository to their usage locations.

## Secret Variables Reference

### SSH_KEY_CONTENT

**Type:** Environment Variable  
**Purpose:** SSH private key for git authentication  
**Format:** Full contents of ed25519 or RSA private key including `-----BEGIN...-----END` lines  

**Usage Locations:**
1. `.github/workflows/copy-branches.yml` - Line 21
   - Read from `${{ secrets.SSH_KEY_CONTENT }}`
   - Used in: `env.SSH_KEY_CONTENT` section

2. `copy-repo-branches.sh` - Line 60
   - Read from `$SSH_KEY_CONTENT` environment variable
   - Written securely to temporary file with `chmod 600`
   - Automatically shredded on script exit

3. `README.md` - Line 38
   - Local usage example: `export SSH_KEY_CONTENT="$(cat ~/.ssh/id_ed25519)"`

**Security:** 
- ✅ Never logged in scripts
- ✅ Temporary file securely deleted after use
- ✅ GitHub Actions automatically masks in logs

### GITHUB_TOKEN

**Type:** Environment Variable / GitHub Secret  
**Purpose:** GitHub Personal Access Token for HTTPS authentication  
**Format:** `ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` (40+ chars)  

**Usage Locations:**
1. `.github/workflows/copy-branches.yml` - Line 22
   - Read from `${{ secrets.GITHUB_TOKEN }}`
   - Used in: `env.GITHUB_TOKEN` section

2. `copy-repo-branches.sh` - Line 71
   - Read from `$GITHUB_TOKEN` environment variable
   - Converts SSH URLs to HTTPS URLs with embedded token
   - Only used if provided and SSH key not used

3. `README.md` - Line 45
   - Local usage example: `export GITHUB_TOKEN=ghp_xxx`

**Security:**
- ✅ Embedded in HTTPS URL only for authentication
- ✅ Sensitive in logs: Use GitHub Secrets deployment
- ✅ Can be revoked anytime from GitHub settings

## Files Referencing Secrets

### Configuration Files
- `.github/workflows/copy-branches.yml` - References both `SSH_KEY_CONTENT` and `GITHUB_TOKEN`

### Scripts
- `copy-repo-branches.sh` - Accepts both secrets via env vars
- `tests/test_copy_branches_local.sh` - No secrets (uses file:// URLs)

### Documentation
- `SECRETS.md` - Instructions for setting up secrets
- `README.md` - Basic secret usage examples

### Git Ignore
- `.gitignore` - Prevents committing `.ssh/`, `.env`, `*.key`, etc.

## No Hardcoded Secrets

The following have been verified:
- ❌ No API keys in code
- ❌ No tokens in workflow files
- ❌ No SSH private keys in repository
- ❌ No `.env` files committed
- ❌ No credentials.json or config files

## How Secrets Flow

```
GitHub Secrets (encrypted at rest)
        ↓
Workflow passes to job: ${{ secrets.SSH_KEY_CONTENT }}
        ↓
Job exports as environment variable: SSH_KEY_CONTENT
        ↓
Script reads from: $SSH_KEY_CONTENT
        ↓
Script uses securely, then shreds temporary files
        ↓
Job completes, environment cleared
```

## Adding New Secrets

If new secrets are needed:

1. **Add to GitHub Secrets:**
   - Settings > Secrets and variables > Actions > New repository secret

2. **Reference in Workflow:**
   ```yaml
   env:
     NEW_SECRET: ${{ secrets.NEW_SECRET }}
   ```

3. **Use in Script:**
   ```bash
   if [ -n "$NEW_SECRET" ]; then
       # Use securely
       shred temp files on exit
   fi
   ```

4. **Document in SECRETS.md**

5. **Update this summary**

## Auditing

To verify no secrets were committed:

```bash
# Check git history for secret patterns
git log -p --all | grep -i "password\|token\|key\|secret" || echo "No secrets found"

# Check staged files
git diff --cached | grep -i "password\|token\|key\|secret" || echo "Clean"

# Scan for common patterns
git grep -i "ghp_\|sk_live\|----BEGIN PRIVATE" || echo "No secrets in repo"
```

## References

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [OWASP: Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
