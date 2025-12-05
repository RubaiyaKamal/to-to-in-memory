# UI Components Specification

## Component Hierarchy

```
App
├── Layout (Root)
│   ├── Header
│   └── Main Content
│       └── Page Content
│
├── Auth Pages
│   ├── SignupPage
│   │   └── AuthForm
│   └── SigninPage
│       └── AuthForm
│
└── Tasks Pages
    ├── TasksListPage
    │   ├── TaskForm (create)
    │   └── TaskList
    │       └── TaskItem (multiple)
    └── TaskDetailPage
        ├── TaskDetail
        └── TaskForm (edit)
```

---

## Core Components

### Header
**Purpose**: Application navigation and user info

**Props**: None (uses auth context)

**State**:
- `user`: Current user from auth context
- `isSigningOut`: Loading state for signout

**UI Elements**:
- App logo/title
- User email display
- Signout button
- Navigation links (if authenticated)

**Styling**:
- Fixed header at top
- Dark background with light text
- Responsive (hamburger menu on mobile)

**Example**:
```tsx
// components/Header.tsx
export function Header() {
  const { user, signOut } = useAuth();

  return (
    <header className="bg-gray-900 text-white p-4">
      <div className="container mx-auto flex justify-between items-center">
        <h1 className="text-2xl font-bold">Todo App</h1>
        {user && (
          <div className="flex items-center gap-4">
            <span className="text-sm">{user.email}</span>
            <button onClick={signOut} className="btn-secondary">
              Sign Out
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
```

---

### AuthForm
**Purpose**: Reusable form for signup and signin

**Props**:
```typescript
interface AuthFormProps {
  mode: "signup" | "signin";
  onSubmit: (email: string, password: string) => Promise<void>;
}
```

**State**:
- `email`: string
- `password`: string
- `isSubmitting`: boolean
- `error`: string | null

**UI Elements**:
- Email input (type="email")
- Password input (type="password", show/hide toggle)
- Submit button
- Link to alternate mode (signup ↔ signin)
- Error message display

**Validation**:
- Email: required, valid format
- Password: required, min 8 characters

**Styling**:
- Centered card layout
- Clean, modern form design
- Inline validation errors
- Disabled state while submitting

**Example**:
```tsx
// components/AuthForm.tsx
export function AuthForm({ mode, onSubmit }: AuthFormProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);
    try {
      await onSubmit(email, password);
    } catch (err) {
      setError(err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="max-w-md mx-auto p-6 bg-white rounded-lg shadow">
      {/* Form fields */}
    </form>
  );
}
```

---

### TaskForm
**Purpose**: Create or edit tasks

**Props**:
```typescript
interface TaskFormProps {
  mode: "create" | "edit";
  initialData?: { title: string; description?: string };
  onSubmit: (data: { title: string; description?: string }) => Promise<void>;
  onCancel?: () => void;
}
```

**State**:
- `title`: string
- `description`: string
- `isSubmitting`: boolean
- `errors`: { title?: string; description?: string }

**UI Elements**:
- Title input (required)
- Description textarea (optional)
- Character count indicators
- Submit button
- Cancel button (edit mode only)

**Validation**:
- Title: 1-200 characters
- Description: max 1000 characters

**Styling**:
- Full-width form
- Clear visual hierarchy
- Inline validation errors
- Character counters (e.g., "45/200")

**Example**:
```tsx
// components/TaskForm.tsx
export function TaskForm({ mode, initialData, onSubmit, onCancel }: TaskFormProps) {
  const [title, setTitle] = useState(initialData?.title || "");
  const [description, setDescription] = useState(initialData?.description || "");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (title.trim().length === 0) return;

    setIsSubmitting(true);
    try {
      await onSubmit({ title: title.trim(), description: description.trim() || undefined });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Form fields */}
    </form>
  );
}
```

---

### TaskList
**Purpose**: Display list of tasks

**Props**:
```typescript
interface TaskListProps {
  tasks: Task[];
  onToggleComplete: (taskId: number) => Promise<void>;
  onDelete: (taskId: number) => Promise<void>;
}
```

