# Pull Request Guidelines

This document provides guidelines for creating and reviewing pull requests for feature branches.

## Overview

This project uses a feature branch workflow:

```
main (production)
├── edit-todo (feature branch) → PR to main
└── sort-filter (feature branch) → PR to main
```

## Creating a Pull Request

### For Edit-Todo Feature

1. **Ensure tests pass**
   ```bash
   git checkout edit-todo
   bun run test:edit
   ```

2. **Create PR to main**
   ```bash
   gh pr create --base main --head edit-todo \
     --title "Feature: Edit Todo Functionality" \
     --body "$(cat FEATURE-EDIT-TODO.md)"
   ```

3. **Manual PR creation** (GitHub Web UI)
   - Navigate to: https://github.com/hhimanshu/ll-todo-app/compare/main...edit-todo
   - Title: "Feature: Edit Todo Functionality"
   - Description: Copy from FEATURE-EDIT-TODO.md
   - Click "Create pull request"

### For Sort-Filter Feature

1. **Ensure tests pass**
   ```bash
   git checkout sort-filter
   bun run test:sort-filter
   ```

2. **Create PR to main**
   ```bash
   gh pr create --base main --head sort-filter \
     --title "Feature: Sort and Filter Todos" \
     --body "$(cat FEATURE-SORT-FILTER.md)"
   ```

3. **Manual PR creation** (GitHub Web UI)
   - Navigate to: https://github.com/hhimanshu/ll-todo-app/compare/main...sort-filter
   - Title: "Feature: Sort and Filter Todos"
   - Description: Copy from FEATURE-SORT-FILTER.md
   - Click "Create pull request"

## PR Checklist

Before submitting a pull request, verify:

- [ ] **Tests Pass**
  ```bash
  bun run test:edit        # For edit-todo
  bun run test:sort-filter # For sort-filter
  ```

- [ ] **Code Quality**
  - Follows existing code style
  - Comments for complex logic
  - No debug statements

- [ ] **Documentation**
  - FEATURE-<NAME>.md is complete
  - API/interface documented
  - Examples provided

- [ ] **Commit Messages**
  - Clear and descriptive
  - References issue numbers if applicable
  - Follows conventional commits

- [ ] **No Secrets**
  - No credentials in code
  - Pre-commit hooks pass
  - No sensitive data in commits

## Required PR Information

### PR Title Format
```
Feature: [Feature Name]
Fixes: [Issue if applicable]
```

Examples:
- "Feature: Edit Todo Functionality"
- "Feature: Sort and Filter Todos"

### PR Description Template

```markdown
## Description
Brief description of the feature

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] All tests passing (bun run test:edit)
- [ ] Manual testing completed
- [ ] Edge cases tested

## Documentation
- FEATURE-<NAME>.md updated
- API endpoints documented
- Examples provided

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update

## Related Issues
Closes #123

## Screenshots (if applicable)
[Screenshots of UI changes, if any]
```

## Code Review Process

### Reviewer Checklist

1. **Functionality**
   - [ ] Feature works as documented
   - [ ] Tests all pass
   - [ ] No breaking changes to main

2. **Code Quality**
   - [ ] Code is clean and readable
   - [ ] No unnecessary complexity
   - [ ] Error handling present

3. **Testing**
   - [ ] Test coverage adequate (>80%)
   - [ ] Edge cases covered
   - [ ] Performance acceptable

4. **Documentation**
   - [ ] API changes documented
   - [ ] README updated if needed
   - [ ] Comments explain complex logic

5. **Security**
   - [ ] No secrets committed
   - [ ] Input validation present
   - [ ] Error messages don't leak info

### Review Comments

Use these comment templates:

**Approve**
```
✅ Looks good! Ready to merge.
```

**Request Changes**
```
🔄 Changes requested:
- [Issue 1]
- [Issue 2]
```

**Comment Only**
```
💭 Minor suggestion:
- [Suggestion]
```

## Merging

### Prerequisites
- [ ] All tests passing
- [ ] At least 1 approval
- [ ] No merge conflicts
- [ ] All conversations resolved

### Merge Command
```bash
# Using GitHub CLI
gh pr merge <PR_NUMBER> --merge

# Or use "Merge" button in GitHub UI
```

### After Merge
1. Delete feature branch
   ```bash
   git branch -d edit-todo    # Local
   git push origin -d edit-todo # Remote
   ```

2. Verify in main
   ```bash
   git checkout main
   git pull origin main
   git log --oneline -5
   ```

## Handling Merge Conflicts

If conflicts occur during merge:

1. **Fetch latest**
   ```bash
   git fetch origin
   ```

2. **Rebase on main**
   ```bash
   git checkout edit-todo
   git rebase origin/main
   ```

3. **Resolve conflicts**
   - Edit files with conflicts
   - Remove conflict markers
   - `git add <file>`

4. **Continue rebase**
   ```bash
   git rebase --continue
   ```

5. **Force push** (only on your feature branch)
   ```bash
   git push -f origin edit-todo
   ```

6. **Re-run tests**
   ```bash
   bun run test:edit
   ```

## Example PR Workflow

### Step 1: Prepare Feature Branch
```bash
git checkout edit-todo
git pull origin main
bun run test:edit
```

### Step 2: Create PR
```bash
gh pr create --base main --head edit-todo \
  --title "Feature: Edit Todo Functionality" \
  --draft  # Create as draft if still working
```

### Step 3: Get Review
- Reviewers provide feedback
- Make requested changes
- Push updates (PR auto-updates)

### Step 4: Approval & Merge
```bash
# Once approved
gh pr merge <PR_NUMBER> --merge

# Verify merge
git checkout main
git pull origin main
```

### Step 5: Cleanup
```bash
git branch -d edit-todo
git push origin -d edit-todo
```

## Additional Resources

- [FEATURE-EDIT-TODO.md](FEATURE-EDIT-TODO.md) - Edit feature specification
- [FEATURE-SORT-FILTER.md](FEATURE-SORT-FILTER.md) - Sort/filter feature specification
- [DEV.md](DEV.md) - Development guide
- [TESTING-SUMMARY.md](TESTING-SUMMARY.md) - Test coverage report
- [GitHub CLI Documentation](https://cli.github.com/manual/)

## Q&A

**Q: Can I make changes after PR is created?**
A: Yes, just push to the same branch. The PR auto-updates.

**Q: What if tests fail in the PR?**
A: Fix the code locally, commit, and push. GitHub will re-run tests automatically.

**Q: Can I merge my own PR?**
A: Generally, ask another team member to review first.

**Q: What if main has updates after I created my PR?**
A: Rebase on main to get latest changes (see "Handling Merge Conflicts" section).

---

**Last Updated:** February 2026
**Version:** 1.0
**Audience:** Developers, Reviewers, Team Leads
