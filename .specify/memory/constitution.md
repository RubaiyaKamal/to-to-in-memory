# Evolution of Todo Constitution

## Core Principles

### I. Spec-Driven Development (NON-NEGOTIABLE)

**All development must be specification-driven:**
- Every feature starts with a complete specification in `specs/<feature>/spec.md`
- Specifications must be refined and approved before implementation begins
- No code generation without a corresponding specification
- Specifications include user scenarios, requirements, success criteria, and dependencies
- Manual code editing by developers is forbidden; all code must be generated from specifications

**Specification Quality Standards:**
- Clear, testable acceptance criteria for every user scenario
- Explicit error paths and edge cases documented
- Dependencies and out-of-scope items clearly stated
- Success criteria must be measurable and verifiable

### II. Phased Evolution Architecture

**The project evolves through five distinct phases:**

1. **Phase I: In-Memory Console Application**
   - Simple Python console app with in-memory storage
   - CRUD operations via command-line interface
   - No external dependencies or databases
   - Focus: Core business logic and TDD foundations

2. **Phase II: Full-Stack Web Application**
   - Next.js frontend with TypeScript and Tailwind CSS
   - FastAPI backend with SQLModel ORM
   - Neon Serverless PostgreSQL database
   - Better Auth with JWT authentication
   - User isolation and multi-user support
   - Focus: Modern web stack and authentication

3. **Phase III: AI-Powered Chatbot**
   - OpenAI Agents SDK integration
   - Model Context Protocol (MCP) stateless tools
   - Stateless chat endpoint with database conversation state
   - ChatKit UI components
   - Natural language task management
   - Focus: Conversational AI and stateless design

4. **Phase IV: Local Kubernetes Deployment**
   - Docker containerization for frontend and backend
   - Kubernetes orchestration with Minikube
   - Helm charts for package management
   - AI-assisted DevOps (kubectl-ai, Kagent, Gordon)
   - Persistent volumes and health checks
   - Focus: Cloud-native patterns and local development

5. **Phase V: Production Cloud Deployment**
   - DigitalOcean Kubernetes Service (DOKS)
   - Kafka on Redpanda Cloud for event-driven architecture
   - Dapr runtime (Pub/Sub, State, Bindings, Secrets, Service Invocation)
   - GitHub Actions CI/CD pipeline
   - Production monitoring and observability
   - Focus: Production-ready cloud architecture

**Phase Constraints:**
- Each phase builds on the previous phase's functionality
- Phase transitions must not break existing features
- All phases must maintain test coverage and documentation
- Phase-specific constraints must be documented in specifications

### III. Test-First Development (NON-NEGOTIABLE)

**TDD cycle is mandatory for all code:**
- **Backend**: pytest with >90% code coverage required
- **Frontend**: Jest/Vitest with >80% code coverage required
- **E2E Tests**: Playwright for critical user flows
- **Red-Green-Refactor**: Tests written first, approved by user, then implemented

**Testing Standards:**
- Unit tests for business logic and utilities
- Integration tests for API endpoints and database operations
- Component tests for React components
- E2E tests for complete user workflows
- All tests must be independent and reproducible
- Mocking external dependencies (OpenAI API, databases in unit tests)

### IV. Security-First Approach

**Security is non-negotiable at every phase:**

**Authentication & Authorization:**
- Phase II+: JWT-based authentication with Better Auth
- Phase II+: User isolation - users only access their own data
- Phase III+: Stateless chat endpoints with user context verification
- Phase IV+: Kubernetes secrets for sensitive configuration
- Phase V: Dapr secrets management with cloud secret stores

**Data Security:**
- Passwords hashed with bcrypt (never stored plain-text)
- JWT tokens signed with `BETTER_AUTH_SECRET`
- Database connection strings in environment variables only
- Never commit secrets or API keys to version control
- SQL injection prevented by SQLModel ORM parameterized queries

**API Security:**
- CORS restricted to allowed origins
- Input validation on all API endpoints (Pydantic models)
- User_id verification in JWT claims matches route parameters
- Rate limiting for production deployments (Phase V)