**State**:
- `loadingTaskId`: number | null (for optimistic updates)

**UI Elements**:
- List of TaskItem components
- Empty state ("No tasks yet")
- Loading state (skeleton loaders)

**Styling**:
- Responsive grid/list layout
- Smooth transitions for add/remove
- Empty state with illustration

**Example**:
```tsx
// components/TaskList.tsx
export function TaskList({ tasks, onToggleComplete, onDelete }: TaskListProps) {
  if (tasks.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">No tasks yet. Create one above!</p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {tasks.map(task => (
        <TaskItem
          key={task.id}
          task={task}
          onToggleComplete={onToggleComplete}
          onDelete={onDelete}
        />
      ))}
    </div>
  );
}
```

---

### TaskItem
**Purpose**: Display individual task in list

**Props**:
```typescript
interface TaskItemProps {
  task: Task;
  onToggleComplete: (taskId: number) => Promise<void>;
  onDelete: (taskId: number) => Promise<void>;
}
```

**State**:
- `isDeleting`: boolean

**UI Elements**:
- Completion checkbox
- Task title
- Task description (truncated)
- Created date
- Quick action buttons (edit, delete)
- Click to view details

**Styling**:
- Card layout with hover effect
- Strikethrough for completed tasks
- Subtle animations for interactions
- Responsive layout

**Example**:
```tsx
// components/TaskItem.tsx
export function TaskItem({ task, onToggleComplete, onDelete }: TaskItemProps) {
  const [isDeleting, setIsDeleting] = useState(false);

  const handleDelete = async () => {
    if (!confirm("Delete this task?")) return;
    setIsDeleting(true);
    try {
      await onDelete(task.id);
    } catch {
      setIsDeleting(false);
    }
  };

  return (
    <div className="p-4 bg-white rounded-lg shadow hover:shadow-md transition">
      <div className="flex items-start gap-3">
        <input
          type="checkbox"
          checked={task.completed}
          onChange={() => onToggleComplete(task.id)}
          className="mt-1"
        />
        <div className="flex-1">
          <h3 className={task.completed ? "line-through text-gray-500" : ""}>
            {task.title}
          </h3>
          {task.description && (
            <p className="text-sm text-gray-600 truncate">{task.description}</p>
          )}
        </div>
        <button onClick={handleDelete} disabled={isDeleting}>
          Delete
        </button>
      </div>
    </div>
  );
}
```

---

### TaskDetail
**Purpose**: Display full task details

**Props**:
```typescript
interface TaskDetailProps {
  task: Task;
  onEdit: () => void;
  onDelete: () => Promise<void>;
  onToggleComplete: () => Promise<void>;
}
```

**UI Elements**:
- Task title (large)
- Task description (full)
- Completion status badge
- Created and updated timestamps
- Action buttons (edit, delete, toggle complete)

**Styling**:
- Card layout with generous padding
- Clear typography hierarchy
- Status badge with color coding
- Responsive layout

---

## Utility Components

### LoadingSpinner
Simple loading indicator

### ErrorMessage
Display error messages with retry option

### EmptyState
Display when no data is available

---

## Styling System

### Tailwind CSS Configuration
```javascript
// tailwind.config.js
module.exports = {
  content: ["./app/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#3b82f6",
        secondary: "#64748b",
        success: "#10b981",
        danger: "#ef4444",
      },
    },
  },
};
```

### Common Styles
```css
/* app/globals.css */
.btn-primary {
  @apply bg-primary text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition;
}

.btn-secondary {
  @apply bg-secondary text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition;
}

.input-field {
  @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary;
}
```

---

## Responsive Design

### Breakpoints
- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px

### Mobile Adaptations
- Stack form fields vertically
- Hamburger menu for navigation
- Full-width task cards
- Larger touch targets (min 44px)

### Desktop Enhancements
- Multi-column task grid
- Sidebar navigation
- Hover states
- Keyboard shortcuts
