# REST API Endpoints

## Base URL
- **Development**: `http://localhost:8000`
- **Production**: `https://api.yourdomain.com` (to be configured)

## Authentication
All endpoints require JWT token in the `Authorization` header:
```
Authorization: Bearer <jwt-token>
```

Requests without a valid token will receive `401 Unauthorized`.

---

## Endpoints

### Health Check

#### `GET /health`
Check API health and database connection.

**Authentication**: Not required

**Response**: `200 OK`
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### List All Tasks

#### `GET /api/{user_id}/tasks`
Retrieve all tasks for the authenticated user.

**Authentication**: Required

**Path Parameters**:
- `user_id` (string): User ID (must match authenticated user)

**Query Parameters**:
- `status` (optional): Filter by status (`all`, `pending`, `completed`). Default: `all`
- `sort` (optional): Sort order (`created`, `title`, `updated`). Default: `created`

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "user_id": "user-uuid-123",
    "title": "Buy groceries",
    "description": "Milk, eggs, bread",
    "completed": false,
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T10:00:00Z"
  },
  {
    "id": 2,
    "user_id": "user-uuid-123",
    "title": "Finish project",
    "description": null,
    "completed": true,
    "created_at": "2024-01-14T15:30:00Z",
    "updated_at": "2024-01-15T09:00:00Z"
  }
]
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: user_id in path doesn't match authenticated user

---

### Create Task

#### `POST /api/{user_id}/tasks`
Create a new task for the authenticated user.

**Authentication**: Required

**Path Parameters**:
- `user_id` (string): User ID (must match authenticated user)

**Request Body**:
```json
{
  "title": "Buy groceries",
  "description": "Milk, eggs, bread"  // Optional
}
```

**Validation**:
- `title`: Required, 1-200 characters
- `description`: Optional, max 1000 characters