### V. Type Safety & Modern Tooling

**Type safety across the stack:**
- **Backend**: Python with Pydantic models and SQLModel
- **Frontend**: TypeScript with strict mode enabled
- **API Contracts**: OpenAPI/Swagger auto-generated from FastAPI
- **Validation**: Zod schemas on frontend, Pydantic on backend

**Development Tools:**
- **Frontend**: Next.js 16+ (App Router), Vite, Tailwind CSS
- **Backend**: FastAPI, SQLModel, Uvicorn
- **AI**: OpenAI Agents SDK, Model Context Protocol (MCP)
- **DevOps**: Docker, Kubernetes, Helm, kubectl-ai, Kagent
- **Testing**: pytest, Vitest, Playwright
- **CI/CD**: GitHub Actions (Phase V)

### VI. AI Integration Principles

**AI-powered features must follow specific patterns:**

**Phase III (Chatbot):**
- **Stateless Tools**: MCP tools must be stateless, no in-memory state
- **Database State**: All conversation state persisted in database
- **Function Calling**: OpenAI function calling for task operations
- **Conversation Context**: Each request includes full conversation history from database
- **Error Handling**: Graceful fallbacks when AI services unavailable

**Phase IV+ (DevOps AI):**
- **kubectl-ai**: Natural language Kubernetes operations
- **Kagent**: Cluster analysis and optimization
- **Gordon (Docker AI)**: AI-assisted Docker operations
- **Optional Enhancement**: All AI tools are optional; standard CLI commands must work

### VII. Cloud-Native & Event-Driven (Phase V)

**Production architecture follows cloud-native principles:**

**Event-Driven Architecture:**
- Kafka on Redpanda Cloud for event streaming
- Pydantic schemas for event definitions
- Event sourcing patterns for audit logs
- Dapr Pub/Sub for service decoupling

**Dapr Runtime:**
- **Pub/Sub**: Kafka integration for events
- **State Store**: PostgreSQL for distributed state
- **Bindings**: External system integration (email, notifications)
- **Secrets**: Kubernetes secrets management
- **Service Invocation**: Service-to-service communication

**Observability:**
- Structured logging with correlation IDs
- Prometheus metrics for monitoring
- Grafana dashboards for visualization
- Distributed tracing for debugging

## Development Workflow

### Specification Workflow

1. **User Request** → Capture requirements in natural language
2. **Specification Creation** → Generate `specs/<feature>/spec.md` with:
   - User scenarios and acceptance criteria
   - Requirements (functional and non-functional)
   - Success criteria (measurable outcomes)
   - Dependencies and out-of-scope items
3. **Specification Refinement** → Run `/sp.clarify` to identify ambiguities
4. **User Approval** → Specification must be approved before proceeding
5. **Planning** → Generate `specs/<feature>/plan.md` with architecture decisions
6. **Task Breakdown** → Generate `specs/<feature>/tasks.md` with testable tasks
7. **Implementation** → Generate code from tasks using `/sp.implement`
8. **Testing** → Run comprehensive test suites (`/run-tests`)
9. **Review & Merge** → Create PR and merge after approval

### Code Generation Workflow

**NEVER write code manually. Always follow this flow:**

1. **Read Specification** → Understand requirements from spec.md
2. **Read Plan** → Understand architecture decisions from plan.md
3. **Read Tasks** → Understand implementation tasks from tasks.md
4. **Generate Tests First** → Create test files based on acceptance criteria
5. **User Approval** → User approves tests before implementation
6. **Generate Implementation** → Generate code to pass tests
7. **Verify Tests Pass** → Run test suite and verify all tests pass
8. **Generate Documentation** → Update README and API docs

### Architecture Decision Records (ADR)

**When to create ADRs:**
- Significant architectural decisions during planning
- Framework or library selection
- Data model or schema changes
- API contract changes
- Security or authentication patterns
- Platform or infrastructure choices

**ADR Three-Part Test (ALL must be true):**
1. **Impact**: Long-term consequences affecting system design
2. **Alternatives**: Multiple viable options were considered
3. **Scope**: Cross-cutting concerns influencing architecture

