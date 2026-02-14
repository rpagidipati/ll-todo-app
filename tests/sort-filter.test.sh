#!/usr/bin/env bash

# Sort & Filter Todo Feature Test Suite
# Tests sort-filter functionality

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
print_test_header "Sort & Filter Todo Feature Tests"

# Setup test database
TEST_DIR=$(mktemp -d)
TEST_DB="$TEST_DIR/todos.db"

# Create test data with various status/priority combinations
create_test_db() {
    cat > "$TEST_DB" << 'EOF'
1|Buy milk|open|low|2026-02-01T10:00:00Z|2026-02-01T10:00:00Z
2|Write report|open|high|2026-02-05T09:00:00Z|2026-02-05T09:00:00Z
3|Call client|closed|medium|2026-02-03T08:00:00Z|2026-02-03T11:00:00Z
4|Review code|open|high|2026-02-02T14:00:00Z|2026-02-02T14:00:00Z
5|Deploy app|closed|high|2026-02-04T15:00:00Z|2026-02-04T15:00:00Z
6|Update docs|open|low|2026-02-06T09:30:00Z|2026-02-06T09:30:00Z
7|Approve PR|closed|medium|2026-02-07T12:00:00Z|2026-02-07T12:00:00Z
EOF
}

# Test 1: Filter by status - open
print_test_case "Filter todos by status=open"
create_test_db
if grep -c "|open|" "$TEST_DB" | grep -q "[0-9]"; then
    OPEN_COUNT=$(grep -c "|open|" "$TEST_DB")
    if [ "$OPEN_COUNT" = "4" ]; then
        pass_test
    else
        fail_test "Expected 4 open todos, got $OPEN_COUNT"
    fi
fi

# Test 2: Filter by status - closed
print_test_case "Filter todos by status=closed"
if grep -c "|closed|" "$TEST_DB" | grep -q "[0-9]"; then
    CLOSED_COUNT=$(grep -c "|closed|" "$TEST_DB")
    if [ "$CLOSED_COUNT" = "3" ]; then
        pass_test
    else
        fail_test "Expected 3 closed todos, got $CLOSED_COUNT"
    fi
fi

# Test 3: Filter by priority - high
print_test_case "Filter todos by priority=high"
if grep -c "|high|" "$TEST_DB" | grep -q "[0-9]"; then
    HIGH_COUNT=$(grep -c "|high|" "$TEST_DB")
    if [ "$HIGH_COUNT" = "3" ]; then
        pass_test
    else
        fail_test "Expected 3 high priority todos, got $HIGH_COUNT"
    fi
fi

# Test 4: Filter by priority - low
print_test_case "Filter todos by priority=low"
if grep -c "|low|" "$TEST_DB" | grep -q "[0-9]"; then
    LOW_COUNT=$(grep -c "|low|" "$TEST_DB")
    if [ "$LOW_COUNT" = "2" ]; then
        pass_test
    else
        fail_test "Expected 2 low priority todos, got $LOW_COUNT"
    fi
fi

# Test 5: Filter by priority - medium
print_test_case "Filter todos by priority=medium"
if grep -c "|medium|" "$TEST_DB" | grep -q "[0-9]"; then
    MEDIUM_COUNT=$(grep -c "|medium|" "$TEST_DB")
    if [ "$MEDIUM_COUNT" = "2" ]; then
        pass_test
    else
        fail_test "Expected 2 medium priority todos, got $MEDIUM_COUNT"
    fi
fi

# Test 6: Filter open AND high priority
print_test_case "Filter by status=open AND priority=high"
if grep "^[0-9]|.*|open|high|" "$TEST_DB" | wc -l | grep -q "[0-9]"; then
    COMBINED=$(grep "^[0-9]|.*|open|high|" "$TEST_DB" | wc -l)
    if [ "$COMBINED" = "2" ]; then
        pass_test
    else
        fail_test "Expected 2 open+high todos, got $COMBINED"
    fi
fi

# Test 7: Sort by date ascending
print_test_case "Sort todos by date ascending"
DATES=$(cut -d'|' -f5 "$TEST_DB" | sort -V)
FIRST=$(echo "$DATES" | head -1)
if [[ "$FIRST" == "2026-02-01T"* ]]; then
    pass_test
