# Todo In-Memory Console App Constitution

## Core Principles

### I. Test-First Development (NON-NEGOTIABLE)
- **TDD Mandatory**: All code must follow Red-Green-Refactor cycle
- Tests written first → User approved → Tests fail → Implementation → Tests pass
- No production code without corresponding tests
- Minimum 80% code coverage required
- Tests must be clear, maintainable, and serve as documentation

### II. Clean Code & SOLID Principles
- **Single Responsibility**: Each class/function has one clear purpose
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Many specific interfaces over one general
- **Dependency Inversion**: Depend on abstractions, not concretions
- Clear, descriptive naming (no abbreviations unless universally understood)
- Functions should be small (max 20 lines preferred)
- No magic numbers or strings - use constants

### III. Library-First Architecture
- Core functionality implemented as standalone, reusable libraries
- Each library must be:
  - Self-contained and independently testable
  - Well-documented with clear purpose
  - Versioned independently if needed
- No organizational-only libraries - each must provide real functionality
- Clear separation between business logic and presentation layer

### IV. CLI Interface Standards
- **Text I/O Protocol**: stdin/args → stdout, errors → stderr
- Support both human-readable and JSON output formats
- Consistent command structure and naming
- Comprehensive help text for all commands
- Graceful error handling with clear error messages
- Exit codes: 0 (success), 1 (user error), 2 (system error)

### V. In-Memory Data Management
- Data stored in memory using appropriate Python data structures
- No persistence layer in basic version
- Data validation at entry points
- Immutability preferred where possible
- Clear data models with type hints

### VI. Simplicity & YAGNI
- Start simple, add complexity only when needed
- Avoid premature optimization
- No speculative features
- Prefer composition over inheritance
- Keep dependencies minimal

## Technology Stack

### Required Technologies
- **Python**: 3.13+ (using latest features and type hints)
- **Package Manager**: UV for fast, reliable dependency management
- **Testing**: pytest for unit and integration tests
- **Type Checking**: mypy for static type analysis
- **Code Quality**: ruff for linting and formatting

### Project Structure
```
to-do-in-memory/
├── .specify/              # SpecKit Plus configuration
│   ├── memory/
│   │   └── constitution.md
│   ├── templates/
│   └── scripts/
├── src/
│   └── todo/
│       ├── __init__.py
│       ├── models/        # Data models
│       ├── storage/       # In-memory storage
│       ├── services/      # Business logic
│       └── cli/           # CLI interface
├── tests/
│   ├── unit/
│   └── integration/
├── history/
│   ├── prompts/           # Prompt History Records
│   └── adr/               # Architecture Decision Records
├── pyproject.toml
├── README.md
└── CLAUDE.md
```

## Development Workflow

### Spec-Driven Development Process
1. **Specification**: Document requirements in `specs/<feature>/spec.md`
2. **Planning**: Create architectural plan in `specs/<feature>/plan.md`
3. **Tasks**: Break down into testable tasks in `specs/<feature>/tasks.md`
4. **Red**: Write failing tests first
5. **Green**: Implement minimal code to pass tests
6. **Refactor**: Improve code while keeping tests green
7. **Document**: Update docs and create PHR (Prompt History Record)

### Code Review Requirements
- All tests must pass
- Code coverage must meet minimum threshold (80%)
- Type hints required for all functions
- Docstrings required for all public APIs
- No linting errors (ruff)
- No type errors (mypy)

### Quality Gates
- **Pre-commit**: Linting and formatting checks
- **Pre-push**: All tests must pass
- **Pre-merge**: Code review and coverage check

## Feature Requirements (Basic Level)

### 1. Add Task
- Accept title (required) and description (optional)
- Auto-generate unique ID
- Set initial status to "incomplete"
- Validate input (non-empty title)
- Return confirmation with task ID

### 2. View Tasks
- List all tasks with ID, title, status
- Show description when available
- Format output clearly (table or list)
- Handle empty task list gracefully
- Support filtering by status (optional enhancement)

### 3. Update Task
- Update title and/or description by ID
- Validate task exists
- Validate new data
- Return confirmation
- Preserve task ID and status

### 4. Delete Task
- Remove task by ID
- Validate task exists
- Confirm deletion
- Handle errors gracefully

### 5. Mark Complete/Incomplete
- Toggle task status by ID
- Validate task exists
- Return confirmation with new status
- Support both marking complete and incomplete

## Governance

### Constitution Authority
- This constitution supersedes all other development practices
- All code must comply with these principles
- Amendments require:
  - Documentation of rationale
  - User approval
  - Migration plan for existing code

### Compliance Verification
- All changes must be verified against constitution
- Complexity must be justified with clear rationale
- Use CLAUDE.md for runtime development guidance
- Create ADRs for significant architectural decisions

### Documentation Standards
- README.md: Setup instructions, usage examples, feature overview
- CLAUDE.md: AI assistant instructions and development guidelines
- Inline comments: Only for complex logic, not obvious code
- Docstrings: All public functions, classes, and modules

**Version**: 1.0.0 | **Ratified**: 2025-12-03 | **Last Amended**: 2025-12-03
