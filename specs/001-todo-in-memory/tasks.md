# Feature Tasks: Todo In-Memory Console App Basic Features

**Feature Branch**: `001-todo-in-memory`
**Created**: 2025-12-03
**Plan**: C:/Users/Lap Zone/to-do-in-memory/specs/001-todo-in-memory/plan.md
**Spec**: C:/Users/Lap Zone/to-do-in-memory/specs/001-todo-in-memory/spec.md

## Implementation Strategy

This feature will be implemented incrementally, focusing on delivering the most critical user stories (P1) first to establish a minimum viable product. Each user story will be developed and tested independently, ensuring a stable and functional application at each stage.

## Phase 1: Setup

### Goal

Initialize the project structure and install necessary dependencies as per the `plan.md`.

### Tasks

- [ ] T001 Create project structure: `src/todo/__init__.py`, `src/todo/models/`, `src/todo/storage/`, `src/todo/services/`, `src/todo/cli/`, `tests/unit/`, `tests/integration/`
- [ ] T002 Install dependencies: `pyproject.toml` (add `uv`, `pytest`, `mypy`, `ruff`)
- [ ] T003 Configure `ruff` and `mypy`: `.ruff.toml`, `mypy.ini`

## Phase 2: Foundational Components

### Goal

Define the core Task data model and establish the in-memory storage mechanism.

### Tasks

- [ ] T004 Define `Task` dataclass in `src/todo/models/task.py` (ID, title, description, status)
- [ ] T005 Create `TaskRepository` for in-memory storage in `src/todo/storage/task_repository.py` (CRUD operations)

## Phase 3: User Story 1 - Add a New Task (P1)

### Goal

Enable users to add new tasks with a title and optional description, receiving confirmation.

### Independent Test

Can be fully tested by adding tasks and verifying their details and confirmation messages.

### Tasks

- [ ] T006 [US1] Create unit tests for `add_task` in `tests/unit/test_task_service.py` (title only, title+description, empty title)
- [ ] T007 [US1] Implement `add_task` in `src/todo/services/task_service.py` (generates ID, sets status incomplete, validates title)
- [ ] T008 [US1] Create CLI command for `add` in `src/todo/cli/commands.py` (handles input, calls service, prints confirmation/error)

## Phase 4: User Story 2 - View All Tasks (P1)

### Goal

Allow users to view a list of all tasks with their details.

### Independent Test

Can be fully tested by creating tasks and then listing them, verifying correct display of all details.

### Tasks

- [ ] T009 [US2] Create unit tests for `get_all_tasks` in `tests/unit/test_task_service.py` (empty list, multiple tasks, tasks with descriptions)
- [ ] T010 [US2] Implement `get_all_tasks` in `src/todo/services/task_service.py` (retrieves all tasks from repository)
- [ ] T011 [US2] Create CLI command for `list` in `src/todo/cli/commands.py` (calls service, formats and prints task list/empty message)

## Phase 5: User Story 3 - Update an Existing Task (P2)

### Goal

Enable users to modify the title or description of existing tasks.

### Independent Test

Can be fully tested by creating a task, updating its details, and then verifying the changes persist.

### Tasks

- [ ] T012 [US3] Create unit tests for `update_task` in `tests/unit/test_task_service.py` (update title, update description, empty title, non-existent ID)
- [ ] T013 [US3] Implement `update_task` in `src/todo/services/task_service.py` (finds task, updates fields, validates new title, handles not found)
- [ ] T014 [US3] Create CLI command for `update` in `src/todo/cli/commands.py` (handles input, calls service, prints confirmation/error)

## Phase 6: User Story 4 - Mark a Task Complete/Incomplete (P2)

### Goal

Allow users to toggle the completion status of tasks.

### Independent Test

Can be fully tested by setting and unsetting a task's completion status and observing the change.

### Tasks

- [ ] T015 [US4] Create unit tests for `toggle_task_status` in `tests/unit/test_task_service.py` (mark complete, mark incomplete, non-existent ID)
- [ ] T016 [US4] Implement `toggle_task_status` in `src/todo/services/task_service.py` (finds task, toggles status, handles not found)
- [ ] T017 [US4] Create CLI command for `complete` / `incomplete` in `src/todo/cli/commands.py` (handles input, calls service, prints confirmation/error)

## Phase 7: User Story 5 - Delete a Task (P3)

### Goal

Enable users to remove tasks from their list.

### Independent Test

Can be fully tested by creating a task, deleting it, and confirming its absence from the list.

### Tasks

- [ ] T018 [US5] Create unit tests for `delete_task` in `tests/unit/test_task_service.py` (delete existing, delete non-existent ID)
- [ ] T019 [US5] Implement `delete_task` in `src/todo/services/task_service.py` (removes task from repository, handles not found)
- [ ] T020 [US5] Create CLI command for `delete` in `src/todo/cli/commands.py` (handles input, calls service, prints confirmation/error)

## Phase 8: Polish & Cross-Cutting Concerns

### Goal

Finalize the CLI interface, error handling, and overall application quality.

### Tasks

- [ ] T021 Implement main CLI entry point in `src/todo/cli/main.py` (arg parsing, command dispatch)
- [ ] T022 Add comprehensive help text for all commands (`src/todo/cli/commands.py`)
- [ ] T023 Ensure graceful error handling and consistent error messages across the application

## Dependencies

- Phase 1 (Setup) -> Phase 2 (Foundational Components)
- Phase 2 (Foundational Components) -> All User Story Phases
- User Story 1 (Add Task) can be implemented independently once foundational components are ready.
- User Story 2 (View All Tasks) can be implemented independently once foundational components are ready.
- User Story 3 (Update Task) depends on User Story 1.
- User Story 4 (Mark Complete/Incomplete) depends on User Story 1.
- User Story 5 (Delete Task) depends on User Story 1.

## Parallel Execution Opportunities

- T001, T002, T003 can be executed in parallel.
- T004, T005 can be executed in parallel within the Foundational phase.
- Within each User Story phase, the test tasks and CLI command tasks can potentially be worked on in parallel with the service implementation, but the service implementation should be completed before the CLI command is fully integrated.
- User Story 1 and User Story 2 can be developed in parallel after Foundational Components are complete.

## Suggested MVP Scope

For the initial MVP, focus on completing **User Story 1: Add a New Task** and **User Story 2: View All Tasks**. These two stories provide the core functionality for users to create and see their to-do items, delivering immediate value.