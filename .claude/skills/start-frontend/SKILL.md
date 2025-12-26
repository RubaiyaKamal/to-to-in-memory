---
name: start-frontend
description: Start the Next.js frontend application for the to-do app. Supports both Phase 2 (Full-Stack) and Phase 3 (Chatbot) frontends with hot reload for development.
---

# Start Frontend Application

Start the Next.js frontend application for development.

## Quick Start

```bash
# Start Phase 2 frontend (default)
bash .claude/skills/start-frontend/scripts/start.sh

# Start Phase 3 frontend
bash .claude/skills/start-frontend/scripts/start.sh phase-3

# Check if frontend is running
bash .claude/skills/start-frontend/scripts/check.sh
```

## What It Does

1. Detects the requested phase (defaults to Phase 2)
2. Installs/updates npm dependencies
3. Checks for required environment variables
4. Starts Next.js dev server with hot reload
5. Opens browser automatically (optional)

## Phases

### Phase 2 (Next.js Full-Stack)
- **Directory**: `phase-2-nextjs/frontend/`
- **Port**: 3000
- **Features**: Task management UI, authentication, responsive design

### Phase 3 (AI Chatbot)
- **Directory**: `phase-3-chatbot/frontend/`
- **Port**: 3001
- **Features**: All Phase 2 features + AI chatbot interface, voice input

## Environment Variables

The frontend requires a `.env.local` file in the frontend directory:

### Phase 2
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### Phase 3
```env
NEXT_PUBLIC_API_URL=http://localhost:8001
NEXT_PUBLIC_CHAT_ENABLED=true
```

## Development Features

- **Hot Reload**: Code changes automatically refresh the browser
- **Fast Refresh**: React components update without full page reload
- **Type Checking**: TypeScript compilation runs in the background
- **Linting**: ESLint checks run automatically

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port already in use | Change port: `PORT=3002 bash start.sh` |
| Module not found | Delete node_modules and run: `npm install` |
| Build errors | Check TypeScript errors: `npm run type-check` |
| API connection failed | Ensure backend is running (use start-backend skill) |

## Integration with .specify/

This skill integrates with the SDD workflow:
- Used during **red** phase for UI testing
- Used during **green** phase for feature implementation
- Referenced in `specs/<feature>/tasks.md` for UI tasks

## Stop Server

Press `Ctrl+C` in the terminal where the server is running.

Or use the companion stop script:
```bash
bash .claude/skills/start-frontend/scripts/stop.sh
```

## Build for Production

```bash
bash .claude/skills/start-frontend/scripts/build.sh
```

This creates an optimized production build in the `.next` directory.
