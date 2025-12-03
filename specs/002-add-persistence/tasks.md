# Tasks: Add JSON Persistence

- [ ] Create `JsonTaskRepository` implementation <!-- id: 0 -->
    - [ ] Create `src/todo/storage/json_repository.py`
    - [ ] Implement `_load` and `_save` methods with JSON serialization
    - [ ] Implement `TaskRepository` interface methods
- [ ] Add Unit Tests for JsonRepository <!-- id: 1 -->
    - [ ] Create `tests/unit/storage/test_json_repository.py`
    - [ ] Test file creation, reading, writing, and data integrity
- [ ] Integrate with CLI <!-- id: 2 -->
    - [ ] Modify `src/todo/cli/app.py` to use `JsonTaskRepository`
- [ ] Verify Persistence <!-- id: 3 -->
    - [ ] Run manual CLI workflow to confirm data survives between commands
