# Quick Setup Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Set Up Neon PostgreSQL (2 minutes)

1. Go to https://neon.tech and create a free account
2. Click "Create Project"
3. Copy the connection string (looks like: `postgresql://user:password@host.neon.tech/dbname`)

### Step 2: Configure Environment Variables (1 minute)

#### Backend
```bash
cd backend
cp .env.example .env
```

Edit `backend/.env` and add:
```bash
DATABASE_URL=<your-neon-connection-string>
BETTER_AUTH_SECRET=<generate-random-32-char-string>
CORS_ORIGINS=http://localhost:3000
```

#### Frontend
```bash
cd frontend
cp .env.local.example .env.local
```

Edit `frontend/.env.local` and add:
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_AUTH_URL=http://localhost:3000
BETTER_AUTH_SECRET=<same-secret-as-backend>
```

### Step 3: Install Dependencies (1 minute)

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

### Step 4: Run the Application (1 minute)

#### Terminal 1 - Backend
```bash
cd backend
uv run uvicorn main:app --reload --port 8000
```

#### Terminal 2 - Frontend
```bash
cd frontend
npm run dev
```

### Step 5: Test It Out!

1. Open http://localhost:3000
2. Click "Sign Up" and create an account
3. Create your first task!

---

## 🐳 Alternative: Docker Compose

If you have Docker installed:

```bash
# Set environment variables in .env file at root
DATABASE_URL=<your-neon-connection-string>
BETTER_AUTH_SECRET=<your-secret-key>

# Run both services
docker-compose up --build
```

---

## 🔑 Generate Secret Key

```bash
# On Windows PowerShell
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((New-Guid).ToString() + (New-Guid).ToString()))

# On Linux/Mac
openssl rand -base64 32
```

---

## ✅ Verify Everything Works

1. **Backend Health Check**: http://localhost:8000/health
2. **API Documentation**: http://localhost:8000/docs
3. **Frontend**: http://localhost:3000

---

## 🆘 Troubleshooting

**Backend won't start?**
- Check DATABASE_URL is correct
- Check BETTER_AUTH_SECRET is set
- Run `uv sync --dev` again

**Frontend won't start?**
- Run `npm install` again
- Check .env.local exists
- Delete `.next` folder and restart

**Can't create tasks?**
- Check backend is running on port 8000
- Check CORS_ORIGINS includes http://localhost:3000
- Check browser console for errors

---

## 📚 Next Steps

- Read `walkthrough.md` for complete documentation
- Check `specs/` for detailed specifications
- See `README.md` for full project documentation
