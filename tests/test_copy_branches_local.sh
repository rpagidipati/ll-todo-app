#!/usr/bin/env bash

# Local test for copy-repo-branches.sh
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPT="$ROOT_DIR/copy-repo-branches.sh"

TMP=$(mktemp -d)
SRC_REPO="$TMP/source-repo"
TARGET_BARE="$TMP/target-repo.git"

echo "[TEST] Preparing source repository"
mkdir -p "$SRC_REPO"
cd "$SRC_REPO"
git init -b main .
echo "initial" > README.md
git add README.md
git commit -m "initial commit"

# create additional branches
git checkout -b edit-todo
echo "edit-todo" > edit.txt
git add edit.txt
git commit -m "edit todo"

git checkout main
git checkout -b filter-sort
echo "filter-sort" > filter.txt
git add filter.txt
git commit -m "filter and sort"

git checkout main

echo "[TEST] Creating bare target repository"
git init --bare "$TARGET_BARE"

echo "[TEST] Running script"
# Use file:// URL to avoid network and secret usage
FILE_URL="file://$TARGET_BARE"
"$SCRIPT" "$FILE_URL" "$SRC_REPO" || true

echo "[TEST] Verifying branches in target"
git --git-dir="$TARGET_BARE" branch -a || true
git --git-dir="$TARGET_BARE" show-ref | sed -n '1,120p'

echo "[TEST] Cleanup"
rm -rf "$TMP"

echo "[TEST] Completed"
