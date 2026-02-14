# Edit Todo Functionality

## Feature Description

The **edit-todo** branch extends the core todo application with the ability to modify existing todo items.

### Capabilities
- ✅ Edit todo text/description
- ✅ Edit todo status (open/closed)
- ✅ Edit todo priority
- ✅ Preserve todo metadata (creation date, ID)
- ✅ Validation of input
- ✅ Error handling for invalid operations

### Branch Information
- **Branch name:** `edit-todo`
- **Base branch:** `main`
- **Status:** Feature branch (ready for testing)

## API/Interface

### Edit Todo Command
```bash
edit-todo [id] [--text "new text"] [--status open|closed] [--priority low|medium|high]
```

### Examples
```bash
# Edit todo text
edit-todo 1 --text "Updated task description"

# Change status
edit-todo 2 --status closed

# Change priority
edit-todo 1 --priority high

# Combined changes
edit-todo 3 --text "New text" --status open --priority medium
```

## Implementation Details

### Data Structure
```json
{
  "id": "unique-identifier",
  "text": "todo description",
  "status": "open|closed",
  "priority": "low|medium|high",
  "createdAt": "ISO8601 timestamp",
  "updatedAt": "ISO8601 timestamp"
}
```

### Validation Rules
- ID must exist
- Text must be non-empty
- Status must be: open, closed
- Priority must be: low, medium, high
- Timestamps are auto-managed

## Testing

See [tests/edit-todo.test.sh](tests/edit-todo.test.sh) for comprehensive test cases.

### Quick Test
```bash
bun run test:edit
```

## Files Modified

### In `edit-todo` Branch
- `src/edit-todo.sh` - Edit functionality implementation
- `tests/edit-todo.test.sh` - Test suite
- `lib/todo-utils.sh` - Shared utilities

## Usage Workflow

1. **Clone/checkout branch**
   ```bash
   git checkout edit-todo
   ```

2. **Install dependencies**
   ```bash
   bun install
   ```

3. **Run tests**
   ```bash
   bun run test:edit
   ```

4. **Try the feature**
   ```bash
   ./edit-todo 1 --text "My updated task"
   ```

## Known Limitations
- Input text maximum 500 characters
- No concurrent edits (last-write-wins)
- Edits are not reversible (no undo)

## Future Enhancements
- Bulk edit multiple todos
- Edit history tracking
- Undo/revert capability
- Concurrent edit locking

## Integration with Main
- PR ready: Create via GitHub
- Test coverage: > 80%
- Documentation: Complete

## Related Files
- [README.md](../README.md) - Project overview
- [BRANCHES.md](../BRANCHES.md) - All branches guide
- [DEV.md](../DEV.md) - Development guide
