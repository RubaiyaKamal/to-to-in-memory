---
name: ai-integration
description: Integrate OpenAI Agents SDK and MCP (Model Context Protocol) servers for conversational AI capabilities. Build stateless chat endpoints with database-backed conversation state for the Evolution of Todo project.
---

# AI Integration Specialist

Build conversational AI capabilities using OpenAI Agents SDK and MCP servers.

## Quick Start

```bash
# 1. Verify OpenAI API key configuration
bash .claude/skills/ai-integration/scripts/verify-openai.sh

# 2. Test MCP tools
bash .claude/skills/ai-integration/scripts/test-mcp-tools.sh

# 3. Start MCP server (if standalone mode)
bash .claude/skills/ai-integration/scripts/start-mcp-server.sh

# 4. Test chat endpoint
bash .claude/skills/ai-integration/scripts/test-chat.sh
```

## Core Capabilities

### 1. MCP Server Architecture (Stateless)

**Critical Principle:** MCP server MUST be stateless. All state stored in database.

#### Key Features
- ✅ Stateless tool execution
- ✅ Database-backed state management
- ✅ User isolation enforced
- ✅ Structured error handling
- ✅ Type-safe with Pydantic

#### MCP Tools (5 Required)

| Tool | Purpose | Parameters |
|------|---------|------------|
| `add_task` | Create new task | user_id, title, description? |
| `list_tasks` | List tasks with filters | user_id, status?, limit? |
| `complete_task` | Toggle task completion | user_id, task_id |
| `update_task` | Update task details | user_id, task_id, title?, description? |
| `delete_task` | Delete task permanently | user_id, task_id |

### 2. OpenAI Agent Configuration

- **Model**: GPT-4 Turbo Preview
- **Function Calling**: Enabled for all MCP tools
- **System Prompt**: Friendly, conversational todo assistant
- **Context**: Full conversation history from database

### 3. Stateless Chat Endpoint

**Flow:**
1. Get/create conversation (database)
2. Load conversation history (database)
3. Save user message (database)
4. Run agent with history
5. Save assistant response (database)
6. Return response (server holds NO state)

## Architecture Rules

### 🚫 Never
- Store conversation state in memory
- Use class/module variables for state
- Keep connections open between requests
- Cache conversation data in server

### ✅ Always
- Store all state in database
- Read state fresh each request
- Write state after each operation
- Each request is independent

## Implementation Guide

### Step 1: Environment Setup

```bash
# Backend .env file
OPENAI_API_KEY=sk-...your-key-here...
DATABASE_URL=sqlite:///./database.db
JWT_SECRET_KEY=your-secret-key
```

Verify configuration:
```bash
bash .claude/skills/ai-integration/scripts/verify-openai.sh
```

### Step 2: Database Models

Required tables:
- `conversations` - Conversation metadata
- `messages` - Individual messages (role, content, timestamp)

```sql
-- Conversations
CREATE TABLE conversations (
    id INTEGER PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Messages
CREATE TABLE messages (
    id INTEGER PRIMARY KEY,
    conversation_id INTEGER NOT NULL,
    user_id VARCHAR NOT NULL,
    role VARCHAR NOT NULL,  -- 'user' or 'assistant'
    content TEXT NOT NULL,
    created_at TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);
```

### Step 3: Implement MCP Tools

See `references/mcp-tools-implementation.py` for complete code.

Key pattern for each tool:
```python
@mcp_server.tool(
    name="tool_name",
    description="Clear description",
    parameters=ToolParams
)
async def tool_function(params: ToolParams) -> dict:
    try:
        # 1. Validate user ownership
        # 2. Perform database operation
        # 3. Return structured response
        return {"status": "success", "message": "...", "data": {...}}
    except Exception as e:
        return {"status": "error", "message": str(e)}
```

### Step 4: Configure OpenAI Agent

See `references/openai-agent-implementation.py` for complete code.

Key components:
- System prompt with personality and guidelines
- Tool definitions matching MCP tools
- Function calling logic
- Conversation history management

### Step 5: Create Stateless Chat Endpoint

See `references/chat-endpoint-implementation.py` for complete code.

Endpoint: `POST /api/v1/chat`
- Request: `{conversation_id?, message}`
- Response: `{conversation_id, response}`

## Testing

### Test MCP Tools Directly

```bash
# Test all tools
bash .claude/skills/ai-integration/scripts/test-mcp-tools.sh

# Test specific tool
python -c "
from app.mcp.tools import add_task, AddTaskParams
import asyncio

result = asyncio.run(add_task(AddTaskParams(
    user_id='test-user',
    title='Test Task'
)))
print(result)
"
```

