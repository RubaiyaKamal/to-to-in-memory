# Todo App - Phase II: Full-Stack Web Application

A modern full-stack todo application with Next.js frontend, FastAPI backend, and PostgreSQL database.

## 🚀 Features

- ✅ User authentication with JWT tokens
- ✅ Create, read, update, delete tasks
- ✅ Mark tasks as complete/incomplete
- ✅ User isolation (users only see their own tasks)
- ✅ Persistent storage in PostgreSQL
- ✅ Responsive web interface
- ✅ RESTful API

## 📁 Project Structure

```
to-do-in-memory/
├── .spec-kit/              # Spec-Kit Plus configuration
├── specs/                  # Specifications
│   ├── overview.md
│   ├── architecture.md
│   ├── features/
│   ├── api/
│   ├── database/
│   └── ui/
├── frontend/               # Next.js application
│   ├── app/               # Pages and layouts
│   ├── components/        # React components
│   └── lib/               # Utilities
├── backend/                # FastAPI application
│   ├── main.py
│   ├── models.py
│   ├── routes/
│   └── db.py
├── legacy/                 # Phase I console app
├── docker-compose.yml
└── README.md
```

## 🛠️ Tech Stack

### Frontend
- Next.js 15 (App Router)
- React 19
- TypeScript
- Tailwind CSS

### Backend
- FastAPI
- SQLModel (ORM)
- Python 3.13
- UV package manager

### Database
- Neon Serverless PostgreSQL

## 📋 Prerequisites

- **Node.js** 20+
- **Python** 3.13+
- **UV** package manager
- **Neon PostgreSQL** account

## 🚀 Quick Start

### 1. Set up Neon PostgreSQL

1. Create account at [https://neon.tech](https://neon.tech)
2. Create a new database
3. Copy the connection string

### 2. Configure Environment Variables

#### Backend
```bash
cd backend
cp .env.example .env
# Edit .env and add:
# - DATABASE_URL (from Neon)
# - BETTER_AUTH_SECRET (generate a random 32+ character string)
# - CORS_ORIGINS=http://localhost:3000
```

#### Frontend
```bash
cd frontend
cp .env.local.example .env.local
# Edit .env.local and add:
# - NEXT_PUBLIC_API_URL=http://localhost:8000
# - BETTER_AUTH_SECRET (same as backend)
```

### 3. Install Dependencies

#### Backend
```bash
cd backend
uv sync --dev
```

#### Frontend
```bash
cd frontend
npm install
```

### 4. Run the Application

#### Option A: Run Separately

**Terminal 1 - Backend:**
```bash
cd backend
uv run uvicorn main:app --reload --port 8000
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

#### Option B: Run with Docker Compose

```bash
# From project root
docker-compose up --build
```

### 5. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

## 📖 Usage

1. **Sign Up**: Create a new account at `/signup`
2. **Sign In**: Log in at `/signin`
3. **Create Tasks**: Add new tasks with title and description
4. **Manage Tasks**: Toggle completion, delete tasks
5. **Sign Out**: Click sign out in the header

## 🧪 Testing

### Backend Tests
```bash
cd backend
uv run pytest -v --cov
```

### Frontend Type Checking
```bash
cd frontend
npm run type-check
```

## 📚 Documentation

- **Architecture**: See `specs/architecture.md`
- **API Endpoints**: See `specs/api/rest-endpoints.md`
- **Database Schema**: See `specs/database/schema.md`
- **Frontend Guidelines**: See `frontend/CLAUDE.md`
- **Backend Guidelines**: See `backend/CLAUDE.md`

## 🔐 Security

- JWT token authentication
- User isolation (users only see their own tasks)
- Password hashing (when Better Auth is integrated)
- CORS protection
- Input validation

## 🗺️ Roadmap

### Phase I ✅
- Console application with in-memory storage

### Phase II 🚧 (Current)
- Full-stack web application
- PostgreSQL database
- JWT authentication
- RESTful API

### Phase III 📋 (Future)
- AI chatbot interface
- Better Auth integration
- OAuth providers (Google, GitHub)
- Advanced features

## 📝 Development Workflow

1. Read relevant spec: `@specs/features/[feature].md`
2. Implement backend: `@backend/CLAUDE.md`
3. Implement frontend: `@frontend/CLAUDE.md`
4. Test and verify
5. Update specs if needed

## 🤝 Contributing

This is a learning project following spec-driven development practices.

## 📄 License

Educational project - Phase II of Hackathon Todo App

## 🙏 Acknowledgments

- Built with Spec-Kit Plus and Claude Code
- Following spec-driven development methodology
