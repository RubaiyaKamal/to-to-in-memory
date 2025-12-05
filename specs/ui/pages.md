# UI Pages Specification

## Next.js App Router Structure

```
app/
├── layout.tsx                 # Root layout
├── page.tsx                   # Landing page (/)
├── signup/
│   └── page.tsx              # Signup page (/signup)
├── signin/
│   └── page.tsx              # Signin page (/signin)
├── tasks/
│   ├── page.tsx              # Tasks list (/tasks)
│   └── [id]/
│       └── page.tsx          # Task detail (/tasks/[id])
└── api/
    └── auth/
        └── [...all]/
            └── route.ts      # Better Auth API routes
```

---

## Pages

### Root Layout (`app/layout.tsx`)
**Purpose**: Shared layout for all pages

**Features**:
- HTML structure
- Metadata configuration
- Global styles import
- Auth provider wrapper
- Header component

**Protected**: No

**Example**:
```tsx
// app/layout.tsx
import { Header } from "@/components/Header";
import { AuthProvider } from "@/lib/auth-context";
import "./globals.css";

export const metadata = {
  title: "Todo App",
  description: "A modern todo application",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>
          <Header />
          <main className="container mx-auto px-4 py-8">
            {children}
          </main>
        </AuthProvider>
      </body>
    </html>
  );
}
```

---

### Landing Page (`app/page.tsx`)
**Purpose**: Redirect to appropriate page based on auth status

**Features**:
- Check authentication status
- Redirect to `/tasks` if authenticated
- Redirect to `/signin` if not authenticated

**Protected**: No

**Example**:
```tsx
// app/page.tsx
"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";

export default function HomePage() {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading) {
      router.push(user ? "/tasks" : "/signin");
    }
  }, [user, isLoading, router]);

  return <div className="text-center">Loading...</div>;
}
```

---

### Signup Page (`app/signup/page.tsx`)
**Purpose**: User registration

**Features**:
- AuthForm component in signup mode
- Email and password inputs
- Form validation
- Create user account
- Generate JWT token
- Redirect to `/tasks` on success
- Link to signin page

**Protected**: No (public)

**Flow**:
1. User enters email and password
2. Validate inputs (email format, password length)
3. Call Better Auth signup API
4. Store JWT token in localStorage
5. Redirect to `/tasks`

**Example**:
```tsx
// app/signup/page.tsx
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { AuthForm } from "@/components/AuthForm";
import { authClient } from "@/lib/auth";

export default function SignupPage() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  const handleSignup = async (email: string, password: string) => {
    try {
      await authClient.signUp({ email, password });
      router.push("/tasks");
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  return (
    <div className="max-w-md mx-auto mt-12">
      <h1 className="text-3xl font-bold text-center mb-8">Sign Up</h1>
      {error && <div className="text-red-500 mb-4">{error}</div>}
      <AuthForm mode="signup" onSubmit={handleSignup} />
      <p className="text-center mt-4">
        Already have an account? <a href="/signin" className="text-primary">Sign In</a>
      </p>
    </div>
  );
}
```

---

### Signin Page (`app/signin/page.tsx`)
**Purpose**: User authentication

**Features**:
- AuthForm component in signin mode
- Email and password inputs
- Form validation
- Verify credentials
- Generate JWT token
- Redirect to `/tasks` on success
- Link to signup page

**Protected**: No (public)

**Flow**:
1. User enters email and password
2. Validate inputs
3. Call Better Auth signin API
4. Store JWT token in localStorage
5. Redirect to `/tasks`

**Example**:
```tsx
// app/signin/page.tsx
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { AuthForm } from "@/components/AuthForm";
import { authClient } from "@/lib/auth";

export default function SigninPage() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  const handleSignin = async (email: string, password: string) => {
    try {
      await authClient.signIn({ email, password });
      router.push("/tasks");
    } catch (err) {
      setError("Invalid email or password");
      throw err;
    }
  };

  return (
    <div className="max-w-md mx-auto mt-12">
      <h1 className="text-3xl font-bold text-center mb-8">Sign In</h1>
      {error && <div className="text-red-500 mb-4">{error}</div>}
      <AuthForm mode="signin" onSubmit={handleSignin} />
      <p className="text-center mt-4">
        Don't have an account? <a href="/signup" className="text-primary">Sign Up</a>
      </p>
    </div>
  );
}
```

---

### Tasks List Page (`app/tasks/page.tsx`)
**Purpose**: Main tasks view with create and list

**Features**:
- Protected route (requires authentication)
- TaskForm for creating new tasks
- TaskList displaying all user's tasks
- Filter by status (all, pending, completed)
- Sort options (created, title)
- Loading and error states

**Protected**: Yes (redirect to `/signin` if not authenticated)

**Flow**:
1. Check authentication (redirect if not authenticated)
2. Fetch user's tasks from API
3. Display TaskForm (create mode)
4. Display TaskList with tasks
5. Handle create, toggle, delete actions

