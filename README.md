# Todo In-Memory Console App

A command-line todo application with in-memory storage, built using spec-driven development with TDD principles.

## Features

✅ **Add tasks** with title and optional description
✅ **List all tasks** with status indicators
✅ **Show specific task** details
✅ **Update tasks** (title and/or description)
✅ **Delete tasks** by ID
✅ **Mark tasks** as complete or incomplete

## Installation

### Prerequisites

- Python 3.13 or higher
- [UV](https://github.com/astral-sh/uv) package manager

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd to-do-in-memory
```

2. Install dependencies:
```bash
uv sync --dev
```

## Usage

### Running the Application

You can run the application using either method:

```bash
# Using UV
uv run todo <command>

# Or as a Python module
uv run python -m todo <command>
```

### Commands

#### Add a Task
```bash
uv run todo add "Buy groceries"
uv run todo add "Buy groceries" -d "Milk, eggs, bread"
```

#### List All Tasks
```bash
uv run todo list
```

#### Show a Specific Task
```bash
uv run todo show <task-id>
```

#### Update a Task
```bash
uv run todo update <task-id> -t "New title"
uv run todo update <task-id> -d "New description"
uv run todo update <task-id> -t "New title" -d "New description"
```

#### Delete a Task
```bash
uv run todo delete <task-id>
```

#### Mark Task as Complete
```bash
uv run todo complete <task-id>
```

#### Mark Task as Incomplete
```bash
uv run todo incomplete <task-id>
```

#### Get Help
```bash
uv run todo --help
uv run todo <command> --help
```

## Development

### Running Tests

```bash
# Run all tests with coverage
uv run pytest -v --cov=src/todo --cov-report=term-missing

# Run only unit tests
uv run pytest tests/unit/ -v

# Run only integration tests
uv run pytest tests/integration/ -v
```

### Code Quality

```bash
# Run linter
uv run ruff check src/ tests/

# Run formatter
uv run ruff format src/ tests/

# Run type checker
uv run mypy src/todo
```

## Project Structure

```
to-do-in-memory/
├── .specify/              # SpecKit Plus configuration
│   ├── memory/
│   │   └── constitution.md
│   └── templates/
├── src/
│   └── todo/
│       ├── __init__.py
│       ├── __main__.py
│       ├── models/        # Data models (Task, TaskStatus)
│       ├── storage/       # In-memory storage (Repository)
│       ├── services/      # Business logic (TodoService)
│       └── cli/           # CLI interface and formatter
├── tests/
│   ├── unit/              # Unit tests
│   └── integration/       # Integration tests
├── pyproject.toml
├── README.md
└── CLAUDE.md
```

## Architecture

The application follows a layered architecture with clear separation of concerns:

- **Models Layer**: Data structures (Task, TaskStatus)
- **Storage Layer**: In-memory repository implementing CRUD operations
- **Services Layer**: Business logic and validation
- **CLI Layer**: Command-line interface and output formatting

## Testing

The project follows strict TDD (Test-Driven Development) principles:

- **57 tests total** (46 unit + 11 integration)
- **All tests passing** ✅
- Tests written before implementation (Red-Green-Refactor)
- Comprehensive coverage of all features and edge cases

## Important Notes

⚠️ **Data Persistence**: This is an in-memory application. All data is lost when the application exits. This is by design for the basic level implementation.

⚠️ **Task IDs**: Each task is assigned a unique UUID. You'll need to copy the task ID from the output to update, delete, or mark tasks as complete.

## Technology Stack

- **Python**: 3.13+
- **Package Manager**: UV
- **Testing**: pytest, pytest-cov
- **Type Checking**: mypy
- **Linting/Formatting**: ruff

## License

This project is built as a learning exercise following spec-driven development practices.
