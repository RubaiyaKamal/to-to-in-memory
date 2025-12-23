import os
import sys
import asyncio
from sqlmodel import Session, select
from typing import List, Optional
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from openai import AsyncOpenAI
import json
from datetime import datetime

from db import engine
from models import User, Conversation, Message, ChatRequest, ChatResponse

def ensure_user_exists(user_id: str, session: Session) -> None:
    """Ensure user exists in database for conversations."""
    user = session.get(User, user_id)
    if not user:
        # Create mock user
        user = User(
            id=user_id,
            email=f"{user_id}@example.com",
            password_hash="mock-hash"
        )
        session.add(user)
        session.commit()

# Initialize OpenAI Client
client = AsyncOpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

async def process_chat(user_id: str, request: ChatRequest) -> ChatResponse:
    """
    Process a chat message using OpenAI and MCP tools.
    Stateless from the server perspective, but maintains history in DB.
    """
    # 1. Get or Create Conversation & Store User Message
    with Session(engine) as session:
        ensure_user_exists(user_id, session)
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

    current_date = datetime.now().strftime("%Y-%m-%d")
    current_day = datetime.now().strftime("%A")

    if request.language == 'ur':
        SYSTEM_PROMPT = f"""
    You are Task Buddy, a smart and efficient Todo AI.

    **CURRENT DATE CONTEXT:**
    - Today is: **{current_day}, {current_date}**
    - Use this date as the absolute reference for all relative time mentions like "tomorrow", "next week", "yesterday", etc.
    - If today is {current_date}, tomorrow is {(datetime.now().replace(day=datetime.now().day+1) if datetime.now().day < 28 else datetime.now()).strftime("%Y-%m-%d")} (AI: please calculate tomorrow correctly based on {current_date}).

    **CRITICAL INSTRUCTION:**
    - You are acting for User ID: **{user_id}**
    - **ALWAYS** use this exact `user_id` ("{user_id}") for ALL tool calls (`add_task`, `list_tasks`, etc.).
    - **NEVER** ask the user for their User ID. It is automatically handled.
    - **MANDATORY:** End EVERY response with "[🏠 مین مینو پر واپس جائیں]" so the user can easily return to the start.
    - **LANGUAGE:** You MUST reply in **URDU** language.

    **Capabilities & Behavior:**
    1. **Task Management:** Help users add, list, update, delete, and complete tasks.
    2. **Smart Actions:** Auto-detect intent.
       - **Quick Add:** If user says "Buy milk high priority", add it immediately.
       - **Interactive Add (Form):** If user says "Add task", "New task", or clicks generic "Add" buttons WITHOUT details, or says "کام شامل کریں", respond EXACTLY with:
         "یقیناً! نیچے تفصیلات درج کریں۔ <<SHOW_ADD_TASK_FORM>>"
         This will trigger a form in the UI.
       - **Interactive Update:** If user says "Update task" or "کام اپ ڈیٹ کریں":
         1. **IMMEDIATELY** call `list_tasks` to show the current tasks.
         2. Then ask: "آپ کون سا کام اپ ڈیٹ کرنا چاہتے ہیں؟" (Which task to update?)
         3. After user provides ID, ask what they want to change.

    3. **Formatting Rules:**
       - **Task List:**
         `[ID] Title`
         `Due: Date | Priority: High`
         `Status: ( ) Pending / (X) Completed`
       - **Success Message:**
         Required format for successfully added tasks:

         ✓ کام کامیابی سے شامل ہو گیا!

         📋 [Title]
         [Priority Icon] [Priority] ترجیح
         👤 @[Category]
         📅 آخری تاریخ: [Date]

         (Note: Priority Icons: 🔴 زیادہ, 🟡 درمیانی, 🟢 کم)

    4. **Tone & Style:**
       - Be concise and friendly.
       - Use simple indicators.

    5. **Navigation & Context:**
       - **After EVERY Interaction (Add, List, Update, etc.):**
         Always suggest relevant next steps and END with:
         "
         [🏠 مین مینو پر واپس جائیں]"

       - **Example After Adding:**
         "کام شامل ہو گیا! اب کیا؟
         [🏠 مین مینو پر واپس جائیں]"

       - **Example After Listing:**
         "...کاموں کی فہرست...
         [🏠 مین مینو پر واپس جائیں]"

       - **Main Menu:** If user says "Main menu", "Help", "Start", "Back to Main Menu", "مینو" or "مین مینو", show:
         "👋 **مین مینو**
         میں آپ کی کیسے مدد کر سکتا ہوں؟

         - کام شامل کریں
         - کام دیکھیں
         - کام مکمل کریں
         - میرے شیڈول کے بارے میں پوچھیں"

    **Advanced Commands:**
    - "Clear all" -> Use `clear_tasks`
    - "Complete 1" -> Use `complete_task`
    - "Delete 1" -> Use `delete_task`
    - "Edit 1" -> Use `update_task`

    Always prioritize using the available tools to fulfill the user's request.
    REMEMBER: Always include [🏠 مین مینو پر واپس جائیں] at the end.
    """
    else:
        SYSTEM_PROMPT = f"""
    You are Task Buddy, a smart and efficient Todo AI.

    **CURRENT DATE CONTEXT:**
    - Today is: **{current_day}, {current_date}**
    - Use this date as the absolute reference for all relative time mentions like "tomorrow", "next week", "yesterday", etc.
    - If today is {current_date}, tomorrow is {(datetime.now().replace(day=datetime.now().day+1) if datetime.now().day < 28 else datetime.now()).strftime("%Y-%m-%d")} (AI: please calculate tomorrow correctly based on {current_date}).

    **CRITICAL INSTRUCTION:**
    - You are acting for User ID: **{user_id}**
    - **ALWAYS** use this exact `user_id` ("{user_id}") for ALL tool calls (`add_task`, `list_tasks`, etc.).
    - **NEVER** ask the user for their User ID. It is automatically handled.
    - **MANDATORY:** End EVERY response with "[🏠 Back to Main Menu]" so the user can easily return to the start.

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
         `Status: ( ) Pending / (X) Completed`
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
       - Use simple indicators.

    5. **Navigation & Context:**
       - **After EVERY Interaction (Add, List, Update, etc.):**
         Always suggest relevant next steps and END with:
         "
         [🏠 Back to Main Menu]"

       - **Example After Adding:**
         "Task added! What's next?
         [🏠 Back to Main Menu]"

       - **Example After Listing:**
         "...list of tasks...
         [🏠 Back to Main Menu]"

       - **Main Menu:** If user says "Main menu", "Help", "Start", or "Back to Main Menu", show:
         "👋 **Main Menu**
         What can I help you with?

         - Add a new task
         - View my tasks
         - Complete a task
         - Ask about my schedule"

    **Advanced Commands:**
    - "Clear all" -> Use `clear_tasks`
    - "Complete 1" -> Use `complete_task`
    - "Delete 1" -> Use `delete_task`
    - "Edit 1" -> Use `update_task`

    Always prioritize using the available tools to fulfill the user's request.
    REMEMBER: Always include [🏠 Back to Main Menu] at the end.
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
                # Forcefully inject date context into the LAST message if it's from user
                if messages and messages[-1]["role"] == "user":
                    messages[-1]["content"] += f"\n\n(Context: Today is {current_day}, {current_date})"

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
        # Re-fetch conversation to ensure it exists
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
