# Phase 3: AI-Powered Chatbot - Quick Start Guide

## Overview

Phase 3 is **fully implemented** with:
- ✅ MCP Server with 6 tools (add, list, complete, update, delete, clear tasks)
- ✅ OpenAI GPT-4 integration with function calling
- ✅ Stateless chat endpoint with database-backed conversation state
- ✅ React/Vite frontend with bilingual support (English/Urdu)
- ✅ Voice input capability
- ✅ User isolation and conversation persistence

## Quick Start

### 1. Setup Backend

```bash
cd phase-3-chatbot/backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Verify OpenAI API key is set in .env
cat .env | grep OPENAI_API_KEY
```

### 2. Start Backend Server

```bash
# From phase-3-chatbot/backend with venv activated
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

Backend will be available at: `http://localhost:8001`

### 3. Setup Frontend

```bash
cd phase-3-chatbot/frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

Frontend will be available at: `http://localhost:5173`

## Using Skills (Recommended)

Use the project skills for easier management:

```bash
# Setup Phase 3 environment
bash .claude/skills/setup-phase/scripts/setup.sh phase-3

# Verify configuration
bash .claude/skills/verify-setup/scripts/verify.sh phase-3

# Verify OpenAI API key
bash .claude/skills/ai-integration/scripts/verify-openai.sh

# Start backend
bash .claude/skills/start-backend/scripts/start.sh phase-3

# In another terminal, start frontend
bash .claude/skills/start-frontend/scripts/start.sh phase-3
```

## Architecture

### Backend (`phase-3-chatbot/backend/`)

**Key Files:**
- `main.py` - FastAPI application with chat endpoint
- `agent.py` - OpenAI agent with MCP client integration
- `mcp_server.py` - MCP server with 6 task management tools
- `models.py` - SQLModel definitions (Task, Conversation, Message)
- `database.py` - Database configuration (SQLite)
- `.env` - Environment variables (OPENAI_API_KEY)

**MCP Tools:**
1. `add_task` - Create new task with priority, due date, category
2. `list_tasks` - List tasks with status filter (all/pending/completed)
3. `complete_task` - Mark task as complete
4. `update_task` - Update task details
5. `delete_task` - Delete specific task
6. `clear_tasks` - Delete all tasks for user

### Frontend (`phase-3-chatbot/frontend/`)

**Key Files:**
- `src/components/Chat.tsx` - Main chat interface
- `src/components/AddTaskForm.tsx` - Task creation form
- `src/components/VoiceInput.tsx` - Voice input component
- `src/lib/api.ts` - API client functions
- `src/lib/translations.ts` - English/Urdu translations

**Features:**
- Quick action buttons (Add, View, Update, Delete, Complete)
- Voice input for hands-free interaction
- Bilingual support (English ↔ Urdu)
- Responsive design with Tailwind CSS
- Conversation history persistence

## API Endpoints

### Chat Endpoint
```
POST /api/{user_id}/chat
```

**Request:**
```json
{
  "message": "Add a task: Buy groceries",
  "conversation_id": null,  // Optional, for continuing conversation
  "language": "en"  // "en" or "ur"
}
```

**Response:**
```json
{
  "conversation_id": 1,
  "response": "✓ Task added successfully!\n\n📋 Buy groceries\n🟡 Medium priority\n👤 @general\n\n[🏠 Back to Main Menu]",
  "tool_calls": [
    {
      "name": "add_task",
      "args": {
        "user_id": "user123",
        "title": "Buy groceries"
      }
    }
  ]
}
```

### Health Check
```
GET /api/health
```

## Environment Variables

**Backend `.env`:**
```env
OPENAI_API_KEY=sk-...your-key-here...
DATABASE_URL=sqlite:///./database_v2.db  # Optional, defaults to SQLite
```

**Frontend `.env` (if needed):**
```env
VITE_API_URL=http://localhost:8001
```

## Example Conversations

