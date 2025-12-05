# Todo App Overview

## Purpose
A todo application that evolves from console app to full-stack web application to AI chatbot interface, demonstrating spec-driven development with modern technologies.

## Current Phase
**Phase II: Full-Stack Web Application**

## Tech Stack

### Frontend
- **Framework**: Next.js 16+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Authentication**: Better Auth with JWT

### Backend
- **Framework**: FastAPI
- **ORM**: SQLModel
- **Database**: Neon Serverless PostgreSQL
- **Authentication**: JWT token verification

### Development
- **Monorepo**: Single repository with frontend and backend
- **Spec-Driven**: GitHub Spec-Kit Plus
- **AI Assistant**: Claude Code
- **Containerization**: Docker Compose

## Features

### Phase I: Console App ✅
- [x] Add tasks with title and description
- [x] List all tasks with status
- [x] Show specific task details
- [x] Update task title and description
- [x] Delete tasks by ID
- [x] Mark tasks as complete/incomplete

### Phase II: Web Application 🚧
- [ ] User signup and signin
- [ ] JWT-based authentication
- [ ] RESTful API endpoints
- [ ] Responsive web interface
- [ ] Multi-user support
- [ ] Persistent storage in PostgreSQL
- [ ] Task CRUD via web UI
- [ ] User isolation (users only see their tasks)

### Phase III: AI Chatbot 📋
- [ ] Natural language task management
- [ ] Chatbot interface
- [ ] AI-powered task suggestions
- [ ] Voice input support

## Architecture Principles

1. **Separation of Concerns**: Frontend, backend, and database are clearly separated
2. **API-First**: Backend exposes RESTful API consumed by frontend
3. **Security**: JWT authentication, user isolation, secure password storage
4. **Scalability**: Serverless database, stateless API, containerized services
5. **Developer Experience**: Hot reload, type safety, comprehensive testing
