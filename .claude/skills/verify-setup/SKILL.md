---
name: verify-setup
description: Verify development environment setup for the to-do application. Checks prerequisites, dependencies, configuration files, database connectivity, and service health. Use after setup-phase to ensure everything is ready.
---

# Verify Setup

Comprehensive verification of development environment setup.

## Quick Start

```bash
# Verify Phase 2 setup
bash .claude/skills/verify-setup/scripts/verify.sh phase-2

# Verify Phase 3 setup
bash .claude/skills/verify-setup/scripts/verify.sh phase-3

# Verify all phases
bash .claude/skills/verify-setup/scripts/verify.sh all
```

## What It Checks

### Prerequisites
- Python 3.9+ installation and version
- Node.js 18+ installation and version
- npm installation and version
- Git installation

### Backend Verification
- Virtual environment exists
- Python dependencies installed
- .env file exists and has required variables
- Database file exists and is accessible
- FastAPI server can start (optional)

### Frontend Verification
- node_modules directory exists
- .env.local file exists
- TypeScript configuration valid
- Build can compile successfully (optional)

### Service Health
- Backend API responds to health check
- Frontend dev server responds
- Database connections work
- API endpoints are accessible

## Verification Levels

### Quick Verification (Default)
Checks files and configurations without starting services:
```bash
bash .claude/skills/verify-setup/scripts/verify.sh
```

### Full Verification
Includes starting services and testing endpoints:
```bash
bash .claude/skills/verify-setup/scripts/verify.sh --full
```

### Specific Component
Verify only backend or frontend:
```bash
bash .claude/skills/verify-setup/scripts/verify.sh --backend
bash .claude/skills/verify-setup/scripts/verify.sh --frontend
```

## Output Format

The verification script provides color-coded output:
- ✓ Green: Check passed
- ✗ Red: Check failed
- ⚠ Yellow: Warning or optional check

## Integration with .specify/

This skill:
- Validates constitution requirements from `.specify/memory/constitution.md`
- Ensures all dependencies match specification
- Can be run as pre-flight check before development
- Referenced in onboarding documentation

## Common Issues and Fixes

| Issue | Fix |
|-------|-----|
| Python version too old | Install Python 3.9+ from python.org |
| Virtual env missing | Run setup-phase skill |
| Missing .env | Copy .env.example to .env |
| Dependencies missing | Run setup-phase skill or `pip install -r requirements.txt` |
| Database not found | Initialize with `python -c "from db import init_db; init_db()"` |
| Port in use | Stop other services or change port in .env |

## Usage in CI/CD

This verification can run in CI/CD pipelines:
```yaml
# .github/workflows/verify.yml
- name: Verify Setup
  run: bash .claude/skills/verify-setup/scripts/verify.sh --full
```

## Troubleshooting Mode

Run with verbose output for debugging:
```bash
bash .claude/skills/verify-setup/scripts/verify.sh --verbose
```

## Exit Codes

- `0`: All checks passed
- `1`: Critical checks failed
- `2`: Some optional checks failed (warnings only)

## Report Generation

Generate a verification report:
```bash
bash .claude/skills/verify-setup/scripts/verify.sh --report > setup-report.txt
```