### Adding a Task
```
User: "Add a task: Buy milk"
Assistant: "✓ Task added successfully!
📋 Buy milk
🟡 Medium priority
👤 @general
[🏠 Back to Main Menu]"
```

### Listing Tasks
```
User: "Show my tasks"
Assistant: "[1] Buy milk
Due: None | Priority: Medium
Status: ( ) Pending

[2] Call mom
Due: 2025-12-26 | Priority: High
Status: (X) Completed

[🏠 Back to Main Menu]"
```

### Completing a Task
```
User: "Complete task 1"
Assistant: "✓ Marked 'Buy milk' as completed. Great job!
[🏠 Back to Main Menu]"
```

### Multi-turn with Context
```
User: "Show my pending tasks"
Assistant: "[Lists pending tasks]
[🏠 Back to Main Menu]"

User: "Complete the first one"
Assistant: "✓ Task completed successfully!
[🏠 Back to Main Menu]"
```

## Testing

### Test MCP Tools Directly

```bash
# Navigate to skills directory
bash .claude/skills/ai-integration/scripts/test-mcp-tools.sh
```

### Test Chat Endpoint

```bash
# Start backend first, then:
bash .claude/skills/ai-integration/scripts/test-chat.sh
```

### Manual cURL Test

```bash
curl -X POST http://localhost:8001/api/testuser/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Add a task: Buy groceries",
    "language": "en"
  }'
```

## Troubleshooting

### OpenAI API Errors
```bash
# Check API key configuration
bash .claude/skills/ai-integration/scripts/verify-openai.sh

# Verify key in .env
cat phase-3-chatbot/backend/.env | grep OPENAI_API_KEY
```

### MCP Server Issues
```bash
# Test MCP tools
cd phase-3-chatbot/backend
source venv/bin/activate
python mcp_server.py  # Should list available tools
```

### Database Issues
```bash
# Check if database exists
ls -la phase-3-chatbot/backend/database_v2.db

# Recreate if needed
cd phase-3-chatbot/backend
source venv/bin/activate
python -c "from database import create_db_and_tables; create_db_and_tables()"
```

### Frontend Connection Issues
```bash
# Check backend is running
curl http://localhost:8001/api/health

# Check CORS configuration in main.py
# Verify frontend origin is in allow_origins
```

## Features

### Bilingual Support
- Switch between English and Urdu with language toggle button
- All UI elements and responses translated
- Persists language preference in localStorage

### Voice Input
- Click microphone icon to speak
- Automatic speech-to-text conversion
- Supports multiple languages

### Conversation Persistence
- All conversations stored in database
- Users can resume previous conversations
- Full conversation history maintained

### User Isolation
- Each user has isolated task list
- User ID tracked in URL and localStorage
- MCP tools enforce user ownership validation

## Architecture Highlights

### Stateless Design
- No server-side session state
- All state in database (SQLite)
- Each request is independent
- Conversation history loaded from DB per request

### Security
- User ID validation on all MCP tool calls
- Database-level user isolation
- CORS configured for frontend origins
- No hardcoded credentials

### Scalability
- Stateless design allows horizontal scaling
- Database can be switched to PostgreSQL
- MCP server runs as subprocess per request
- Can be containerized easily

## Next Steps

1. **Production Deployment**: Switch to PostgreSQL, add authentication
2. **Advanced Features**: Task priorities, recurring tasks, reminders
3. **UI Enhancements**: Drag-and-drop, calendar view, task categories
4. **Analytics**: Track conversation metrics, user engagement
5. **Voice Improvements**: Better speech recognition, voice output

## Support

For issues or questions:
- Check `phase-3-chatbot/backend/main.py` for endpoint definitions
- Review `phase-3-chatbot/backend/agent.py` for agent logic
- Inspect `phase-3-chatbot/backend/mcp_server.py` for tool implementations
- See `.claude/skills/ai-integration/SKILL.md` for detailed MCP documentation

## Status: ✅ READY TO USE

Phase 3 chatbot is fully implemented and ready for use! Just start the backend and frontend servers.
