# Specification: Add JSON File Persistence

## Goal
Enable the Todo application to persist tasks between CLI command executions by saving data to a local JSON file.

## Problem
Currently, the application uses `InMemoryTaskRepository`, which loses all data when the program exits. Since the CLI runs a new process for each command, tasks added in one command are not available in subsequent commands.

## Requirements

### Functional
1.  **Persistence**: Tasks must be saved to a file (e.g., `tasks.json`) immediately upon creation, update, or deletion.
2.  **Loading**: The application must load existing tasks from the file when it starts.
3.  **Data Format**: Data should be stored in a human-readable JSON format.
4.  **Location**: The data file should be stored in the current working directory or a user-specific data directory.
5.  **Default Behavior**: The application should use this persistent storage by default instead of in-memory storage.

### Technical
1.  **New Repository**: Implement `JsonTaskRepository` that adheres to the `TaskRepository` interface.
2.  **Serialization**: Convert `Task` objects to dictionaries for JSON serialization and vice-versa.
3.  **Error Handling**: Handle cases where the file doesn't exist (create it) or is corrupted (raise error or reset).
