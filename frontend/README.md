# Todo Frontend

Next.js frontend for the Todo application with authentication.

## Setup

### Prerequisites
- Node.js 20+
- npm

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.local.example .env.local
# Edit .env.local with your configuration
```

## Running

### Development
```bash
npm run dev
```

Visit http://localhost:3000

### Production Build
```bash
npm run build
npm start
```

## Project Structure

```
frontend/
├── app/                    # Next.js App Router
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Landing page
│   ├── signin/            # Signin page
│   ├── signup/            # Signup page
│   └── tasks/             # Tasks page
├── components/             # React components
│   ├── Header.tsx
│   ├── TaskForm.tsx
│   ├── TaskItem.tsx
│   └── TaskList.tsx
├── lib/                    # Utilities
│   ├── api.ts             # API client
│   └── auth.ts            # Auth utilities
├── types/                  # TypeScript types
│   └── task.ts
└── public/                 # Static assets
```

## Environment Variables

Required in `.env.local`:

```bash
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_AUTH_URL=http://localhost:3000
BETTER_AUTH_SECRET=your-secret-key-same-as-backend
```

## Features

- ✅ User authentication (signup/signin)
- ✅ Create tasks
- ✅ List tasks
- ✅ Toggle task completion
- ✅ Delete tasks
- ✅ Responsive design
- ✅ Form validation
- ✅ Error handling

## Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Authentication**: JWT tokens (Better Auth integration pending)

## Development

### Type Checking
```bash
npm run type-check
```

### Linting
```bash
npm run lint
```

## Notes

- Current implementation uses simplified JWT auth
- Better Auth integration is planned for future iteration
- All API calls require authentication token