**Response**: `201 Created`
```json
{
  "id": 3,
  "user_id": "user-uuid-123",
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": false,
  "created_at": "2024-01-15T11:00:00Z",
  "updated_at": "2024-01-15T11:00:00Z"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid request body or validation error
  ```json
  {
    "detail": "Title is required and must be 1-200 characters"
  }
  ```
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: user_id in path doesn't match authenticated user

---

### Get Task Details

#### `GET /api/{user_id}/tasks/{id}`
Retrieve details of a specific task.

**Authentication**: Required

**Path Parameters**:
- `user_id` (string): User ID (must match authenticated user)
- `id` (integer): Task ID

**Response**: `200 OK`
```json
{
  "id": 1,
  "user_id": "user-uuid-123",
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": false,
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: user_id in path doesn't match authenticated user
- `404 Not Found`: Task doesn't exist or doesn't belong to user
  ```json
  {
    "detail": "Task not found"
  }
  ```

---

### Update Task

#### `PUT /api/{user_id}/tasks/{id}`
Update an existing task's title and/or description.

**Authentication**: Required

**Path Parameters**:
- `user_id` (string): User ID (must match authenticated user)
- `id` (integer): Task ID

**Request Body**:
```json
{
  "title": "Buy groceries and cook dinner",  // Optional
  "description": "Milk, eggs, bread, chicken"  // Optional
}
```

**Validation**:
- At least one field (`title` or `description`) must be provided
- `title`: 1-200 characters if provided
- `description`: max 1000 characters if provided

**Response**: `200 OK`
```json
{
  "id": 1,
  "user_id": "user-uuid-123",
  "title": "Buy groceries and cook dinner",
  "description": "Milk, eggs, bread, chicken",
  "completed": false,
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T11:30:00Z"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid request body or validation error
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: user_id in path doesn't match authenticated user
- `404 Not Found`: Task doesn't exist or doesn't belong to user

---

### Delete Task

#### `DELETE /api/{user_id}/tasks/{id}`
Permanently delete a task.

**Authentication**: Required

**Path Parameters**:
- `user_id` (string): User ID (must match authenticated user)
- `id` (integer): Task ID

**Response**: `204 No Content`
(Empty response body)

**Error Responses**:
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: user_id in path doesn't match authenticated user
- `404 Not Found`: Task doesn't exist or doesn't belong to user

---

### Toggle Task Completion

#### `PATCH /api/{user_id}/tasks/{id}/complete`
Toggle a task's completion status (complete ↔ incomplete).

**Authentication**: Required

**Path Parameters**:
- `user_id` (string): User ID (must match authenticated user)
- `id` (integer): Task ID

**Request Body**: None required (status is toggled automatically)

**Response**: `200 OK`
```json
{
  "id": 1,
  "user_id": "user-uuid-123",
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": true,  // Toggled from false to true
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T12:00:00Z"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: user_id in path doesn't match authenticated user
- `404 Not Found`: Task doesn't exist or doesn't belong to user

---

## Error Response Format

All error responses follow this structure:

```json
{
  "detail": "Human-readable error message"
}
```

### HTTP Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation error, malformed request |
| 401 | Unauthorized | Missing, invalid, or expired JWT token |
| 403 | Forbidden | Valid token but user_id mismatch |
| 404 | Not Found | Resource doesn't exist or doesn't belong to user |
| 500 | Internal Server Error | Unexpected server error |

---

## CORS Configuration

### Allowed Origins
- Development: `http://localhost:3000`
- Production: `https://yourdomain.com` (to be configured)

### Allowed Methods
- `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`

### Allowed Headers
- `Authorization`, `Content-Type`

### Credentials
- Allowed: `true`

---

## Rate Limiting

**Phase II**: Not implemented
**Future Enhancement**: 100 requests per minute per user

---

## API Versioning

**Current Version**: v1 (implicit, no version prefix)
**Future**: `/api/v2/...` when breaking changes are introduced

---

## Example API Calls

### Using cURL

#### Create Task
```bash
curl -X POST http://localhost:8000/api/user-uuid-123/tasks \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy groceries", "description": "Milk, eggs, bread"}'
```

#### List Tasks
```bash
curl -X GET http://localhost:8000/api/user-uuid-123/tasks \
  -H "Authorization: Bearer eyJhbGc..."
```

#### Update Task
```bash
curl -X PUT http://localhost:8000/api/user-uuid-123/tasks/1 \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy groceries and cook dinner"}'
```

#### Toggle Complete
```bash
curl -X PATCH http://localhost:8000/api/user-uuid-123/tasks/1/complete \
  -H "Authorization: Bearer eyJhbGc..."
```

#### Delete Task
```bash
curl -X DELETE http://localhost:8000/api/user-uuid-123/tasks/1 \
  -H "Authorization: Bearer eyJhbGc..."
```

### Using JavaScript (Frontend)

```typescript
// lib/api.ts
const API_URL = process.env.NEXT_PUBLIC_API_URL;

async function getAuthHeaders() {
  const session = await authClient.getSession();
  return {
    "Authorization": `Bearer ${session.token}`,
    "Content-Type": "application/json",
  };
}

export const api = {
  async getTasks(userId: string) {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/api/${userId}/tasks`, { headers });
    if (!response.ok) throw new Error("Failed to fetch tasks");
    return response.json();
  },

  async createTask(userId: string, data: { title: string; description?: string }) {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/api/${userId}/tasks`, {
      method: "POST",
      headers,
      body: JSON.stringify(data),
    });
    if (!response.ok) throw new Error("Failed to create task");
    return response.json();
  },

  async updateTask(userId: string, taskId: number, data: Partial<{ title: string; description: string }>) {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/api/${userId}/tasks/${taskId}`, {
      method: "PUT",
      headers,
      body: JSON.stringify(data),
    });
    if (!response.ok) throw new Error("Failed to update task");
    return response.json();
  },

  async deleteTask(userId: string, taskId: number) {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/api/${userId}/tasks/${taskId}`, {
      method: "DELETE",
      headers,
    });
    if (!response.ok) throw new Error("Failed to delete task");
  },

  async toggleComplete(userId: string, taskId: number) {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/api/${userId}/tasks/${taskId}/complete`, {
      method: "PATCH",
      headers,
    });
    if (!response.ok) throw new Error("Failed to toggle task");
    return response.json();
  },
};
```
