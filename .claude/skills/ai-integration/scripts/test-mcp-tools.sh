#!/bin/bash

# Test MCP Tools Script
# Tests all MCP tools for the AI chatbot

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PHASE="${1:-phase-3}"
BACKEND_DIR="phase-3-chatbot/backend"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Testing MCP Tools${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check backend directory
if [ ! -d "$BACKEND_DIR" ]; then
    echo -e "${RED}Backend directory not found: $BACKEND_DIR${NC}"
    exit 1
fi

cd "$BACKEND_DIR"

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate || source venv/Scripts/activate 2>/dev/null
else
    echo -e "${RED}Virtual environment not found${NC}"
    exit 1
fi

# Check if MCP tools exist
if [ ! -f "app/mcp/tools.py" ]; then
    echo -e "${YELLOW}MCP tools not yet implemented${NC}"
    echo "Please implement according to references/mcp-tools-implementation.py"
    exit 1
fi

echo -e "${GREEN}Running MCP tool tests...${NC}"
echo ""

# Test each tool
TEST_USER_ID="test-user-$(date +%s)"

echo -e "${BLUE}Test 1: Add Task${NC}"
python -c "
import asyncio
import sys
sys.path.insert(0, '.')

from app.mcp.tools import add_task, AddTaskParams

async def test():
    result = await add_task(AddTaskParams(
        user_id='$TEST_USER_ID',
        title='Test Task 1',
        description='This is a test task'
    ))
    print(f\"Result: {result}\")
    assert result['status'] == 'success', 'Add task failed'
    print('✓ Add task successful')
    return result.get('task_id')

task_id = asyncio.run(test())
print(f'Task ID: {task_id}')
" || echo -e "${RED}✗ Add task failed${NC}"

echo ""

echo -e "${BLUE}Test 2: List Tasks${NC}"
python -c "
import asyncio
import sys
sys.path.insert(0, '.')

from app.mcp.tools import list_tasks, ListTasksParams

async def test():
    result = await list_tasks(ListTasksParams(
        user_id='$TEST_USER_ID',
        status='all'
    ))
    print(f\"Result: {result}\")
    assert result['status'] == 'success', 'List tasks failed'
    print(f\"✓ List tasks successful - Found {result['summary']['total']} tasks\")

asyncio.run(test())
" || echo -e "${RED}✗ List tasks failed${NC}"

echo ""

echo -e "${BLUE}Test 3: Complete Task${NC}"
python -c "
import asyncio
import sys
sys.path.insert(0, '.')

from app.mcp.tools import complete_task, CompleteTaskParams

async def test():
    # First get a task ID
    from app.mcp.tools import list_tasks, ListTasksParams
    tasks_result = await list_tasks(ListTasksParams(user_id='$TEST_USER_ID'))

    if tasks_result['summary']['total'] == 0:
        print('⚠ No tasks to complete')
        return

    task_id = tasks_result['tasks'][0]['id']

    result = await complete_task(CompleteTaskParams(
        user_id='$TEST_USER_ID',
        task_id=task_id
    ))
    print(f\"Result: {result}\")
    assert result['status'] == 'success', 'Complete task failed'
    print('✓ Complete task successful')

asyncio.run(test())
" || echo -e "${RED}✗ Complete task failed${NC}"

echo ""

echo -e "${BLUE}Test 4: Update Task${NC}"
python -c "
import asyncio
import sys
sys.path.insert(0, '.')

from app.mcp.tools import update_task, UpdateTaskParams

async def test():
    # Get a task ID
    from app.mcp.tools import list_tasks, ListTasksParams
    tasks_result = await list_tasks(ListTasksParams(user_id='$TEST_USER_ID'))

    if tasks_result['summary']['total'] == 0:
        print('⚠ No tasks to update')
        return

    task_id = tasks_result['tasks'][0]['id']

    result = await update_task(UpdateTaskParams(
        user_id='$TEST_USER_ID',
        task_id=task_id,
        title='Updated Test Task',
        description='Updated description'
    ))
    print(f\"Result: {result}\")
    assert result['status'] == 'success', 'Update task failed'
    print('✓ Update task successful')

asyncio.run(test())
" || echo -e "${RED}✗ Update task failed${NC}"

echo ""

echo -e "${BLUE}Test 5: Delete Task${NC}"
python -c "
import asyncio
import sys
sys.path.insert(0, '.')

from app.mcp.tools import delete_task, DeleteTaskParams

async def test():
    # Get a task ID
    from app.mcp.tools import list_tasks, ListTasksParams
    tasks_result = await list_tasks(ListTasksParams(user_id='$TEST_USER_ID'))

    if tasks_result['summary']['total'] == 0:
        print('⚠ No tasks to delete')
        return

    task_id = tasks_result['tasks'][0]['id']

    result = await delete_task(DeleteTaskParams(
        user_id='$TEST_USER_ID',
        task_id=task_id
    ))
    print(f\"Result: {result}\")
    assert result['status'] == 'success', 'Delete task failed'
    print('✓ Delete task successful')

asyncio.run(test())
" || echo -e "${RED}✗ Delete task failed${NC}"

echo ""

# Test user isolation
echo -e "${BLUE}Test 6: User Isolation${NC}"
python -c "
import asyncio
import sys
sys.path.insert(0, '.')

from app.mcp.tools import add_task, list_tasks, AddTaskParams, ListTasksParams

async def test():
    # Create task for user 1
    result1 = await add_task(AddTaskParams(
        user_id='user1',
        title='User 1 Task'
    ))

    # Create task for user 2
    result2 = await add_task(AddTaskParams(
        user_id='user2',
        title='User 2 Task'
    ))

    # List tasks for user 1 - should only see their task
    user1_tasks = await list_tasks(ListTasksParams(user_id='user1'))
    user2_tasks = await list_tasks(ListTasksParams(user_id='user2'))

    # Verify isolation
    user1_titles = [t['title'] for t in user1_tasks['tasks']]
    user2_titles = [t['title'] for t in user2_tasks['tasks']]

    assert 'User 1 Task' in user1_titles, 'User 1 should see their task'
    assert 'User 2 Task' not in user1_titles, 'User 1 should NOT see user 2 task'
    assert 'User 2 Task' in user2_titles, 'User 2 should see their task'
    assert 'User 1 Task' not in user2_titles, 'User 2 should NOT see user 1 task'

    print('✓ User isolation working correctly')

asyncio.run(test())
" || echo -e "${RED}✗ User isolation failed${NC}"

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}MCP Tool Tests Complete${NC}"
echo -e "${GREEN}=====================================${NC}"

cd - > /dev/null