### Test Chat Endpoint

```bash
# Interactive chat test
bash .claude/skills/ai-integration/scripts/test-chat.sh

# cURL example
curl -X POST http://localhost:8001/api/v1/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "Add a task: Buy groceries"}'
```

## Examples

### Example Conversations

**Adding Tasks:**
```
User: "Remind me to buy groceries tomorrow"
Assistant: "✓ I've added 'Buy groceries tomorrow' to your list."

User: "Add another one: Call mom"
Assistant: "✓ Added 'Call mom' to your tasks."
```

**Listing Tasks:**
```
User: "What do I need to do?"
Assistant: "You have 2 tasks:
☐ Buy groceries tomorrow
☐ Call mom

Both are pending. Would you like to mark any as complete?"
```

**Completing Tasks:**
```
User: "I called mom"
Assistant: "✓ Marked 'Call mom' as completed. Great job!"

User: "Show my tasks"
Assistant: "You have 2 tasks (1 completed, 1 pending):
☐ Buy groceries tomorrow
✓ Call mom"
```

### Example Tool Calls

See `examples/tool-examples.json` for complete request/response examples.

## Integration with .specify/

### Phase III Requirements

This skill implements Phase III (AI-Powered Chatbot):
- ✅ MCP server with 5+ stateless tools
- ✅ OpenAI Agents SDK integration (GPT-4)
- ✅ Stateless chat endpoint
- ✅ Conversation persistence in database
- ✅ JWT verification enforced
- ✅ User isolation at database level

### Referenced in Specs

- `specs/features/ai-chatbot.md` - Feature specification
- `specs/api/chat-endpoint.md` - API design
- `specs/database/schema.md` - Conversation tables

### TDD Workflow

**Red Phase:** Write tests
```bash
# Test MCP tools fail before implementation
bash .claude/skills/run-tests/scripts/run.sh backend tests/test_mcp_tools.py
```

**Green Phase:** Implement
```bash
# Implement tools using references/
# Test again
bash .claude/skills/ai-integration/scripts/test-mcp-tools.sh
```

**Refactor Phase:** Optimize
```bash
# Ensure stateless design
# Verify user isolation
# Check error handling
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| OpenAI API key missing | Add to .env: `OPENAI_API_KEY=sk-...` |
| Tool not found | Check tool registration in mcp_server.tool() |
| State not persisting | Verify database writes in each tool |
| Unauthorized errors | Check user_id validation in tools |
| Agent not calling tools | Verify tool definitions match OpenAI format |

## Security Checklist

- [ ] JWT verification on chat endpoint
- [ ] User ID extracted from JWT (not request body)
- [ ] All tools validate user ownership
- [ ] Database queries filter by user_id
- [ ] No sensitive data in error messages
- [ ] API key stored in environment variables
- [ ] Conversation history isolated per user

## Performance Considerations

### Database Queries
- Index on `conversation_id` in messages table
- Index on `user_id` in conversations table
- Limit conversation history (e.g., last 50 messages)

### OpenAI API
- Use streaming for long responses (future enhancement)
- Cache system prompt (static)
- Monitor token usage

## File Structure

```
backend/
├── app/
│   ├── mcp/
│   │   ├── __init__.py
│   │   ├── server.py          # MCP server initialization
│   │   └── tools.py           # 5 MCP tool implementations
│   ├── agents/
│   │   ├── __init__.py
│   │   ├── prompts.py         # System prompt
│   │   └── chat_agent.py      # OpenAI agent logic
│   ├── routes/
│   │   └── chat.py            # Stateless chat endpoint
│   └── models/
│       ├── conversation.py    # Conversation model
│       └── message.py         # Message model
```

## References

Complete implementation code:
- `references/mcp-tools-implementation.py` - All 5 MCP tools
- `references/openai-agent-implementation.py` - Agent configuration
- `references/chat-endpoint-implementation.py` - Stateless endpoint
- `references/system-prompt.md` - System prompt text
- `examples/tool-examples.json` - Tool request/response examples

## Next Steps

After implementing this skill:

1. **Frontend Integration**: Add ChatKit UI components
2. **Voice Input**: Integrate speech-to-text
3. **Streaming**: Add SSE for real-time responses
4. **Analytics**: Track conversation metrics
5. **Advanced Features**: Context understanding, multi-turn clarification

## Related Skills

- `start-backend` - Start FastAPI server with MCP endpoint
- `run-tests` - Test MCP tools and chat endpoint
- `verify-setup` - Verify OpenAI configuration

---

**Critical:** This skill enables conversational AI that is stateless, secure, and provides excellent user experience while maintaining strict user isolation and database-backed state management.
