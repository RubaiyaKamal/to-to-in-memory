# Todo In-Memory Constitution

## Core Principles

### I. Clean Code & Python Best Practices
- Follow PEP 8 style guidelines
- Write self-documenting code with clear variable and function names
- Keep functions small and focused on a single responsibility
- Use type hints for better code clarity and IDE support
- Maintain proper separation of concerns

### II. Command-Line Interface First
- Every feature must be accessible via CLI
- Use clear, intuitive command structure: `todo <action> [arguments]`
- Provide helpful error messages and usage instructions
- Support both short and long argument formats
- Output should be human-readable with clear formatting

### III. Test-Driven Development (NON-NEGOTIABLE)
- Write tests before implementation
- All features must have corresponding unit tests
- Maintain test coverage above 80%
- Tests must pass before any commit
- Follow Red-Green-Refactor cycle strictly

### IV. Spec-Driven Development
- Every feature starts with a specification document
- Specifications must be reviewed and approved before implementation
- Use Spec-Kit Plus for structured specification management
- Maintain specs history in the `specs/` folder
- Document architectural decisions in ADR format

### V. Dependency Management with UV
- Use UV for all Python dependency management
- Keep `pyproject.toml` up to date
- Lock dependencies with `uv.lock`
- Use virtual environments for isolation
- Document all required dependencies

### VI. Data Integrity & Validation
- Validate all user inputs
- Use Pydantic models for data validation
- Ensure data consistency across operations
- Handle edge cases gracefully
- Provide clear error messages for invalid data

## Technology Stack

### Required Technologies
- **Language**: Python 3.11+
- **Package Manager**: UV
- **Testing**: pytest, pytest-cov
- **Code Quality**: ruff (linting), mypy (type checking)
- **Data Validation**: Pydantic
- **Storage**: In-memory (with future persistence support)

### Project Structure
```
to-do-in-memory/
├── src/              # Source code
├── tests/            # Test files
├── specs/            # Specification documents
├── .specify/         # Spec-Kit Plus configuration
├── pyproject.toml    # Project configuration
└── README.md         # Project documentation
```

## Development Workflow

### Feature Development Process
1. **Specification Phase**
   - Create feature specification in `specs/` folder
   - Document requirements, acceptance criteria, and constraints
   - Get specification approved before coding

2. **Planning Phase**
   - Create implementation plan
   - Break down into tasks
   - Identify dependencies and risks

3. **Implementation Phase**
   - Write tests first (TDD)
   - Implement feature to pass tests
   - Refactor for clean code
   - Update documentation

4. **Verification Phase**
   - Run all tests (`uv run pytest`)
   - Check code quality (`uv run ruff check`)
   - Verify type hints (`uv run mypy`)
   - Manual testing of CLI commands

5. **Documentation Phase**
   - Update README.md
   - Update CLAUDE.md with AI collaboration notes
   - Document any architectural decisions

### Quality Gates
- All tests must pass
- Code coverage must be ≥ 80%
- No linting errors
- Type checking must pass
- Manual verification of CLI functionality

## Governance

### Constitution Authority
- This constitution supersedes all other development practices
- All code reviews must verify compliance with these principles
- Any deviation must be documented and justified

### Amendment Process
- Amendments require documentation of rationale
- Must include migration plan if affecting existing code
- Version number must be incremented

### Compliance
- All pull requests must comply with this constitution
- Complexity must be justified with clear benefits
- Use `.specify/memory/guidance.md` for runtime development guidance

**Version**: 1.0.0 | **Ratified**: 2025-12-02 | **Last Amended**: 2025-12-04