**Example**:
```tsx
// app/tasks/page.tsx
"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { TaskForm } from "@/components/TaskForm";
import { TaskList } from "@/components/TaskList";
import type { Task } from "@/types/task";

export default function TasksPage() {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [isLoadingTasks, setIsLoadingTasks] = useState(true);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push("/signin");
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      loadTasks();
    }
  }, [user]);

  const loadTasks = async () => {
    try {
      const data = await api.getTasks(user.id);
      setTasks(data);
    } finally {
      setIsLoadingTasks(false);
    }
  };

  const handleCreateTask = async (data: { title: string; description?: string }) => {
    const newTask = await api.createTask(user.id, data);
    setTasks([newTask, ...tasks]);
  };

  const handleToggleComplete = async (taskId: number) => {
    const updatedTask = await api.toggleComplete(user.id, taskId);
    setTasks(tasks.map(t => t.id === taskId ? updatedTask : t));
  };

  const handleDelete = async (taskId: number) => {
    await api.deleteTask(user.id, taskId);
    setTasks(tasks.filter(t => t.id !== taskId));
  };

  if (isLoading || !user) {
    return <div>Loading...</div>;
  }

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-8">My Tasks</h1>

      <div className="mb-8">
        <h2 className="text-xl font-semibold mb-4">Create New Task</h2>
        <TaskForm mode="create" onSubmit={handleCreateTask} />
      </div>

      <div>
        <h2 className="text-xl font-semibold mb-4">All Tasks</h2>
        {isLoadingTasks ? (
          <div>Loading tasks...</div>
        ) : (
          <TaskList
            tasks={tasks}
            onToggleComplete={handleToggleComplete}
            onDelete={handleDelete}
          />
        )}
      </div>
    </div>
  );
}
```

---

### Task Detail Page (`app/tasks/[id]/page.tsx`)
**Purpose**: View and edit individual task

**Features**:
- Protected route (requires authentication)
- Display full task details
- Edit mode with TaskForm
- Delete task
- Toggle completion
- Back to list button

**Protected**: Yes (redirect to `/signin` if not authenticated)

**Flow**:
1. Check authentication
2. Fetch task by ID from API
3. Verify task belongs to user (404 if not)
4. Display TaskDetail component
5. Handle edit, delete, toggle actions

**Example**:
```tsx
// app/tasks/[id]/page.tsx
"use client";

import { useState, useEffect } from "react";
import { useRouter, useParams } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { api } from "@/lib/api";
import { TaskDetail } from "@/components/TaskDetail";
import { TaskForm } from "@/components/TaskForm";
import type { Task } from "@/types/task";

export default function TaskDetailPage() {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  const params = useParams();
  const taskId = parseInt(params.id as string);

  const [task, setTask] = useState<Task | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  useEffect(() => {
    if (!isLoading && !user) {
      router.push("/signin");
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    if (user) {
      loadTask();
    }
  }, [user, taskId]);

  const loadTask = async () => {
    try {
      const data = await api.getTask(user.id, taskId);
      setTask(data);
    } catch (err) {
      router.push("/tasks");
    }
  };

  const handleUpdate = async (data: { title: string; description?: string }) => {
    const updatedTask = await api.updateTask(user.id, taskId, data);
    setTask(updatedTask);
    setIsEditing(false);
  };

  const handleDelete = async () => {
    await api.deleteTask(user.id, taskId);
    router.push("/tasks");
  };

  const handleToggleComplete = async () => {
    const updatedTask = await api.toggleComplete(user.id, taskId);
    setTask(updatedTask);
  };

  if (!task) {
    return <div>Loading...</div>;
  }

  return (
    <div className="max-w-2xl mx-auto">
      <button onClick={() => router.push("/tasks")} className="mb-4">
        ← Back to Tasks
      </button>

      {isEditing ? (
        <TaskForm
          mode="edit"
          initialData={{ title: task.title, description: task.description }}
          onSubmit={handleUpdate}
          onCancel={() => setIsEditing(false)}
        />
      ) : (
        <TaskDetail
          task={task}
          onEdit={() => setIsEditing(true)}
          onDelete={handleDelete}
          onToggleComplete={handleToggleComplete}
        />
      )}
    </div>
  );
}
```

---

## Route Protection

### Protected Route HOC
```tsx
// lib/with-auth.tsx
import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "./auth-context";

export function withAuth(Component: React.ComponentType) {
  return function ProtectedRoute(props: any) {
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

    return <Component {...props} />;
  };
}
```

---

## SEO & Metadata

### Page Metadata
```tsx
// app/tasks/page.tsx
export const metadata = {
  title: "My Tasks | Todo App",
  description: "Manage your todo tasks",
};
```

### Dynamic Metadata
```tsx
// app/tasks/[id]/page.tsx
export async function generateMetadata({ params }: { params: { id: string } }) {
  return {
    title: `Task ${params.id} | Todo App`,
  };
}
```