**ADR Process:**
- AI suggests ADR: "📋 Architectural decision detected: [brief]. Document? Run `/sp.adr [title]`"
- User consents before ADR creation
- ADR created in `history/adr/` with decision context, options, and rationale

## Quality Standards

### Code Quality

- **Readability**: Clear variable names, minimal comments (self-documenting code)
- **Simplicity**: YAGNI (You Aren't Gonna Need It) - implement only what's specified
- **DRY**: Don't Repeat Yourself - extract common patterns
- **SOLID**: Follow SOLID principles for object-oriented code
- **Error Handling**: Explicit error handling with meaningful messages
- **Logging**: Structured logging for debugging and monitoring

### Performance Standards

- **Backend API**: p95 latency < 200ms for CRUD operations
- **Frontend**: First Contentful Paint < 1.5s
- **Database**: Query optimization with indexes for common queries
- **Caching**: Strategic caching for expensive operations (Phase V)
- **Resource Limits**: Kubernetes resource requests and limits defined

### Documentation Standards

- **README Files**: Every phase has comprehensive README with setup instructions
- **API Documentation**: Auto-generated Swagger UI from FastAPI
- **Code Comments**: Only where logic isn't self-evident
- **Architecture Diagrams**: Mermaid diagrams for complex flows
- **Deployment Guides**: Step-by-step deployment instructions

## Technology Constraints

### Language & Framework Lock-In

- **Backend**: Python 3.11+ with FastAPI (non-negotiable)
- **Frontend**: Next.js 16+ with TypeScript (non-negotiable)
- **Database**: PostgreSQL-compatible (Neon in dev, PostgreSQL in prod)
- **AI**: OpenAI Agents SDK with GPT-4 (non-negotiable for Phase III+)
- **Container**: Docker and Kubernetes (non-negotiable for Phase IV+)

### Third-Party Service Constraints

- **Phase I-II**: Neon Serverless PostgreSQL
- **Phase III**: OpenAI API (GPT-4)
- **Phase IV**: Local development only (Minikube)
- **Phase V**: DOKS, Redpanda Cloud (Kafka), Dapr runtime

### Browser & Compatibility

- **Modern Browsers**: Chrome, Firefox, Safari, Edge (latest 2 versions)
- **Mobile**: Responsive design, touch-friendly
- **Accessibility**: WCAG 2.1 Level AA compliance

## Non-Functional Requirements

### Reliability

- **Uptime**: 99.9% uptime target for Phase V production
- **Error Recovery**: Graceful degradation when services unavailable
- **Data Integrity**: ACID transactions for critical operations
- **Backup**: Database backups in Phase V production

### Scalability

- **Phase II**: Handles 100s of concurrent users
- **Phase V**: Horizontal scaling for 1000s of concurrent users
- **Database**: Connection pooling and query optimization
- **Event Processing**: Kafka for high-throughput event streams

### Maintainability

- **Modular Design**: Clear separation between layers
- **Versioning**: Semantic versioning (MAJOR.MINOR.PATCH)
- **Migration**: Database migrations with Alembic
- **Configuration**: Environment-based configuration (dev, staging, prod)

## Governance

### Constitution Authority

- This constitution supersedes all other development practices
- All PRs and code reviews must verify compliance with constitution
- Amendments require documentation, approval, and migration plan
- Complexity must be justified against simplicity principle

### Specification Authority

- Specifications are the source of truth for requirements
- Code must match specifications exactly
- Specification changes require version updates
- Out-of-scope items must be documented in future phases

### Review Process

- All generated code must be reviewed against specification
- Test coverage requirements must be met before merge
- Security review required for authentication/authorization changes
- Performance testing required for Phase V production deployment

### Prompt History Records (PHR)

- Every user interaction must generate a PHR
- PHRs stored in `history/prompts/` organized by feature
- PHRs capture: prompt, response, stage, files, tests, outcomes
- PHRs enable learning and traceability

**Version**: 1.0.0 | **Ratified**: 2025-12-30 | **Last Amended**: 2025-12-30
