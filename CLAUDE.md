# Todo App - Hackathon Phase II

## Project Overview
This is a **monorepo** using **GitHub Spec-Kit Plus** for spec-driven development. The project transforms a console Todo app into a full-stack web application with Next.js frontend, FastAPI backend, and Neon PostgreSQL database.

## Current Phase
**Phase II: Full-Stack Web Application** with Better Auth authentication and JWT tokens.

## Spec-Kit Plus Structure
Specifications are organized in `/specs` following Spec-Kit conventions:

- **`/specs/overview.md`** - Project overview, tech stack, feature roadmap
- **`/specs/architecture.md`** - System architecture, data flow, security
- **`/specs/features/`** - Feature specifications (what to build)
  - `task-crud.md` - Task CRUD operations
  - `authentication.md` - Better Auth integration
- **`/specs/api/`** - API endpoint specifications
  - `rest-endpoints.md` - All REST API endpoints with JWT
- **`/specs/database/`** - Database schema and models
  - `schema.md` - PostgreSQL schema, SQLModel models
- **`/specs/ui/`** - UI component and page specifications
  - `components.md` - React component hierarchy
  - `pages.md` - Next.js App Router pages

## How to Use Specs
1. **Always read relevant spec before implementing**
2. **Reference specs with**: `@specs/features/task-crud.md`
3. **Update specs if requirements change**
4. **Follow Spec-Kit conventions** defined in `.spec-kit/config.yaml`

## Project Structure

```
to-do-in-memory/
├── .spec-kit/              # Spec-Kit Plus configuration
│   └── config.yaml
├── specs/                  # Organized specifications
│   ├── overview.md
│   ├── architecture.md
│   ├── features/
│   ├── api/
│   ├── database/
│   └── ui/
├── frontend/               # Next.js 16+ application
│   ├── CLAUDE.md          # Frontend-specific guidelines
│   ├── app/               # App Router pages
│   ├── components/        # React components
│   ├── lib/               # Utilities and API client
│   └── package.json
├── backend/                # FastAPI application
│   ├── CLAUDE.md          # Backend-specific guidelines
│   ├── main.py            # FastAPI entry point
│   ├── models.py          # SQLModel models
│   ├── routes/            # API route handlers
│   └── pyproject.toml
├── legacy/                 # Phase I console app (archived)
├── docker-compose.yml      # Local development setup
├── CLAUDE.md              # This file (monorepo navigation)
└── README.md
```

## Development Workflow

### 1. Read Spec
Start by reading the relevant specification:
```
@specs/features/task-crud.md
@specs/api/rest-endpoints.md
@specs/database/schema.md
```

### 2. Implement Backend
Navigate to backend and follow backend guidelines:
```
@backend/CLAUDE.md
```

### 3. Implement Frontend
Navigate to frontend and follow frontend guidelines:
```
@frontend/CLAUDE.md
```

### 4. Test and Iterate
- Test backend API endpoints
- Test frontend UI
- Verify integration
- Update specs if needed

## Technology Stack

### Frontend
- **Framework**: Next.js 16+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Authentication**: Better Auth with JWT
- **API Client**: Fetch API with JWT headers

### Backend
- **Framework**: FastAPI
- **ORM**: SQLModel
- **Database**: Neon Serverless PostgreSQL
- **Authentication**: JWT token verification
- **Server**: Uvicorn (ASGI)

### Development
- **Monorepo**: Single repository
- **Spec-Driven**: GitHub Spec-Kit Plus
- **Containerization**: Docker Compose
- **Package Managers**: npm (frontend), UV (backend)

## Quick Commands

### Frontend
```bash
cd frontend
npm install
npm run dev          # Start dev server (port 3000)
npm run build        # Build for production
npm run type-check   # TypeScript type checking
```

### Backend
```bash
cd backend
uv sync --dev                              # Install dependencies
uv run uvicorn main:app --reload           # Start dev server (port 8000)
uv run pytest -v --cov                     # Run tests
uv run mypy .                              # Type checking
```

### Docker (Both Services)
```bash
docker-compose up --build    # Start both frontend and backend
docker-compose down          # Stop all services
```

## Environment Variables

