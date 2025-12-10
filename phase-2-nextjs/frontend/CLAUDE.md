# Frontend Guidelines

## Stack
- **Framework**: Next.js 16+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Authentication**: Better Auth with JWT
- **State Management**: React hooks (useState, useEffect, useContext)

## Project Structure
```
frontend/
├── app/                    # Next.js App Router
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Landing page
│   ├── signup/            # Signup page
│   ├── signin/            # Signin page
│   ├── tasks/             # Tasks pages
│   └── api/               # API routes (Better Auth)
├── components/             # Reusable UI components
│   ├── Header.tsx
│   ├── AuthForm.tsx
│   ├── TaskForm.tsx
│   ├── TaskList.tsx
│   ├── TaskItem.tsx
│   └── TaskDetail.tsx
├── lib/                    # Utilities and helpers
│   ├── auth.ts            # Better Auth configuration
│   ├── auth-context.tsx   # Auth context provider
│   └── api.ts             # API client with JWT
├── types/                  # TypeScript type definitions
│   └── task.ts
├── public/                 # Static assets
├── .env.local             # Environment variables
├── package.json
├── tsconfig.json
└── tailwind.config.js
```

## Development Patterns

### Server vs Client Components
- **Use server components by default** (Next.js App Router default)
- **Use client components** (`"use client"`) only when needed:
  - Interactive elements (onClick, onChange, etc.)
  - React hooks (useState, useEffect, etc.)
  - Browser APIs (localStorage, window, etc.)
  - Context providers and consumers

### Component Structure
```tsx
// Server Component (default)
export default function TasksPage() {
  // Can fetch data directly
  return <div>...</div>;
}

// Client Component (when needed)
"use client";

import { useState } from "react";

export function TaskForm() {
  const [title, setTitle] = useState("");
  // Interactive logic
  return <form>...</form>;
}
```

## API Client

All backend API calls should use the centralized API client:

```typescript
// lib/api.ts
import { authClient } from "./auth";

const API_URL = process.env.NEXT_PUBLIC_API_URL;

async function getAuthHeaders() {
  const session = await authClient.getSession();
  if (!session?.token) {
    throw new Error("Not authenticated");
  }
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

  // ... other methods
};
```

**Usage in components**:
```tsx
import { api } from "@/lib/api";

const tasks = await api.getTasks(userId);
```

## Authentication

### Better Auth Setup
```typescript
// lib/auth.ts
import { betterAuth } from "better-auth/client";
import { jwtPlugin } from "better-auth/plugins/jwt";

export const authClient = betterAuth({
  baseURL: process.env.NEXT_PUBLIC_AUTH_URL,
  plugins: [
    jwtPlugin({
      secret: process.env.BETTER_AUTH_SECRET,
      expiresIn: "7d",
    }),
  ],
});
```

### Auth Context Provider
```tsx
// lib/auth-context.tsx
"use client";

import { createContext, useContext, useState, useEffect } from "react";
import { authClient } from "./auth";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    try {
      const session = await authClient.getSession();
      setUser(session?.user || null);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AuthContext.Provider value={{ user, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
```

### Protected Routes
```tsx
// In any protected page
"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";

export default function ProtectedPage() {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !user) {
      router.push("/signin");
    }
  }, [user, isLoading, router]);

  if (isLoading || !user) {
    return <div>Loading...</div>;
  }

  return <div>Protected content</div>;
}
```

## Styling

### Tailwind CSS
- **Use Tailwind utility classes** for all styling
- **No inline styles** (use Tailwind classes instead)
- **Follow existing component patterns** for consistency

### Common Patterns
```tsx
// Button styles
<button className="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition">
  Click Me
</button>

// Input styles
<input className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" />

// Card styles
<div className="p-4 bg-white rounded-lg shadow hover:shadow-md transition">
  Card content
</div>
```

### Custom Styles (globals.css)
```css
/* app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .btn-primary {
    @apply bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition;
  }

  .btn-secondary {
    @apply bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition;
  }

  .input-field {
    @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500;
  }
}
```

## TypeScript

