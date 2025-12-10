# Todo Backend API

FastAPI backend for the Todo application with JWT authentication and PostgreSQL database.

## Setup

### Prerequisites
- Python 3.13+
- UV package manager
- Neon PostgreSQL database

### Installation

1. Install dependencies:
```bash
uv sync --dev
```

2. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your database URL and secret key
```

3. Set up Neon PostgreSQL:
   - Create account at https://neon.tech
   - Create a new database
   - Copy connection string to `.env` as `DATABASE_URL`

## Running

### Development
```bash
uv run uvicorn main:app --reload --port 8000
```

### Production
```bash
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Health Check
- `GET /health` - Check API health

### Tasks
All task endpoints require JWT authentication via `Authorization: Bearer <token>` header.

- `GET /api/{user_id}/tasks` - List all tasks
- `POST /api/{user_id}/tasks` - Create task
- `GET /api/{user_id}/tasks/{id}` - Get task details
- `PUT /api/{user_id}/tasks/{id}` - Update task
- `DELETE /api/{user_id}/tasks/{id}` - Delete task
- `PATCH /api/{user_id}/tasks/{id}/complete` - Toggle completion

## Testing

```bash
# Run all tests
uv run pytest -v

# Run with coverage
uv run pytest -v --cov=. --cov-report=term-missing

# Type checking
uv run mypy .
```

## Environment Variables

Required variables in `.env`:

```bash
DATABASE_URL=postgresql://user:password@host.neon.tech/dbname?sslmode=require
BETTER_AUTH_SECRET=your-secret-key-min-32-chars-same-as-frontend
CORS_ORIGINS=http://localhost:3000
```

## Project Structure

```
backend/
├── main.py              # FastAPI app entry point
├── models.py            # SQLModel database models
├── db.py                # Database connection
├── auth.py              # JWT verification
├── routes/              # API route handlers
│   ├── tasks.py
│   └── health.py
├── tests/               # Test files
├── .env                 # Environment variables (not committed)
├── .env.example         # Environment template
└── pyproject.toml       # UV configuration
```
