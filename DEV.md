# Development Guide

This document provides comprehensive guidance for developing and testing the todo application features across multiple branches.

## Table of Contents

1. [Development Setup](#development-setup)
2. [Branch Management](#branch-management)
3. [Testing Features](#testing-features)
4. [Development Environment](#development-environment)
5. [Testing URLs and Endpoints](#testing-urls-and-endpoints)
6. [Feature Workflow](#feature-workflow)
7. [Integration Testing](#integration-testing)
8. [Troubleshooting](#troubleshooting)

## Development Setup

### Prerequisites

Ensure you have the following installed:

```bash
# Required
- Bash 4.0 or higher
- Git 2.20 or higher
- Bun 1.3.9 or higher (for runtime and package management)
- Node.js 18.0.0 or higher (optional, alternative to Bun)

# Optional
- SSH key pair (for GitHub authentication)
- GitHub CLI (gh) for PR management
```

### Initial Setup

1. **Install dependencies and verify environment:**
   ```bash
   bun run setup
   ```
   This runs `bun.sh` which:
   - Checks required tools (Bash, Git, SSH)
   - Validates SSH key configuration
   - Creates pre-commit hooks to prevent secret leaks
   - Verifies documentation exists

2. **Verify installation:**
   ```bash
   bun --version
   git --version
   bash --version
   ```

### Environment Variables

For local development, you can optionally set:

```bash
# For branch copying operations
export SSH_KEY_CONTENT="your-ssh-private-key"  # Full key content
export GITHUB_TOKEN="your-github-token"        # GitHub personal access token

# Do NOT commit these to .git or version control
# Use .env file (in .gitignore) or export in shell session only
```

## Branch Management

### Active Branches

This project uses three main branches:

| Branch | Purpose | Features |
|--------|---------|----------|
| `main` | Production/stable | Base functionality, integration point |
| `edit-todo` | Edit feature | Modify todo text, status, priority |
| `sort-filter` | Query feature | Filter by status/priority, sort results |

### Create Local Copies of Branches

```bash
# Copy all remote branches to local
git fetch origin

# Checkout feature branches
git checkout edit-todo
git checkout sort-filter

# Verify all three branches exist
git branch -a
```

Output should show:
```
  edit-todo
  main
  sort-filter
* (current branch)
```

### Switch Between Branches

```bash
# Switch to edit-todo branch
git checkout edit-todo

# Switch to sort-filter branch
git checkout sort-filter

# Return to main
git checkout main
```

## Testing Features

### Run All Tests

```bash
# Run all test suites via package.json
bun run test              # Branch copying tests
bun run test:edit         # Edit-todo feature tests
bun run test:sort-filter  # Sort-filter feature tests

# Or run directly with bash
bash tests/test_copy_branches_local.sh
bash tests/edit-todo.test.sh
bash tests/sort-filter.test.sh
```

### Edit-Todo Feature Tests

Location: `tests/edit-todo.test.sh`

Tests the following functionality:

- **Load existing todo:** Retrieve todo by ID from database
- **Edit text:** Modify todo text content
- **Edit status:** Change status from open ↔ closed
- **Edit priority:** Change priority (low/medium/high)
- **Validation:** Reject invalid IDs, empty text, invalid statuses
- **Metadata preservation:** Keep creation timestamp unchanged
- **Timestamp updates:** Update modification timestamp on edit
- **Multiple fields:** Edit text, status, priority simultaneously

**Run tests:**
```bash
bun run test:edit

# Expected output
# === Edit Todo Feature Tests ===
# ▶ Load existing todo by ID
#   ✓ PASS
# ▶ Edit todo text
#   ✓ PASS
# [... more tests ...]
# === Test Summary ===
# Tests run:    10
# Tests passed: 10
# Tests failed: 0
# All tests passed!
```

### Sort-Filter Feature Tests

Location: `tests/sort-filter.test.sh`

Tests the following functionality:

- **Filter by status:** Return only open or closed todos
- **Filter by priority:** Return todos of specific priority
- **Combined filters:** Apply multiple filters together
- **Sort by date:** Ascending/descending chronological order
- **Sort by priority:** High → Medium → Low
- **Sort alphabetically:** By todo text content
- **Export format:** JSON output structure
- **Performance:** Filter 150+ todos in <1 second (benchmarked)
- **Edge cases:** Empty filters, invalid values

**Run tests:**
```bash
bun run test:sort-filter

# Expected output
# === Sort & Filter Todo Feature Tests ===
# ▶ Filter todos by status=open
#   ✓ PASS: '4' == '4'
# ▶ Filter todos by status=closed
#   ✓ PASS: '3' == '3'
# [... more tests ...]
# === Test Summary ===
# Tests run:    15
# Tests passed: 15
# Tests failed: 0
# All tests passed!
```

### Test Coverage Summary

```
Total Tests: 35
├── Branch Copy Tests: 10
├── Edit-Todo Tests: 10
└── Sort-Filter Tests: 15

Test Categories:
├── Unit Tests: 28 (isolated functionality)
├── Integration Tests: 5 (feature interaction)
└── Performance Tests: 2 (benchmarking)
```

## Development Environment

### Local Development Server Setup

While this project is primarily bash/git utilities, here's how to set up a development environment for the todo app itself:

```bash
# Option 1: Bun development server (if Node code added)
bun run dev

# Option 2: Watch mode for tests
watch -n 2 'bun run test'

# Option 3: Manual test loop
while true; do
    bun run test:edit
    bun run test:sort-filter
    sleep 2
done
```

### File Structure for Development

```
/workspaces/ll-todo-app/
├── main branch
│   ├── .github/
│   │   └── workflows/
│   │       └── copy-branches.yml
│   ├── tests/
│   │   ├── test_copy_branches_local.sh
│   │   ├── edit-todo.test.sh
│   │   └── sort-filter.test.sh
│   ├── copy-repo-branches.sh
│   ├── bun.sh
│   ├── package.json
│   └── README.md
│
├── edit-todo branch (extends main with)
│   ├── src/
│   │   └── edit-todo.sh (feature implementation)
│   └── docs/
│       └── FEATURE-EDIT-TODO.md
│
└── sort-filter branch (extends main with)
    ├── src/
    │   └── sort-filter.sh (feature implementation)
    └── docs/
        └── FEATURE-SORT-FILTER.md
```

## Testing URLs and Endpoints

### Local Test Directories

When running tests, temporary directories are created:

```bash
# Test databases (auto-created and cleaned up)
/tmp/todo-test-*/
├── todos.db          # Test todo database
├── large.db          # Performance test: 150 todos
└── repos/            # Test git repositories

# These are cleaned up automatically after each test run
```

### Test Data Structures

**Todo Database Format (todos.db):**
```
id|text|status|priority|created_at|modified_at

Example:
1|Buy milk|open|low|2026-02-14T10:00:00Z|2026-02-14T10:00:00Z
2|Write report|open|high|2026-02-14T09:00:00Z|2026-02-14T09:00:00Z
3|Call client|closed|medium|2026-02-14T08:00:00Z|2026-02-14T11:00:00Z
```

### API Examples (for when REST/HTTP endpoints are added)

```bash
# Edit todo (future HTTP endpoint)
curl -X PATCH http://localhost:3000/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"text": "Buy organic milk", "priority": "medium"}'

# Filter todos
curl "http://localhost:3000/api/todos?status=open&priority=high"

# Sort todos
curl "http://localhost:3000/api/todos?sort=priority&order=desc"

# Get todo
curl http://localhost:3000/api/todos/1
```

## Feature Workflow

### Typical Development Workflow

1. **Create/Checkout Feature Branch**
   ```bash
   git checkout edit-todo
   # or
   git checkout sort-filter
   ```

2. **Implement Feature**
   ```bash
   # Edit source files in src/ directory
   vim src/edit-todo.sh
   ```

3. **Run Feature Tests**
   ```bash
   # Test edit-todo feature
   bun run test:edit
   
   # Test sort-filter feature
   bun run test:sort-filter
   ```

4. **Run All Tests (regression check)**
   ```bash
   bun run test          # Branch copy test
   bun run test:edit     # Edit feature
   bun run test:sort-filter  # Sort/filter feature
   ```

5. **Commit Changes**
   ```bash
   git add src/ tests/ docs/
   git commit -m "feat: implement edit-todo functionality"
   ```

6. **Push to Remote**
   ```bash
   git push origin edit-todo
   ```

7. **Create Pull Request**
   ```bash
   # Using GitHub CLI
   gh pr create --base main --head edit-todo \
     --title "Feature: Edit Todo" \
     --body "$(cat FEATURE-EDIT-TODO.md)"
   ```

### Merging to Main

```bash
# Checkout main branch
git checkout main

# Pull latest changes
git pull origin main

# Merge feature branch
git merge edit-todo

# Or use GitHub PR interface for code review
gh pr merge <PR_NUMBER> --merge
```

## Integration Testing

### Test Multiple Features Together

```bash
# Scenario 1: Edit and Filter
1. Edit a todo's priority (edit-todo feature)
2. Filter todos by new priority (sort-filter feature)
3. Verify edited todo appears in filtered results

# Scenario 2: Sort and Edit
1. Sort todos by priority
2. Edit lowest priority todo to high
3. Verify position changes in re-sorted list

# Scenario 3: Copy Branches and Test
bun run test  # Copies branches, then test both features
```

### Write Integration Tests

Create `tests/integration.test.sh`:

```bash
#!/usr/bin/env bash
# Integration tests combining edit-todo and sort-filter features

# Test: Edit a todo, then filter by its new priority
TEST_TODO_ID=2
./src/edit-todo.sh $TEST_TODO_ID --priority high
FILTERED=$(./src/sort-filter.sh --priority high | grep "^$TEST_TODO_ID|")
[ -n "$FILTERED" ] && echo "✓ Integration test passed"
```

## Troubleshooting

### Common Issues

**Issue: `bun: command not found`**
```bash
# Solution: Bun not installed
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc  # Reload shell
```

**Issue: `chmod: cannot access tests/edit-todo.test.sh`**
```bash
# Solution: File doesn't exist or wrong path
ls -la tests/
# If missing, recreate:
git checkout edit-todo.test.sh
```

**Issue: Tests fail - "Todo not found"**
```bash
# Verify test database structure
cat /tmp/todo-test-*/todos.db
# Should have format: id|text|status|priority|created|modified
```

**Issue: Pre-commit hook blocks my commit**
```bash
# If committing documentation with secret examples:
git commit --no-verify  # Use with caution!
# Or remove patterns from commit and use --no-verify only for legitimate cases
```

### Debug Test Output

**Run test with verbose output:**
```bash
bash -x tests/edit-todo.test.sh 2>&1 | less
```

**Check test file syntax:**
```bash
bash -n tests/sort-filter.test.sh  # Check syntax without running
```

**Test individual assertions:**
```bash
# Create standalone test script
cat > /tmp/test-debug.sh << 'EOF'
#!/bin/bash
TEST_DB="/tmp/test.db"
echo "1|Buy milk|open|low|2026-02-01T10:00:00Z|2026-02-01T10:00:00Z" > "$TEST_DB"
echo "Open todos: $(grep -c '|open|' "$TEST_DB")"
rm "$TEST_DB"
EOF
bash /tmp/test-debug.sh
```

### Getting Help

**Check documentation:**
- [FEATURE-EDIT-TODO.md](FEATURE-EDIT-TODO.md) - Edit feature details
- [FEATURE-SORT-FILTER.md](FEATURE-SORT-FILTER.md) - Sort/filter feature details
- [README.md](README.md) - Project overview
- [BUN-SETUP.md](BUN-SETUP.md) - Bun runtime setup
- [SECRETS.md](SECRETS.md) - Secret management

**Check test implementation:**
```bash
head -50 tests/edit-todo.test.sh      # See how tests work
head -50 tests/sort-filter.test.sh
```

**Run setup verification:**
```bash
bun run setup  # Re-runs environment checks
```

## Next Steps

1. **Implement feature code** in feature branches (edit-todo, sort-filter)
2. **Update test cases** as features evolve
3. **Create pull requests** to main with passing tests
4. **Document API endpoints** once HTTP layer added
5. **Add performance benchmarks** for large datasets
6. **Implement continuous integration** in GitHub Actions

---

**Last Updated:** February 2026  
**Maintained By:** Development Team  
**Version:** 1.0.0
