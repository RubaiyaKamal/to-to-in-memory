# Database Schema

## Overview
- **Database**: Neon Serverless PostgreSQL
- **ORM**: SQLModel (combines SQLAlchemy + Pydantic)
- **Migrations**: Alembic (future enhancement)

---

## Tables

### users
Managed by Better Auth. Stores user authentication information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | VARCHAR(36) | PRIMARY KEY | UUID user identifier |
| email | VARCHAR(255) | UNIQUE, NOT NULL | User email address |
| name | VARCHAR(255) | NULL | User display name (optional) |
| password_hash | VARCHAR(255) | NOT NULL | bcrypt hashed password |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Account creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Indexes**:
- PRIMARY KEY on `id`
- UNIQUE INDEX on `email`

**SQL**:
```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email ON users(email);
```

---

### tasks
Stores todo tasks with user ownership.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Auto-incrementing task ID |
| user_id | VARCHAR(36) | FOREIGN KEY, NOT NULL | Owner user ID |
| title | VARCHAR(200) | NOT NULL | Task title |
| description | TEXT | NULL | Task description (optional) |
| completed | BOOLEAN | NOT NULL, DEFAULT FALSE | Completion status |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Task creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Foreign Keys**:
- `user_id` REFERENCES `users(id)` ON DELETE CASCADE

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `user_id` (for filtering tasks by user)
- INDEX on `completed` (for filtering by status)
- INDEX on `created_at` (for sorting)

**SQL**:
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_completed ON tasks(completed);
CREATE INDEX idx_tasks_created_at ON tasks(created_at DESC);
```

---

## SQLModel Models

### User Model
```python
# backend/models.py
from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional

class User(SQLModel, table=True):
    __tablename__ = "users"

    id: str = Field(primary_key=True)
    email: str = Field(unique=True, index=True, max_length=255)
    name: Optional[str] = Field(default=None, max_length=255)
    password_hash: str = Field(max_length=255)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
```

### Task Model
```python
# backend/models.py
from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional

class Task(SQLModel, table=True):
    __tablename__ = "tasks"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(foreign_key="users.id", index=True)
    title: str = Field(max_length=200)
    description: Optional[str] = Field(default=None)
    completed: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
```

### Request/Response Models
```python
# backend/models.py
from pydantic import BaseModel, Field

class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)

class TaskUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)

class TaskResponse(BaseModel):
    id: int
    user_id: str
    title: str
    description: Optional[str]
    completed: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
```

---

## Relationships

```mermaid
erDiagram
    users ||--o{ tasks : owns

    users {
        varchar id PK
        varchar email UK
        varchar name
        varchar password_hash
        timestamp created_at
        timestamp updated_at
    }

    tasks {
        serial id PK
        varchar user_id FK
        varchar title
        text description
        boolean completed
        timestamp created_at
        timestamp updated_at
    }
```

**Relationship Rules**:
- One user can have many tasks (1:N)
- Each task belongs to exactly one user
- Deleting a user cascades to delete all their tasks
- Tasks cannot exist without a user (enforced by foreign key)

---

## Data Constraints

### Business Rules
1. **User Email Uniqueness**: No two users can have the same email
2. **Task Ownership**: Every task must belong to a user
3. **Title Required**: Tasks must have a non-empty title
4. **Cascade Delete**: Deleting a user deletes all their tasks
5. **Timestamps**: All records have creation and update timestamps

### Validation Rules
1. **Email Format**: Must be valid email format (validated in application layer)
2. **Title Length**: 1-200 characters
3. **Description Length**: 0-1000 characters (optional)
4. **Password**: Minimum 8 characters (validated before hashing)

---

## Indexes Strategy

### Performance Optimization
1. **Primary Keys**: Automatic indexes for fast lookups
2. **User Email**: Unique index for fast authentication queries
3. **Task User ID**: Index for filtering tasks by user (most common query)
4. **Task Completed**: Index for filtering by completion status
5. **Task Created At**: Index for sorting tasks by creation date

### Query Patterns
```sql
-- Most common queries (all use indexes)

-- Get all tasks for a user (uses idx_tasks_user_id)
SELECT * FROM tasks WHERE user_id = 'user-uuid-123' ORDER BY created_at DESC;

-- Get pending tasks for a user (uses idx_tasks_user_id + idx_tasks_completed)
SELECT * FROM tasks WHERE user_id = 'user-uuid-123' AND completed = FALSE;

-- Get user by email (uses idx_users_email)
SELECT * FROM users WHERE email = 'user@example.com';

-- Get specific task for user (uses PRIMARY KEY + idx_tasks_user_id)
SELECT * FROM tasks WHERE id = 1 AND user_id = 'user-uuid-123';
```

---

## Database Initialization

### Using SQLModel
```python
# backend/db.py
from sqlmodel import SQLModel, create_engine, Session
from models import User, Task
import os

DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL, echo=True)

def init_db():
    """Create all tables"""
    SQLModel.metadata.create_all(engine)

def get_session():
    """Get database session"""
    with Session(engine) as session:
        yield session
```

### Environment Variable
```bash
# .env
DATABASE_URL=postgresql://user:password@host.neon.tech/dbname?sslmode=require
```

---

## Migration Strategy

### Phase II (Current)
- Use `SQLModel.metadata.create_all()` for table creation
- No migration files (simple schema)
- Drop and recreate for schema changes (development only)

### Future Enhancement (Phase III+)
- Implement Alembic for migrations
- Version control schema changes
- Support production migrations without data loss

```bash
# Future migration commands
alembic init alembic
alembic revision --autogenerate -m "Initial schema"
alembic upgrade head
```

---

## Data Retention

### Phase II
- No automatic data deletion
- Users can manually delete tasks
- Deleting user account deletes all tasks (CASCADE)

### Future Enhancement
- Soft delete with `deleted_at` timestamp
- Archive old completed tasks
- Data export functionality

---

## Security Considerations

### Password Storage
- Never store plain text passwords
- Use bcrypt with cost factor 12
- Password hash stored in `password_hash` column

### User Isolation
- All task queries MUST filter by `user_id`
- Foreign key constraint prevents orphaned tasks
- Application layer enforces user_id from JWT token

### SQL Injection Prevention
- SQLModel ORM uses parameterized queries
- Never concatenate user input into SQL
- Pydantic validation before database operations

---

## Backup & Recovery

### Neon PostgreSQL Features
- Automatic daily backups (Neon managed)
- Point-in-time recovery (Neon Pro plan)
- Database branching for testing

### Recommendations
- Enable Neon automatic backups
- Test restore process periodically
- Export critical data for redundancy