### Frontend (`.env.local`)
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_AUTH_URL=http://localhost:3000
BETTER_AUTH_SECRET=<shared-secret-key>
```

### Backend (`.env`)
```bash
DATABASE_URL=postgresql://user:pass@host.neon.tech/db?sslmode=require
BETTER_AUTH_SECRET=<same-shared-secret-key>
CORS_ORIGINS=http://localhost:3000
```

## Architectural Principles

1. **Separation of Concerns**: Frontend, backend, and database are clearly separated
2. **API-First**: Backend exposes RESTful API consumed by frontend
3. **Security**: JWT authentication, user isolation, secure password storage
4. **Scalability**: Serverless database, stateless API, containerized services
5. **Developer Experience**: Hot reload, type safety, comprehensive testing
6. **Spec-Driven**: All features defined in specs before implementation

## Authentication Flow

1. User signs up/signs in via Better Auth (frontend)
2. Better Auth generates JWT token with user_id
3. Frontend stores JWT in localStorage
4. Frontend attaches JWT to all API requests (Authorization header)
5. Backend verifies JWT signature and extracts user_id
6. Backend ensures user_id in URL matches token
7. Backend filters all queries by authenticated user_id

## Cross-Cutting Concerns

### Error Handling
- Frontend: Display user-friendly error messages
- Backend: Return structured error responses with HTTP status codes
- Both: Log errors for debugging

### Validation
- Frontend: Client-side validation for UX
- Backend: Server-side validation for security (never trust client)

### Testing
- Frontend: Type checking, build verification
- Backend: Unit tests, integration tests, API tests

## Navigation Between Components

### Working on Features
1. Read feature spec: `@specs/features/[feature].md`
2. Check API spec: `@specs/api/rest-endpoints.md`
3. Check database spec: `@specs/database/schema.md`
4. Implement backend: `@backend/CLAUDE.md`
5. Implement frontend: `@frontend/CLAUDE.md`

### Working on Backend
- See: `@backend/CLAUDE.md` for FastAPI patterns, SQLModel usage, JWT verification

### Working on Frontend
- See: `@frontend/CLAUDE.md` for Next.js patterns, component structure, API client usage

## Spec-Driven Development Rules

1. **Spec First**: Write or update spec before implementing
2. **Reference Specs**: Always reference specs when implementing
3. **Update Specs**: Keep specs in sync with implementation
4. **Follow Structure**: Use Spec-Kit directory structure
5. **Document Decisions**: Use ADRs for architectural decisions (future)

## Phase Progression

- **Phase I** ✅: Console app with in-memory storage
- **Phase II** 🚧: Full-stack web app with PostgreSQL
- **Phase III** 📋: AI chatbot interface (future)

## Getting Help

- **Architecture**: See `@specs/architecture.md`
- **API Endpoints**: See `@specs/api/rest-endpoints.md`
- **Database Schema**: See `@specs/database/schema.md`
- **Frontend Guidelines**: See `@frontend/CLAUDE.md`
- **Backend Guidelines**: See `@backend/CLAUDE.md`

---

**Remember**: This is a monorepo. Claude Code can see and edit both frontend and backend in a single context. Use the layered CLAUDE.md files for component-specific guidance.

## Task context

**Your Surface:** You operate on a project level, providing guidance to users and executing development tasks via a defined set of tools.

**Your Success is Measured By:**
- All outputs strictly follow the user intent.
- Prompt History Records (PHRs) are created automatically and accurately for every user prompt.
- Architectural Decision Record (ADR) suggestions are made intelligently for significant decisions.
- All changes are small, testable, and reference code precisely.

## Core Guarantees (Product Promise)

- Record every user input verbatim in a Prompt History Record (PHR) after every user message. Do not truncate; preserve full multiline input.
- PHR routing (all under `history/prompts/`):
  - Constitution → `history/prompts/constitution/`
  - Feature-specific → `history/prompts/<feature-name>/`
  - General → `history/prompts/general/`
- ADR suggestions: when an architecturally significant decision is detected, suggest: "📋 Architectural decision detected: <brief>. Document? Run `/sp.adr <title>`." Never auto‑create ADRs; require user consent.

## Development Guidelines

### 1. Authoritative Source Mandate:
Agents MUST prioritize and use MCP tools and CLI commands for all information gathering and task execution. NEVER assume a solution from internal knowledge; all methods require external verification.

### 2. Execution Flow:
Treat MCP servers as first-class tools for discovery, verification, execution, and state capture. PREFER CLI interactions (running commands and capturing outputs) over manual file creation or reliance on internal knowledge.

### 3. Knowledge capture (PHR) for Every User Input.
After completing requests, you **MUST** create a PHR (Prompt History Record).

**When to create PHRs:**
- Implementation work (code changes, new features)
- Planning/architecture discussions
- Debugging sessions
- Spec/task/plan creation
- Multi-step workflows

**PHR Creation Process:**

1) Detect stage
   - One of: constitution | spec | plan | tasks | red | green | refactor | explainer | misc | general

2) Generate title
   - 3–7 words; create a slug for the filename.

2a) Resolve route (all under history/prompts/)
  - `constitution` → `history/prompts/constitution/`
  - Feature stages (spec, plan, tasks, red, green, refactor, explainer, misc) → `history/prompts/<feature-name>/` (requires feature context)
  - `general` → `history/prompts/general/`

3) Prefer agent‑native flow (no shell)
   - Read the PHR template from one of:
     - `.specify/templates/phr-template.prompt.md`
     - `templates/phr-template.prompt.md`
   - Allocate an ID (increment; on collision, increment again).
   - Compute output path based on stage:
     - Constitution → `history/prompts/constitution/<ID>-<slug>.constitution.prompt.md`
     - Feature → `history/prompts/<feature-name>/<ID>-<slug>.<stage>.prompt.md`
     - General → `history/prompts/general/<ID>-<slug>.general.prompt.md`
   - Fill ALL placeholders in YAML and body:
     - ID, TITLE, STAGE, DATE_ISO (YYYY‑MM‑DD), SURFACE="agent"
     - MODEL (best known), FEATURE (or "none"), BRANCH, USER
     - COMMAND (current command), LABELS (["topic1","topic2",...])
     - LINKS: SPEC/TICKET/ADR/PR (URLs or "null")
     - FILES_YAML: list created/modified files (one per line, " - ")
     - TESTS_YAML: list tests run/added (one per line, " - ")
     - PROMPT_TEXT: full user input (verbatim, not truncated)
     - RESPONSE_TEXT: key assistant output (concise but representative)
     - Any OUTCOME/EVALUATION fields required by the template
   - Write the completed file with agent file tools (WriteFile/Edit).
   - Confirm absolute path in output.

4) Use sp.phr command file if present
   - If `.**/commands/sp.phr.*` exists, follow its structure.
   - If it references shell but Shell is unavailable, still perform step 3 with agent‑native tools.

5) Shell fallback (only if step 3 is unavailable or fails, and Shell is permitted)
   - Run: `.specify/scripts/bash/create-phr.sh --title "<title>" --stage <stage> [--feature <name>] --json`
   - Then open/patch the created file to ensure all placeholders are filled and prompt/response are embedded.

6) Routing (automatic, all under history/prompts/)
   - Constitution → `history/prompts/constitution/`
   - Feature stages → `history/prompts/<feature-name>/` (auto-detected from branch or explicit feature context)
   - General → `history/prompts/general/`

7) Post‑creation validations (must pass)
   - No unresolved placeholders (e.g., `{{THIS}}`, `[THAT]`).
   - Title, stage, and dates match front‑matter.
   - PROMPT_TEXT is complete (not truncated).
   - File exists at the expected path and is readable.
   - Path matches route.

8) Report
   - Print: ID, path, stage, title.
   - On any failure: warn but do not block the main command.
   - Skip PHR only for `/sp.phr` itself.

### 4. Explicit ADR suggestions
- When significant architectural decisions are made (typically during `/sp.plan` and sometimes `/sp.tasks`), run the three‑part test and suggest documenting with:
  "📋 Architectural decision detected: <brief> — Document reasoning and tradeoffs? Run `/sp.adr <decision-title>`"
- Wait for user consent; never auto‑create the ADR.

### 5. Human as Tool Strategy
You are not expected to solve every problem autonomously. You MUST invoke the user for input when you encounter situations that require human judgment. Treat the user as a specialized tool for clarification and decision-making.

**Invocation Triggers:**
1.  **Ambiguous Requirements:** When user intent is unclear, ask 2-3 targeted clarifying questions before proceeding.
2.  **Unforeseen Dependencies:** When discovering dependencies not mentioned in the spec, surface them and ask for prioritization.
3.  **Architectural Uncertainty:** When multiple valid approaches exist with significant tradeoffs, present options and get user's preference.
4.  **Completion Checkpoint:** After completing major milestones, summarize what was done and confirm next steps.

## Default policies (must follow)
- Clarify and plan first - keep business understanding separate from technical plan and carefully architect and implement.
- Do not invent APIs, data, or contracts; ask targeted clarifiers if missing.
- Never hardcode secrets or tokens; use `.env` and docs.
- Prefer the smallest viable diff; do not refactor unrelated code.
- Cite existing code with code references (start:end:path); propose new code in fenced blocks.
- Keep reasoning private; output only decisions, artifacts, and justifications.

### Execution contract for every request
1) Confirm surface and success criteria (one sentence).
2) List constraints, invariants, non‑goals.
3) Produce the artifact with acceptance checks inlined (checkboxes or tests where applicable).
4) Add follow‑ups and risks (max 3 bullets).
5) Create PHR in appropriate subdirectory under `history/prompts/` (constitution, feature-name, or general).
6) If plan/tasks identified decisions that meet significance, surface ADR suggestion text as described above.

### Minimum acceptance criteria
- Clear, testable acceptance criteria included
- Explicit error paths and constraints stated
- Smallest viable change; no unrelated edits
- Code references to modified/inspected files where relevant

## Architect Guidelines (for planning)

Instructions: As an expert architect, generate a detailed architectural plan for [Project Name]. Address each of the following thoroughly.

1. Scope and Dependencies:
   - In Scope: boundaries and key features.
   - Out of Scope: explicitly excluded items.
   - External Dependencies: systems/services/teams and ownership.

2. Key Decisions and Rationale:
   - Options Considered, Trade-offs, Rationale.
   - Principles: measurable, reversible where possible, smallest viable change.

3. Interfaces and API Contracts:
   - Public APIs: Inputs, Outputs, Errors.
   - Versioning Strategy.
   - Idempotency, Timeouts, Retries.
   - Error Taxonomy with status codes.

4. Non-Functional Requirements (NFRs) and Budgets:
   - Performance: p95 latency, throughput, resource caps.
   - Reliability: SLOs, error budgets, degradation strategy.
   - Security: AuthN/AuthZ, data handling, secrets, auditing.
   - Cost: unit economics.

5. Data Management and Migration:
   - Source of Truth, Schema Evolution, Migration and Rollback, Data Retention.

6. Operational Readiness:
   - Observability: logs, metrics, traces.
   - Alerting: thresholds and on-call owners.
   - Runbooks for common tasks.
   - Deployment and Rollback strategies.
   - Feature Flags and compatibility.

7. Risk Analysis and Mitigation:
   - Top 3 Risks, blast radius, kill switches/guardrails.

8. Evaluation and Validation:
   - Definition of Done (tests, scans).
   - Output Validation for format/requirements/safety.

9. Architectural Decision Record (ADR):
   - For each significant decision, create an ADR and link it.

### Architecture Decision Records (ADR) - Intelligent Suggestion

After design/architecture work, test for ADR significance:

- Impact: long-term consequences? (e.g., framework, data model, API, security, platform)
- Alternatives: multiple viable options considered?
- Scope: cross‑cutting and influences system design?

If ALL true, suggest:
📋 Architectural decision detected: [brief-description]
   Document reasoning and tradeoffs? Run `/sp.adr [decision-title]`

Wait for consent; never auto-create ADRs. Group related decisions (stacks, authentication, deployment) into one ADR when appropriate.

## Basic Project Structure

- `.specify/memory/constitution.md` — Project principles
- `specs/<feature>/spec.md` — Feature requirements
- `specs/<feature>/plan.md` — Architecture decisions
- `specs/<feature>/tasks.md` — Testable tasks with cases
- `history/prompts/` — Prompt History Records
- `history/adr/` — Architecture Decision Records
- `.specify/` — SpecKit Plus templates and scripts

## Code Standards
See `.specify/memory/constitution.md` for code quality, testing, performance, security, and architecture principles.
