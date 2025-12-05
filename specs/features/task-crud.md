# Feature: Task CRUD Operations

## User Stories

### US-1: Create Task
**As a** logged-in user
**I want to** create a new task with a title and optional description
**So that** I can track things I need to do

### US-2: View All Tasks
**As a** logged-in user
**I want to** view all my tasks in a list
**So that** I can see what I need to work on

### US-3: View Task Details
**As a** logged-in user
**I want to** view the details of a specific task
**So that** I can see all information about it

### US-4: Update Task
**As a** logged-in user
**I want to** update a task's title and/or description
**So that** I can correct or add information

### US-5: Delete Task
**As a** logged-in user
**I want to** delete a task
**So that** I can remove tasks I no longer need

### US-6: Mark Task Complete/Incomplete
**As a** logged-in user
**I want to** toggle a task's completion status
**So that** I can track my progress

## Acceptance Criteria

### Create Task (US-1)
- ✅ User must be authenticated (valid JWT token)
- ✅ Title is required (1-200 characters)
- ✅ Description is optional (max 1000 characters)
- ✅ Task is automatically associated with authenticated user
- ✅ New task defaults to incomplete status
- ✅ Created task has unique ID, timestamps (created_at, updated_at)
- ✅ API returns 201 Created with task object
- ✅ Frontend displays success message and adds task to list
- ❌ Empty title returns 400 Bad Request
- ❌ Title > 200 characters returns 400 Bad Request
- ❌ No JWT token returns 401 Unauthorized

### View All Tasks (US-2)
- ✅ User must be authenticated (valid JWT token)
- ✅ Returns only tasks belonging to authenticated user
- ✅ Tasks are ordered by created_at (newest first)
- ✅ Each task shows: ID, title, completion status, created date
- ✅ Empty list shows "No tasks yet" message
- ✅ API returns 200 OK with array of tasks
- ❌ No JWT token returns 401 Unauthorized
- ❌ Invalid JWT token returns 401 Unauthorized

### View Task Details (US-3)
- ✅ User must be authenticated (valid JWT token)
- ✅ Task must belong to authenticated user
- ✅ Shows all task fields: ID, title, description, status, timestamps
- ✅ API returns 200 OK with task object
- ❌ Task doesn't exist returns 404 Not Found
- ❌ Task belongs to different user returns 404 Not Found
- ❌ No JWT token returns 401 Unauthorized

### Update Task (US-4)
- ✅ User must be authenticated (valid JWT token)
- ✅ Task must belong to authenticated user
- ✅ Can update title only
- ✅ Can update description only
- ✅ Can update both title and description
- ✅ Title validation: 1-200 characters if provided
- ✅ Description validation: max 1000 characters if provided
- ✅ updated_at timestamp is automatically updated
- ✅ API returns 200 OK with updated task object
- ✅ Frontend displays success message and updates task in list
- ❌ Empty title returns 400 Bad Request
- ❌ Title > 200 characters returns 400 Bad Request
- ❌ Task doesn't exist returns 404 Not Found
- ❌ Task belongs to different user returns 404 Not Found
- ❌ No JWT token returns 401 Unauthorized

### Delete Task (US-5)
- ✅ User must be authenticated (valid JWT token)
- ✅ Task must belong to authenticated user
- ✅ Task is permanently deleted from database
- ✅ API returns 204 No Content
- ✅ Frontend displays success message and removes task from list
- ❌ Task doesn't exist returns 404 Not Found
- ❌ Task belongs to different user returns 404 Not Found
- ❌ No JWT token returns 401 Unauthorized

### Mark Complete/Incomplete (US-6)
- ✅ User must be authenticated (valid JWT token)
- ✅ Task must belong to authenticated user
- ✅ Toggles completion status (true ↔ false)
- ✅ updated_at timestamp is automatically updated
- ✅ API returns 200 OK with updated task object
- ✅ Frontend updates task status in UI immediately
- ❌ Task doesn't exist returns 404 Not Found
- ❌ Task belongs to different user returns 404 Not Found
- ❌ No JWT token returns 401 Unauthorized

## Data Model

### Task
```typescript
interface Task {
  id: number;                    // Auto-generated primary key
  user_id: string;               // Foreign key to users table
  title: string;                 // Required, 1-200 characters
  description: string | null;    // Optional, max 1000 characters
  completed: boolean;            // Default: false
  created_at: Date;              // Auto-generated
  updated_at: Date;              // Auto-updated
}
```

## Validation Rules

### Title
- **Required**: Yes
- **Type**: String
- **Min Length**: 1 character
- **Max Length**: 200 characters
- **Trimming**: Leading/trailing whitespace removed
- **Empty after trim**: Rejected with 400 Bad Request

### Description
- **Required**: No
- **Type**: String or null
- **Max Length**: 1000 characters
- **Trimming**: Leading/trailing whitespace removed
- **Empty after trim**: Stored as null

### User ID
- **Required**: Yes (extracted from JWT token)
- **Type**: String (UUID)
- **Validation**: Must match authenticated user's ID

## UI/UX Requirements

### Task List View
- Display tasks in a responsive grid/list
- Show task title, status icon, and created date
- Provide quick actions: complete toggle, edit, delete
- Show empty state when no tasks exist
- Loading state while fetching tasks
- Error state if API call fails

### Task Creation Form
- Title input field (required)
- Description textarea (optional)
- Character count indicators
- Submit button (disabled while submitting)
- Clear form after successful creation
- Show validation errors inline

### Task Detail View
- Display all task information
- Edit button to switch to edit mode
- Delete button with confirmation
- Complete toggle button
- Back button to return to list

### Task Edit Form
- Pre-fill with current values
- Same validation as creation
- Save and Cancel buttons
- Show success/error messages

## Error Handling

### Client-Side Errors (400-499)
- **400 Bad Request**: Validation errors (show specific field errors)
- **401 Unauthorized**: Redirect to signin page
- **404 Not Found**: Show "Task not found" message
- **429 Too Many Requests**: Show "Please slow down" message

### Server-Side Errors (500-599)
- **500 Internal Server Error**: Show "Something went wrong, please try again"
- **503 Service Unavailable**: Show "Service temporarily unavailable"

### Network Errors
- Connection timeout: Show "Connection timeout, please check your internet"
- No internet: Show "No internet connection"

## Performance Requirements

### API Response Times
- List tasks: < 200ms (p95)
- Create task: < 300ms (p95)
- Update task: < 300ms (p95)
- Delete task: < 200ms (p95)

### Frontend Rendering
- Initial page load: < 2 seconds
- Task list render: < 100ms
- UI interactions: < 50ms (perceived instant)

## Security Requirements

### Authentication
- All endpoints require valid JWT token
- Token must not be expired
- Token signature must be valid

### Authorization
- Users can only access their own tasks
- Attempting to access another user's task returns 404 (not 403 to avoid leaking existence)

### Input Sanitization
- All user inputs are validated and sanitized
- SQL injection prevented by ORM (SQLModel)
- XSS prevented by React's default escaping
