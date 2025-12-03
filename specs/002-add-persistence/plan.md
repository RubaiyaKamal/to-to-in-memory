# Implementation Plan: JSON Persistence

## Architecture Changes

### 1. Storage Layer
- Create a new class `JsonTaskRepository` in `src/todo/storage/json_repository.py`.
- Implement `TaskRepository` interface.
- Use Python's built-in `json` module.
- **File Path**: Default to `tasks.json` in the current directory.

### 2. CLI Layer
- Update `src/todo/cli/app.py` to initialize `JsonTaskRepository` instead of `InMemoryTaskRepository`.

## Detailed Design

### JsonTaskRepository
- `__init__(file_path: str = "tasks.json")`: Initialize with file path. Load data if file exists.
- `_save()`: Helper method to write current `_tasks` dict to disk.
- `_load()`: Helper method to read from disk and populate `_tasks`.
- `add()`: Add to dict, then call `_save()`.
- `update()`: Update dict, then call `_save()`.
- `delete()`: Remove from dict, then call `_save()`.
- `get()`, `get_all()`: Read from memory (which is synced with disk on load).

### Serialization
- `Task` -> `dict`: `asdict(task)` or manual mapping (handling `Enum` and `datetime`).
- `dict` -> `Task`: Reconstruct `Task` object (parsing `datetime` strings).

## Verification Plan

### Automated Tests
- Create `tests/unit/storage/test_json_repository.py`.
- Test persistence:
    1.  Create repo, add task.
    2.  Destroy repo instance.
    3.  Create new repo instance.
    4.  Verify task exists.

### Manual Verification
- Run CLI commands in sequence:
    1.  `todo add "Persistent Task"`
    2.  `todo list` (Should show the task)
    3.  `todo complete <ID>`
    4.  `todo list` (Should show updated status)
