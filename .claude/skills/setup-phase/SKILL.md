---
name: setup-phase
description: Set up development environment for a specific phase of the to-do application. Installs dependencies, creates configuration files, and initializes databases. Perfect for onboarding or switching between phases.
---

# Setup Phase Environment

Complete environment setup for a specific phase of the to-do application.

## Quick Start

```bash
# Setup Phase 2 (Next.js Full-Stack)
bash .claude/skills/setup-phase/scripts/setup.sh phase-2

# Setup Phase 3 (AI Chatbot)
bash .claude/skills/setup-phase/scripts/setup.sh phase-3

# Setup both phases
bash .claude/skills/setup-phase/scripts/setup.sh all
```

## What It Does

1. **Checks Prerequisites**: Python 3.9+, Node.js 18+, npm
2. **Creates Virtual Environment**: Python venv for backend
3. **Installs Backend Dependencies**: FastAPI, SQLAlchemy, pytest, etc.
4. **Installs Frontend Dependencies**: Next.js, React, TypeScript, etc.
5. **Creates Configuration Files**: .env, .env.local from examples
6. **Initializes Database**: Creates SQLite database with schema
7. **Verifies Setup**: Runs health checks on all components

## Phases

### Phase 2 (Next.js Full-Stack)
Sets up:
- FastAPI backend with SQLModel and JWT authentication
- Next.js frontend with TypeScript and Tailwind CSS
- SQLite database with user and task tables
- Environment variables for development

### Phase 3 (AI Chatbot)
Sets up:
- All Phase 2 components
- OpenAI integration for AI chatbot
- MCP server for AI tool calling
- Additional frontend components for chat UI

## Prerequisites

Before running setup, ensure you have:
- Python 3.9 or higher
- Node.js 18 or higher
- npm or yarn
- Git (for version control)

## Environment Variables

### Phase 2 Backend (.env)
```env
DATABASE_URL=sqlite:///./database.db
JWT_SECRET_KEY=your-secret-key-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Phase 2 Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### Phase 3 Additional (.env)
```env
OPENAI_API_KEY=your-openai-api-key
```

## Post-Setup Verification

After setup completes, verify with:
```bash
bash .claude/skills/verify-setup/scripts/verify.sh
```

## Integration with .specify/

This skill:
- Uses constitution from `.specify/memory/constitution.md`
- Follows setup patterns from `.specify/scripts/bash/`
- Integrates with SDD workflow for new feature development

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Python not found | Install Python 3.9+ from python.org |
| Node not found | Install Node.js 18+ from nodejs.org |
| Permission denied | Run with appropriate permissions or use sudo (Linux/Mac) |
| Virtual env failed | Delete existing venv and retry |
| npm install fails | Clear npm cache: `npm cache clean --force` |

## Manual Setup Steps

If automated setup fails, follow these manual steps:

### Backend Setup
```bash
cd phase-2-nextjs/backend
python3 -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your configuration
```

### Frontend Setup
```bash
cd phase-2-nextjs/frontend
npm install
cp .env.example .env.local
# Edit .env.local with your configuration
```

### Database Initialization
```bash
cd phase-2-nextjs/backend
source venv/bin/activate
python -c "from db import init_db; init_db()"
```