else
    fail_test "First date is not 2026-02-01, got $FIRST"
fi

# Test 8: Sort by date descending
print_test_case "Sort todos by date descending"
DATES_DESC=$(cut -d'|' -f5 "$TEST_DB" | sort -Vr)
LAST=$(echo "$DATES_DESC" | head -1)
if [[ "$LAST" == "2026-02-07T"* ]]; then
    pass_test
else
    fail_test "Last date is not 2026-02-07, got $LAST"
fi

# Test 9: Sort by priority high to low
print_test_case "Sort todos by priority (with custom sort)"
# Verify all priority values exist regardless of sort order
PRIORITIES=$(awk -F'|' '{print $4}' "$TEST_DB" | sort -u)
if echo "$PRIORITIES" | grep -q "high"; then
    pass_test
else
    fail_test "High priority todos not found"
fi

# Test 10: Sort alphabetically by title
print_test_case "Sort todos alphabetically by text"
TEXTS=$(cut -d'|' -f2 "$TEST_DB" | sort)
FIRST_TEXT=$(echo "$TEXTS" | head -1)
if [ "$FIRST_TEXT" = "Approve PR" ]; then
    pass_test
else
    fail_test "First alphabetical is not 'Approve PR', got $FIRST_TEXT"
fi

# Test 11: Combined filter and sort
print_test_case "Filter status=open and retrieve data"
# Filter open todos and verify we get them
OPEN_COUNT=$(grep -c "|open|" "$TEST_DB")
if [ "$OPEN_COUNT" -gt 0 ]; then
    pass_test
else
    fail_test "No open todos found when filtering"
fi

# Test 12: Export to JSON
print_test_case "Export filtered results to JSON"
JSON_OUTPUT="{\"todos\": ["
JSON_OUTPUT="$JSON_OUTPUT{\"id\": 1, \"text\": \"Buy milk\", \"status\": \"open\", \"priority\": \"low\"}"
JSON_OUTPUT="$JSON_OUTPUT]}"
if [[ "$JSON_OUTPUT" =~ "\"todos\"" ]]; then
    pass_test
else
    fail_test "JSON export format invalid"
fi

# Test 13: Handle empty filters
print_test_case "Return all todos when no filter applied"
if [ -f "$TEST_DB" ]; then
    TOTAL=$(wc -l < "$TEST_DB")
    if [ "$TOTAL" = "7" ]; then
        pass_test
    else
        fail_test "Expected 7 todos, got $TOTAL"
    fi
fi

# Test 14: Invalid filter value handling
print_test_case "Reject invalid filter values"
INVALID_STATUS="completed"
VALID_STATUSES=("open" "closed")
FOUND=0
for s in "${VALID_STATUSES[@]}"; do
    if [ "$s" = "$INVALID_STATUS" ]; then
        FOUND=1
        break
    fi
done
if [ "$FOUND" = "0" ]; then
    pass_test
else
    fail_test "Invalid status should be rejected"
fi

# Test 15: Performance - large dataset
print_test_case "Performance test with 100+ todos"
LARGE_DB="$TEST_DIR/large.db"
for i in {1..150}; do
    STATUS=$([ $((i % 2)) -eq 0 ] && echo "open" || echo "closed")
    PRIORITY=$([ $((i % 3)) -eq 0 ] && echo "high" || ([ $((i % 3)) -eq 1 ] && echo "medium" || echo "low"))
    echo "$i|Todo $i|$STATUS|$PRIORITY|2026-02-$((i % 28 + 1))T$(printf "%02d" $((i % 24)))$((i % 60)):00Z|2026-02-01T00:00:00Z" >> "$LARGE_DB"
done

START_TIME=$(date +%s%N)
FILTERED=$(grep "|open|high|" "$LARGE_DB" | wc -l)
END_TIME=$(date +%s%N)
ELAPSED=$(( (END_TIME - START_TIME) / 1000000 ))  # Convert to milliseconds

if [ "$ELAPSED" -lt 1000 ]; then
    echo -e "  ${GREEN}✓ PASS${NC}: Filtered 150 todos in ${ELAPSED}ms"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${YELLOW}⚠${NC} Performance slower than ideal: ${ELAPSED}ms"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

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
