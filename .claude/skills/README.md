# To-Do Application Skills

Project-specific development skills for the To-Do application. These skills integrate with the .specify/ framework and support the Spec-Driven Development (SDD) workflow.

## Available Skills

### 1. start-backend
Start the FastAPI backend server for development.

**Usage:**
```bash
# Start Phase 2 backend (port 8000)
bash .claude/skills/start-backend/scripts/start.sh

# Start Phase 3 backend (port 8001)
bash .claude/skills/start-backend/scripts/start.sh phase-3

# Check backend status
bash .claude/skills/start-backend/scripts/check.sh

# Stop backend
bash .claude/skills/start-backend/scripts/stop.sh
```

**Features:**
- Auto-detects phase and port
- Activates Python virtual environment
- Installs dependencies if needed
- Hot reload with uvicorn
- Health check endpoints

### 2. start-frontend
Start the Next.js frontend application for development.

**Usage:**
```bash
# Start Phase 2 frontend (port 3000)
bash .claude/skills/start-frontend/scripts/start.sh

# Start Phase 3 frontend (port 3001)
bash .claude/skills/start-frontend/scripts/start.sh phase-3

# Check frontend status
bash .claude/skills/start-frontend/scripts/check.sh

# Build for production
bash .claude/skills/start-frontend/scripts/build.sh
```

**Features:**
- Hot reload and Fast Refresh
- TypeScript compilation
- Automatic backend connectivity check
- Production build support

### 3. run-tests
Execute automated tests for TDD workflow.

**Usage:**
```bash
# Run all tests
bash .claude/skills/run-tests/scripts/run.sh all

# Run backend tests only
bash .claude/skills/run-tests/scripts/run.sh backend

# Run frontend tests only
bash .claude/skills/run-tests/scripts/run.sh frontend

# Run with coverage
bash .claude/skills/run-tests/scripts/run.sh backend --coverage

# Run E2E tests
bash .claude/skills/run-tests/scripts/run.sh e2e
```

**Features:**
- Backend: pytest with coverage (>90% target)
- Frontend: Jest/Vitest (>80% target)
- E2E: Playwright integration
- TDD Red-Green-Refactor support

### 4. setup-phase
Set up development environment for a specific phase.

**Usage:**
```bash
# Setup Phase 2
bash .claude/skills/setup-phase/scripts/setup.sh phase-2

# Setup Phase 3
bash .claude/skills/setup-phase/scripts/setup.sh phase-3

# Setup both phases
bash .claude/skills/setup-phase/scripts/setup.sh all
```

**What it does:**
- Checks prerequisites (Python, Node.js, npm)
- Creates Python virtual environments
- Installs all dependencies
- Creates configuration files (.env, .env.local)
- Initializes databases
- Provides next steps guidance

### 5. verify-setup
Verify development environment is properly configured.

**Usage:**
```bash
# Quick verification
bash .claude/skills/verify-setup/scripts/verify.sh phase-2

# Full verification (includes service health checks)
bash .claude/skills/verify-setup/scripts/verify.sh phase-2 --full

# Verify all phases
bash .claude/skills/verify-setup/scripts/verify.sh all
```

**Checks:**
- Prerequisites installed
- Virtual environments created
- Dependencies installed
- Configuration files present
- Database initialized
- Services responding (with --full)

### 6. ai-integration
Integrate OpenAI Agents SDK and MCP servers for conversational AI.

**Usage:**
```bash
# Verify OpenAI configuration
bash .claude/skills/ai-integration/scripts/verify-openai.sh

# Test MCP tools
bash .claude/skills/ai-integration/scripts/test-mcp-tools.sh

# Test chat endpoint
bash .claude/skills/ai-integration/scripts/test-chat.sh

# Start MCP server (optional standalone)
bash .claude/skills/ai-integration/scripts/start-mcp-server.sh
```

**Features:**
- 5 MCP tools (add/list/complete/update/delete tasks)
- OpenAI GPT-4 integration with function calling
- Stateless chat endpoint design
- Database-backed conversation state
- User isolation and JWT verification
- Complete implementation references

## Typical Workflows

### Initial Setup
```bash
# 1. Setup the environment
bash .claude/skills/setup-phase/scripts/setup.sh phase-2

# 2. Verify everything is ready
bash .claude/skills/verify-setup/scripts/verify.sh phase-2 --full

# 3. Start development servers
bash .claude/skills/start-backend/scripts/start.sh &
bash .claude/skills/start-frontend/scripts/start.sh
```

### TDD Development Cycle

