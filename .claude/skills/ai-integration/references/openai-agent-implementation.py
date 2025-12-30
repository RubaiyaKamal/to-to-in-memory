"""
OpenAI Agent Implementation Reference
Complete implementation of OpenAI agent with function calling

File location: backend/app/agents/chat_agent.py
"""

from openai import OpenAI
from typing import List, Dict, Any
import json
import os

from app.mcp.tools import (
    add_task, list_tasks, complete_task, update_task, delete_task,
    AddTaskParams, ListTasksParams, CompleteTaskParams,
    UpdateTaskParams, DeleteTaskParams
)
from app.agents.prompts import SYSTEM_PROMPT

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Define tools for OpenAI function calling
TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "add_task",
            "description": "Create a new task in the user's todo list",
            "parameters": {
                "type": "object",
                "properties": {
                    "title": {
                        "type": "string",
                        "description": "The task title (required, 1-200 characters)"
                    },
                    "description": {
                        "type": "string",
                        "description": "Optional task description"
                    }
                },
                "required": ["title"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "list_tasks",
            "description": "List tasks with optional status filter",
            "parameters": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": ["all", "pending", "completed"],
                        "description": "Filter by status (default: 'all')"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Maximum number of tasks to return"
                    }
                }
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "complete_task",
            "description": "Mark a task as completed or toggle completion status",
            "parameters": {
                "type": "object",
                "properties": {
                    "task_id": {
                        "type": "integer",
                        "description": "ID of the task to complete"
                    }
                },
                "required": ["task_id"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "update_task",
            "description": "Update a task's title or description",
            "parameters": {
                "type": "object",
                "properties": {
                    "task_id": {
                        "type": "integer",
                        "description": "ID of the task to update"
                    },
                    "title": {
                        "type": "string",
                        "description": "New title"
                    },
                    "description": {
                        "type": "string",
                        "description": "New description"
                    }
                },
                "required": ["task_id"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "delete_task",
            "description": "Permanently delete a task",
            "parameters": {
                "type": "object",
                "properties": {
                    "task_id": {
                        "type": "integer",
                        "description": "ID of the task to delete"
                    }
                },
                "required": ["task_id"]
            }
        }
    }
]

async def run_agent(
    user_id: str,
    user_message: str,
    conversation_history: List[Dict[str, Any]]
) -> str:
    """
    Run the OpenAI agent with conversation history.

    Args:
        user_id: Authenticated user ID (for tool calls)
        user_message: New message from user
        conversation_history: Previous messages [{role, content}]

    Returns:
        Agent's response message
    """
    # Build messages array
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT}
    ]

    # Add conversation history
    messages.extend(conversation_history)

    # Add new user message
    messages.append({
        "role": "user",
        "content": user_message
    })

    # Call OpenAI with tools
    response = client.chat.completions.create(
        model="gpt-4-turbo-preview",
        messages=messages,
        tools=TOOLS,
        tool_choice="auto"
    )

    assistant_message = response.choices[0].message

    # Handle tool calls
    if assistant_message.tool_calls:
        # Execute each tool call
        for tool_call in assistant_message.tool_calls:
            function_name = tool_call.function.name
            function_args = json.loads(tool_call.function.arguments)

            # Add user_id to all function calls
            function_args["user_id"] = user_id

            # Call the appropriate MCP tool
            if function_name == "add_task":
                result = await add_task(AddTaskParams(**function_args))
            elif function_name == "list_tasks":
                result = await list_tasks(ListTasksParams(**function_args))
            elif function_name == "complete_task":
                result = await complete_task(CompleteTaskParams(**function_args))
            elif function_name == "update_task":
                result = await update_task(UpdateTaskParams(**function_args))
            elif function_name == "delete_task":
                result = await delete_task(DeleteTaskParams(**function_args))
            else:
                result = {"status": "error", "message": f"Unknown function: {function_name}"}

            # Add tool response to messages
            messages.append({
                "role": "assistant",
                "content": None,
                "tool_calls": [tool_call]
            })
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": json.dumps(result)
            })

        # Get final response after tool execution
        final_response = client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=messages
        )

        return final_response.choices[0].message.content

    # No tool calls, return direct response
    return assistant_message.content
