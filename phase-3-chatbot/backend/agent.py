import os
import sys
import asyncio
from sqlmodel import Session, select
from typing import List, Optional
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from openai import AsyncOpenAI
import json

from .database import engine
from .models import Conversation, Message, ChatRequest, ChatResponse

# Initialize OpenAI Client
client = AsyncOpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
import os
import sys
import asyncio
from sqlmodel import Session, select
from typing import List, Optional
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from openai import AsyncOpenAI
import json

from .database import engine
from .models import Conversation, Message, ChatRequest, ChatResponse

# Initialize OpenAI Client
client = AsyncOpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

async def process_chat(user_id: str, request: ChatRequest) -> ChatResponse:
    """
    Process a chat message using OpenAI and MCP tools.
    Stateless from the server perspective, but maintains history in DB.
    """
    # 1. Get or Create Conversation & Store User Message
    with Session(engine) as session:
        if request.conversation_id:
            conversation = session.get(Conversation, request.conversation_id)
            if not conversation or conversation.user_id != user_id:
                conversation = Conversation(user_id=user_id)
                session.add(conversation)
                session.commit()
                session.refresh(conversation)
        else:
            conversation = Conversation(user_id=user_id)
            session.add(conversation)
            session.commit()
            session.refresh(conversation)

        conversation_id = conversation.id

        user_msg = Message(
            user_id=user_id,
            conversation_id=conversation_id,
            role="user",
            content=request.message
        )
        session.add(user_msg)
        session.commit()

        # Retrieve History
        history_msgs = session.exec(
            select(Message)
            .where(Message.conversation_id == conversation_id)
            .order_by(Message.created_at)
        ).all()

        messages = [{"role": msg.role, "content": msg.content} for msg in history_msgs]

    # Inject System Prompt
    SYSTEM_PROMPT = f"""
    You are Task Buddy, a smart and efficient Todo AI.

    **CRITICAL INSTRUCTION:**
    - You are acting for User ID: **{user_id}**
    - **ALWAYS** use this exact `user_id` ("{user_id}") for ALL tool calls (`add_task`, `list_tasks`, etc.).
    - **NEVER** ask the user for their User ID. It is automatically handled.

    **Capabilities & Behavior:**
    1. **Task Management:** Help users add, list, update, delete, and complete tasks.
    2. **Smart Actions:** Auto-detect intent.
       - **Quick Add:** If user says "Buy milk high priority", add it immediately.
       - **Interactive Add (Form):** If user says "Add task", "New task", or clicks generic "Add" buttons WITHOUT details, **DO NOT** ask for details one by one. Instead, respond EXACTLY with:
         "Sure! Fill in the details below. <<SHOW_ADD_TASK_FORM>>"
         This will trigger a form in the UI.
       - **Interactive Update:** If user says "Update task", "Edit task", "I need to update a task", or clicks "Update Task":
         1. **IMMEDIATELY** call `list_tasks` to show the current tasks (so the user sees the IDs).
         2. Then ask: "Which task number would you like to update?"
         3. After user provides ID, ask what they want to change.

    3. **Formatting Rules:**
       - **Task List:**
         `[ID] Title`
         `Due: Date | Priority: High`
         `Status: ⭕ Pending / ✅ Completed`
       - **Success Message:**
         Required format for successfully added tasks:

         ✓ Task added successfully!

         📋 [Title]
         [Priority Icon] [Priority] priority
         👤 @[Category]
         📅 Due: [Date]

         (Note: Priority Icons: 🔴 High, 🟡 Medium, 🟢 Low)

    4. **Tone & Style:**
       - Be concise and friendly.
       - Use emojis (✅, 📋, 🔴, 🟡, 🟢, 👤, 📅).

    5. **Navigation & Context:**
       - **After Adding a Task:**
         "What's next?

         [🏠 Main menu]"
       - **After Listing Tasks:**
         "────────────────
         What would you like to do?

         1️⃣ Add new task
         2️⃣ Mark task complete
         3️⃣ Edit task
         4️⃣ Delete task
         [🏠 Main menu]"
       - **Main Menu:** If user says "Main menu", "Help", or "Start", show:
         "👋 **Main Menu**
         What can I help you with?

         ➕ Add a new task
         📝 View my tasks
         ✅ Complete a task
         ❓ Ask about my schedule"

    **Advanced Commands:**
    - "Clear all" -> Use `clear_tasks`
    - "Complete 1" -> Use `complete_task`
    - "Delete 1" -> Use `delete_task`
    - "Edit 1" -> Use `update_task`

    Always prioritize using the available tools to fulfill the user's request.
    """

    messages.insert(0, {"role": "system", "content": SYSTEM_PROMPT})

    # 4. MCP & OpenAI Interaction (Outside of DB Session)
    # We need to run the MCP server as a subprocess
    python_exe = sys.executable
    script_path = os.path.join(os.path.dirname(__file__), "mcp_server.py")

    server_params = StdioServerParameters(
        command=python_exe,
        args=[script_path],
        env=os.environ.copy()
    )

    final_response_content = ""
    tool_calls_log = []

    try:
        async with stdio_client(server_params) as (read, write):
            async with ClientSession(read, write) as mcp_session:
                await mcp_session.initialize()

                # List available tools
                mcp_tools = await mcp_session.list_tools()

                # Convert MCP tools to OpenAI tools format
                openai_tools = []
                for tool in mcp_tools.tools:
                    openai_tools.append({
                        "type": "function",
                        "function": {
                            "name": tool.name,
                            "description": tool.description,
                            "parameters": tool.inputSchema
                        }
                    })

                # Call OpenAI
                response = await client.chat.completions.create(
                    model="gpt-4o",
                    messages=messages,
                    tools=openai_tools,
                    tool_choice="auto"
                )

                response_message = response.choices[0].message

                # Handle Tool Calls
                if response_message.tool_calls:
                    messages.append(response_message) # Add assistant's tool_call message

                    for tool_call in response_message.tool_calls:
                        tool_name = tool_call.function.name
                        tool_args = json.loads(tool_call.function.arguments)

                        tool_calls_log.append({
                            "name": tool_name,
                            "args": tool_args
                        })

                        # Execute tool via MCP
                        result = await mcp_session.call_tool(tool_name, arguments=tool_args)

                        # Add tool result to messages
                        # MCP CallToolResult might have multiple contents (text/image)
                        # We assume text for now
                        tool_output = ""
                        if result.content:
                            for content in result.content:
                                if content.type == "text":
                                    tool_output += content.text

                        messages.append({
                            "role": "tool",
                            "tool_call_id": tool_call.id,
                            "content": tool_output
                        })

                    # Follow-up call to OpenAI to get final response
                    second_response = await client.chat.completions.create(
                        model="gpt-4o",
                        messages=messages
                    )
                    final_response_content = second_response.choices[0].message.content
                else:
                    final_response_content = response_message.content
    except Exception as e:
        print(f"MCP Error: {e}")
        import traceback
        traceback.print_exc()
        final_response_content = f"Oops! I encountered an error: {str(e)}"

    # 5. Store Assistant Response (New Session)
    with Session(engine) as session:
        # Re-fetch conversation to ensure it exists (it should)
        assistant_msg = Message(
            user_id=user_id,
            conversation_id=conversation_id,
            role="assistant",
            content=final_response_content or "Action completed." # Fallback
        )
        session.add(assistant_msg)
        session.commit()

    return ChatResponse(
        conversation_id=conversation_id,
        response=final_response_content or "Action completed.",
        tool_calls=tool_calls_log
    )