#### Red Phase (Write Failing Tests)
```bash
# 1. Write tests in backend/tests/ or frontend/__tests__/

# 2. Run tests to verify they fail
bash .claude/skills/run-tests/scripts/run.sh backend
# Expected: Tests fail (red)
```

#### Green Phase (Make Tests Pass)
```bash
# 1. Implement the feature

# 2. Start servers for manual testing
bash .claude/skills/start-backend/scripts/start.sh &
bash .claude/skills/start-frontend/scripts/start.sh &

# 3. Run tests to verify they pass
bash .claude/skills/run-tests/scripts/run.sh backend
# Expected: Tests pass (green)
```

#### Refactor Phase (Improve Code)
```bash
# 1. Refactor code while keeping tests green

# 2. Continuously run tests
bash .claude/skills/run-tests/scripts/run.sh backend --coverage

# 3. Ensure coverage remains >90%
```

### Daily Development
```bash
# Morning: Start your environment
bash .claude/skills/verify-setup/scripts/verify.sh phase-2
bash .claude/skills/start-backend/scripts/start.sh &
bash .claude/skills/start-frontend/scripts/start.sh

# Development: Run tests frequently
bash .claude/skills/run-tests/scripts/run.sh backend

# Evening: Check everything still works
bash .claude/skills/run-tests/scripts/run.sh all --coverage
```

## Integration with .specify/

These skills integrate with the Spec-Driven Development workflow:

### Workflow Integration
- **sp.specify**: Create feature specs → Use skills to implement
- **sp.plan**: Create implementation plans → Reference skills in tasks
- **sp.tasks**: Generate task list → Execute using skills
- **sp.implement**: Execute tasks → Skills provide the tooling

### Constitution Alignment
- Follows principles from `.specify/memory/constitution.md`
- Supports TDD-first development (Red-Green-Refactor)
- Maintains >90% backend coverage requirement
- Ensures all changes are testable

### Task Execution
Skills are referenced in `specs/<feature>/tasks.md`:

```markdown
## Task: Implement User Authentication

### Test Cases
- [ ] Run tests: `bash .claude/skills/run-tests/scripts/run.sh backend`
- [ ] Expected: Tests fail (red phase)

### Implementation
- [ ] Start backend: `bash .claude/skills/start-backend/scripts/start.sh`
- [ ] Implement feature in backend/routes/auth.py
- [ ] Run tests again: `bash .claude/skills/run-tests/scripts/run.sh backend`
- [ ] Expected: Tests pass (green phase)
```

## Troubleshooting

### Backend Issues
```bash
# Check what's running
bash .claude/skills/start-backend/scripts/check.sh

# Verify setup
bash .claude/skills/verify-setup/scripts/verify.sh phase-2

# Stop and restart
bash .claude/skills/start-backend/scripts/stop.sh
bash .claude/skills/start-backend/scripts/start.sh
```

### Frontend Issues
```bash
# Check frontend status
bash .claude/skills/start-frontend/scripts/check.sh

# Rebuild dependencies
cd phase-2-nextjs/frontend
rm -rf node_modules .next
npm install
```

### Test Failures
```bash
# Run with verbose output
bash .claude/skills/run-tests/scripts/run.sh backend -v

# Check coverage report
bash .claude/skills/run-tests/scripts/run.sh backend --coverage
# Open htmlcov/index.html in browser
```

## Skill Development

To create new skills for this project:

1. Create skill directory: `.claude/skills/<skill-name>/`
2. Add SKILL.md with front matter and documentation
3. Create scripts in `scripts/` subdirectory
4. Make scripts executable: `chmod +x scripts/*.sh`
5. Update this README with the new skill

### Skill Template Structure
```
.claude/skills/<skill-name>/
├── SKILL.md              # Documentation with front matter
├── scripts/
│   ├── main.sh          # Primary script
│   ├── helper.sh        # Helper scripts
│   └── utils.sh         # Utilities
└── references/          # Additional documentation (optional)
    └── api.md
```

## Version History

- **v1.1.0** (2025-12-25): Added AI Integration
  - ai-integration (OpenAI + MCP)

- **v1.0.0** (2025-12-25): Initial skill set
  - start-backend
  - start-frontend
  - run-tests
  - setup-phase
  - verify-setup

## Contributing

When adding new skills:
1. Follow existing patterns and structure
2. Include comprehensive documentation
3. Add color-coded output for better UX
4. Support both Phase 2 and Phase 3
5. Integrate with .specify/ framework
6. Test on both Unix and Windows (Git Bash)
