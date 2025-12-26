---
name: start-backend
description: Start the FastAPI backend server for the to-do application. Supports both Phase 2 (Next.js) and Phase 3 (Chatbot) backends. Automatically detects the phase and starts the appropriate server.
---

# Start Backend Server

Start the FastAPI backend server for development.

## Quick Start

```bash
# Start Phase 2 backend (default)
bash .claude/skills/start-backend/scripts/start.sh

# Start Phase 3 backend
bash .claude/skills/start-backend/scripts/start.sh phase-3

# Check if backend is running
bash .claude/skills/start-backend/scripts/check.sh
```

## What It Does

1. Detects the requested phase (defaults to Phase 2)
2. Activates the Python virtual environment
3. Installs/updates dependencies if needed
4. Starts the FastAPI server with hot reload
5. Displays server URL and status

## Phases

### Phase 2 (Next.js Full-Stack)
- **Directory**: `phase-2-nextjs/backend/`
- **Port**: 8000
- **Features**: Task CRUD, User authentication, JWT tokens

### Phase 3 (AI Chatbot)
- **Directory**: `phase-3-chatbot/backend/`
- **Port**: 8001
- **Features**: All Phase 2 features + AI chatbot, MCP server

## Environment Variables

The backend requires a `.env` file in the backend directory:

```env
# Database
DATABASE_URL=sqlite:///./database.db

# Authentication
JWT_SECRET_KEY=your-secret-key-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Phase 3 only
OPENAI_API_KEY=your-openai-key-here
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port already in use | Check for running backend: `lsof -i :8000` or `lsof -i :8001` |
| Import errors | Reinstall dependencies: `pip install -r requirements.txt` |
| Database errors | Check DATABASE_URL in .env |
| Missing .env | Copy .env.example to .env and fill in values |

## Integration with .specify/

This skill integrates with the SDD workflow:
- Used during **red** phase to start server for testing
- Used during **green** phase for implementation verification
- Referenced in `specs/<feature>/tasks.md` for development tasks

## Stop Server

Press `Ctrl+C` in the terminal where the server is running.

Or use the companion stop script:
```bash
bash .claude/skills/start-backend/scripts/stop.sh
```
