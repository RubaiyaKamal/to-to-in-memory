---
name: run-tests
description: Run automated tests for the to-do application. Supports backend (pytest), frontend (Jest/Vitest), and E2E tests (Playwright). Integrates with TDD workflow and .specify/ framework.
---

# Run Tests

Execute automated tests for quality assurance and TDD workflow.

## Quick Start

```bash
# Run all tests (backend + frontend)
bash .claude/skills/run-tests/scripts/run.sh all

# Run backend tests only
bash .claude/skills/run-tests/scripts/run.sh backend

# Run frontend tests only
bash .claude/skills/run-tests/scripts/run.sh frontend

# Run E2E tests
bash .claude/skills/run-tests/scripts/run.sh e2e

# Run tests with coverage
bash .claude/skills/run-tests/scripts/run.sh backend --coverage
```

## Test Types

### Backend Tests (pytest)
- **Location**: `phase-*/backend/tests/`
- **Framework**: pytest
- **Coverage**: pytest-cov
- **Features**: Unit tests, integration tests, API tests

### Frontend Tests (Jest/Vitest)
- **Location**: `phase-*/frontend/__tests__/`
- **Framework**: Jest or Vitest
- **Features**: Component tests, hook tests, utility tests

### E2E Tests (Playwright)
- **Location**: `phase-*/e2e/`
- **Framework**: Playwright
- **Features**: User flow tests, integration tests

## Test Coverage

### Backend Coverage Requirements
- **Minimum**: 90% coverage
- **Reports**: HTML coverage report in `htmlcov/`
- **Command**: `pytest --cov=. --cov-report=html`

### Frontend Coverage Requirements
- **Minimum**: 80% coverage
- **Reports**: Coverage summary in terminal
- **Command**: `npm test -- --coverage`

## TDD Workflow Integration

This skill integrates with the Red-Green-Refactor cycle:

### Red Phase
```bash
# Write failing tests first
bash .claude/skills/run-tests/scripts/run.sh backend
# Expected: Tests fail (red)
```

### Green Phase
```bash
# Implement feature
# Run tests again
bash .claude/skills/run-tests/scripts/run.sh backend
# Expected: Tests pass (green)
```

### Refactor Phase
```bash
# Refactor code
# Ensure tests still pass
bash .claude/skills/run-tests/scripts/run.sh backend
# Expected: Tests pass (green)
```

## Options

| Option | Description |
|--------|-------------|
| `--coverage` | Generate coverage report |
| `--verbose` | Show detailed test output |
| `--watch` | Run tests in watch mode (frontend only) |
| `--debug` | Run in debug mode with extra logging |

## Examples

```bash
# Run backend tests with coverage
bash .claude/skills/run-tests/scripts/run.sh backend --coverage

# Run frontend tests in watch mode
bash .claude/skills/run-tests/scripts/run.sh frontend --watch

# Run specific test file
bash .claude/skills/run-tests/scripts/run.sh backend tests/test_tasks.py

# Run E2E tests with UI
bash .claude/skills/run-tests/scripts/run.sh e2e --headed
```

## Integration with .specify/

Referenced in task execution:
- **Task Definition**: `specs/<feature>/tasks.md` specifies test requirements
- **Red Phase**: Write tests (use this skill to verify they fail)
- **Green Phase**: Implement (use this skill to verify they pass)
- **Validation**: All tasks must have passing tests before completion

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Import errors | Install dependencies: `pip install -r requirements.txt` |
| Test not found | Check test file naming: `test_*.py` or `*_test.py` |
| Coverage too low | Add more tests to untested code paths |
| E2E tests fail | Ensure servers are running before E2E tests |

## CI/CD Integration

These tests are designed to run in CI/CD pipelines:
- **GitHub Actions**: `.github/workflows/test.yml`
- **Pre-commit hooks**: Run fast tests before commits
- **PR validation**: All tests must pass before merge