### Type Definitions
```typescript
// types/task.ts
export interface Task {
  id: number;
  user_id: string;
  title: string;
  description: string | null;
  completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface TaskCreate {
  title: string;
  description?: string;
}

export interface TaskUpdate {
  title?: string;
  description?: string;
}
```

### Component Props
```tsx
interface TaskItemProps {
  task: Task;
  onToggleComplete: (taskId: number) => Promise<void>;
  onDelete: (taskId: number) => Promise<void>;
}

export function TaskItem({ task, onToggleComplete, onDelete }: TaskItemProps) {
  // Component implementation
}
```

## Error Handling

### API Errors
```tsx
const [error, setError] = useState<string | null>(null);

try {
  await api.createTask(userId, data);
} catch (err) {
  setError(err instanceof Error ? err.message : "An error occurred");
}

// Display error
{error && <div className="text-red-500">{error}</div>}
```

### Form Validation
```tsx
const [errors, setErrors] = useState<{ title?: string }>({});

const validate = () => {
  const newErrors: { title?: string } = {};
  if (!title.trim()) {
    newErrors.title = "Title is required";
  } else if (title.length > 200) {
    newErrors.title = "Title must be 200 characters or less";
  }
  setErrors(newErrors);
  return Object.keys(newErrors).length === 0;
};
```

## Performance

### Loading States
```tsx
const [isLoading, setIsLoading] = useState(false);

const handleSubmit = async () => {
  setIsLoading(true);
  try {
    await api.createTask(userId, data);
  } finally {
    setIsLoading(false);
  }
};

<button disabled={isLoading}>
  {isLoading ? "Creating..." : "Create Task"}
</button>
```

### Optimistic Updates
```tsx
const handleToggleComplete = async (taskId: number) => {
  // Optimistic update
  setTasks(tasks.map(t =>
    t.id === taskId ? { ...t, completed: !t.completed } : t
  ));

  try {
    const updatedTask = await api.toggleComplete(userId, taskId);
    // Update with server response
    setTasks(tasks.map(t => t.id === taskId ? updatedTask : t));
  } catch (err) {
    // Revert on error
    setTasks(tasks.map(t =>
      t.id === taskId ? { ...t, completed: !t.completed } : t
    ));
  }
};
```

## Testing

### Type Checking
```bash
npm run type-check
```

### Build Verification
```bash
npm run build
```

## Environment Variables

### Required Variables
```bash
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_AUTH_URL=http://localhost:3000
BETTER_AUTH_SECRET=your-secret-key-min-32-chars
```

### Usage
```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL;
```

**Note**: Only variables prefixed with `NEXT_PUBLIC_` are exposed to the browser.

## Common Tasks

### Adding a New Page
1. Create file in `app/` directory
2. Export default component
3. Add metadata if needed
4. Add to navigation if needed

### Adding a New Component
1. Create file in `components/` directory
2. Define TypeScript interface for props
3. Export component function
4. Use in pages or other components

### Adding a New API Method
1. Add method to `lib/api.ts`
2. Include JWT headers
3. Handle errors appropriately
4. Return typed response

## Debugging

### Common Issues

**Issue**: "Not authenticated" error
- **Solution**: Check if JWT token exists in localStorage
- **Solution**: Verify token hasn't expired
- **Solution**: Ensure `BETTER_AUTH_SECRET` matches backend

**Issue**: CORS errors
- **Solution**: Verify backend CORS configuration includes frontend URL
- **Solution**: Check `NEXT_PUBLIC_API_URL` is correct

**Issue**: 404 on API calls
- **Solution**: Verify API URL and endpoint path
- **Solution**: Check backend server is running

## Best Practices

1. **Always use TypeScript** - Define types for all props and state
2. **Keep components small** - Single responsibility principle
3. **Reuse components** - Don't duplicate code
4. **Handle loading states** - Show feedback to users
5. **Handle errors gracefully** - Display user-friendly messages
6. **Validate inputs** - Both client and server side
7. **Use semantic HTML** - Accessibility matters
8. **Responsive design** - Test on different screen sizes
9. **Follow Tailwind patterns** - Consistent styling
10. **Comment complex logic** - Help future developers
