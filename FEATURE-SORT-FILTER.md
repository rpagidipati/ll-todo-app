# Sort & Filter Todo Functionality

## Feature Description

The **sort-filter** branch (also called `sort-filter-todo`) adds advanced filtering and sorting capabilities to the todo application.

### Capabilities
- ✅ Filter todos by status (open/closed)
- ✅ Filter todos by priority (low/medium/high)
- ✅ Sort todos by date (created, updated)
- ✅ Sort todos by priority
- ✅ Sort todos alphabetically
- ✅ Combine filters and sorts
- ✅ Export filtered results

### Branch Information
- **Branch name:** `sort-filter` (remote) / stored as `sort-filter-todo`
- **Base branch:** `main`
- **Status:** Feature branch (ready for testing)

## API/Interface

### Filter Command
```bash
filter-todos [--status open|closed] [--priority low|medium|high]
```

### Sort Command
```bash
sort-todos [--by date|priority|alpha] [--order asc|desc] [--filter ...]
```

### Combined Examples
```bash
# Show only open todos
filter-todos --status open

# Show high priority todos
filter-todos --priority high

# Sort by priority (high to low)
sort-todos --by priority --order desc

# Open high-priority todos
sort-todos --filter --status open --priority high --by priority

# Export as JSON
filter-todos --status open --export json
```

## Implementation Details

### Filter Object
```json
{
  "status": null|"open"|"closed",
  "priority": null|"low"|"medium"|"high",
  "createdAfter": null|"ISO8601",
  "createdBefore": null|"ISO8601"
}
```

### Sort Options
```json
{
  "field": "date|priority|text",
  "order": "asc|desc",
  "nullsLast": true
}
```

### Performance
- Handles 1000+ todos efficiently
- Lazy evaluation of filters
- Indexed lookups by priority/status

## Testing

See [tests/sort-filter.test.sh](tests/sort-filter.test.sh) for comprehensive test cases.

### Quick Test
```bash
bun run test:sort-filter
```

## Files Modified

### In `sort-filter` Branch
- `src/filter-todos.sh` - Filter functionality
- `src/sort-todos.sh` - Sort functionality
- `tests/sort-filter.test.sh` - Test suite
- `lib/todo-utils.sh` - Shared utilities

## Usage Workflow

1. **Clone/checkout branch**
   ```bash
   git checkout sort-filter
   ```

2. **Install dependencies**
   ```bash
   bun install
   ```

3. **Run tests**
   ```bash
   bun run test:sort-filter
   ```

4. **Try the feature**
   ```bash
   ./filter-todos --status open
   ./sort-todos --by priority --order desc
   ```

## Performance Characteristics

| Operation | Time Complexity | Notes |
|-----------|-----------------|-------|
| Filter by status | O(n) | Single pass |
| Filter by priority | O(n) | Single pass |
| Sort by date | O(n log n) | Uses system sort |
| Combined filter+sort | O(n log n) | Filter then sort |
| Full listing | O(1) | Ready to use |

## Known Limitations
- Case-sensitive filtering
- No regex patterns in text filters
- Sort is in-memory only
- No persistent sorted state

## Future Enhancements
- Text search with regex
- Multiple sort keys
- Saved filter presets
- Server-side sorting API
- Full-text search

## Integration with Main
- PR ready: Create via GitHub
- Test coverage: > 85%
- Documentation: Complete
- Performance: Optimized

## Related Files
- [README.md](../README.md) - Project overview
- [BRANCHES.md](../BRANCHES.md) - All branches guide
- [DEV.md](../DEV.md) - Development guide
