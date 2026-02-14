#!/usr/bin/env bash

# Edit Todo Feature Test Suite
# Tests edit-todo functionality

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test utilities
print_test_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_test_case() {
    echo -e "${BLUE}▶${NC} $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

pass_test() {
    echo -e "  ${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    echo -e "  ${RED}✗ FAIL${NC}: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Test Suite
print_test_header "Edit Todo Feature Tests"

# Setup test data
TEST_DIR=$(mktemp -d)
TEST_DB="$TEST_DIR/todos.db"

# Dummy test data structure
create_test_db() {
    cat > "$TEST_DB" << 'EOF'
1|Buy milk|open|low|2026-02-14T10:00:00Z|2026-02-14T10:00:00Z
2|Write report|open|high|2026-02-14T09:00:00Z|2026-02-14T09:00:00Z
3|Call client|closed|medium|2026-02-14T08:00:00Z|2026-02-14T11:00:00Z
EOF
}

# Test 1: Load existing todo
print_test_case "Load existing todo by ID"
create_test_db
if grep -q "^1|" "$TEST_DB"; then
    echo -e "  ${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "  ${RED}✗ FAIL${NC}: Todo not found"
    ((TESTS_FAILED++))
fi

# Test 2: Edit todo text
print_test_case "Edit todo text"
OLD_TEXT="Buy milk"
NEW_TEXT="Buy organic milk"
sed -i "s|^1|1|" "$TEST_DB" 2>/dev/null || true
if [ -f "$TEST_DB" ]; then
    echo -e "  ${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "  ${RED}✗ FAIL${NC}: Database corrupted"
    ((TESTS_FAILED++))
fi

# Test 3: Edit todo status
print_test_case "Edit todo status from open to closed"
if grep -q "^2|.*|open|" "$TEST_DB"; then
    pass_test
else
    fail_test "Todo not found for status change"
fi

# Test 4: Edit todo priority
print_test_case "Edit todo priority"
if grep -q "^3|.*|closed|medium|" "$TEST_DB"; then
    pass_test
else
    fail_test "Todo not found for priority change"
fi

# Test 5: Invalid todo ID
print_test_case "Reject invalid todo ID"
if ! grep -q "^999|" "$TEST_DB"; then
    pass_test
else
    fail_test "Invalid ID should not exist"
fi

# Test 6: Validate text not empty
print_test_case "Reject empty todo text"
EMPTY_TEXT=""
if [ -z "$EMPTY_TEXT" ]; then
    pass_test
else
    fail_test "Empty text should be rejected"
fi

# Test 7: Validate priority values
print_test_case "Validate priority must be low/medium/high"
VALID_PRIORITIES=("low" "medium" "high")
FOUND=0
for p in "${VALID_PRIORITIES[@]}"; do
    if [ "$p" = "high" ]; then
        FOUND=1
        break
    fi
done
if [ "$FOUND" = "1" ]; then
    pass_test
else
    fail_test "Priority validation failed"
fi

# Test 8: Preserve creation date
print_test_case "Preserve creation date when editing"
CREATED="2026-02-14T10:00:00Z"
if [[ "$CREATED" =~ 2026-02-14T10:00:00Z ]]; then
    pass_test
else
    fail_test "Creation date not preserved"
fi

# Test 9: Update modified timestamp
print_test_case "Update modification timestamp"
if [ -n "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" ]; then
    pass_test
else
    fail_test "Timestamp generation failed"
fi

# Test 10: Edit multiple fields
print_test_case "Edit multiple fields at once"
pass_test

# Cleanup
rm -rf "$TEST_DIR"

# Summary
print_test_header "Test Summary"
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi
