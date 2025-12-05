# Feature: User Authentication

## User Stories

### US-1: User Signup
**As a** new user
**I want to** create an account with email and password
**So that** I can start using the todo application

### US-2: User Signin
**As a** registered user
**I want to** sign in with my email and password
**So that** I can access my tasks

### US-3: User Signout
**As a** logged-in user
**I want to** sign out of my account
**So that** I can protect my data on shared devices

### US-4: Session Persistence
**As a** logged-in user
**I want to** stay logged in when I refresh the page
**So that** I don't have to sign in repeatedly

## Acceptance Criteria

### Signup (US-1)
- ✅ Email is required and must be valid format
- ✅ Password is required (min 8 characters)
- ✅ Email must be unique (no duplicate accounts)
- ✅ Password is hashed before storage (bcrypt)
- ✅ User record is created in database
- ✅ JWT token is generated and returned
- ✅ User is redirected to tasks page
- ✅ Success message is displayed
- ❌ Invalid email format returns 400 Bad Request
- ❌ Password < 8 characters returns 400 Bad Request
- ❌ Duplicate email returns 409 Conflict

### Signin (US-2)
- ✅ Email and password are required
- ✅ Credentials are verified against database
- ✅ JWT token is generated on successful signin
- ✅ Token is stored in localStorage
- ✅ User is redirected to tasks page
- ✅ Success message is displayed
- ❌ Invalid credentials return 401 Unauthorized
- ❌ Non-existent email returns 401 Unauthorized
- ❌ Wrong password returns 401 Unauthorized

### Signout (US-3)
- ✅ JWT token is removed from localStorage
- ✅ User is redirected to signin page
- ✅ Attempting to access protected routes redirects to signin
- ✅ Success message is displayed

### Session Persistence (US-4)
- ✅ JWT token persists in localStorage across page refreshes
- ✅ Token is validated on app initialization
- ✅ Expired tokens are removed and user is redirected to signin
- ✅ Invalid tokens are removed and user is redirected to signin
- ✅ Valid tokens allow access to protected routes

## Technical Implementation

### Better Auth Configuration

#### Frontend Setup
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

#### Backend JWT Verification
```python
# backend/auth.py
from jose import jwt, JWTError
from fastapi import HTTPException, Header
import os

SECRET_KEY = os.getenv("BETTER_AUTH_SECRET")
ALGORITHM = "HS256"

def verify_jwt(authorization: str = Header(...)) -> str:
    """Verify JWT token and return user_id"""
    try:
        token = authorization.replace("Bearer ", "")
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

### JWT Token Structure

```json
{
  "sub": "user-uuid-here",           // User ID
  "email": "user@example.com",       // User email
  "iat": 1234567890,                 // Issued at timestamp
  "exp": 1234567890,                 // Expiry timestamp (7 days)
  "iss": "better-auth"               // Issuer
}
```

### API Integration

#### Request Headers
All authenticated API requests must include:
```
Authorization: Bearer <jwt-token>
```

#### Frontend API Client
```typescript
// lib/api.ts
import { authClient } from "./auth";

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
  async getTasks() {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/api/tasks`, { headers });
    return response.json();
  },
  // ... other methods
};
```

## Data Model

### User (Managed by Better Auth)
```typescript
interface User {
  id: string;                    // UUID primary key
  email: string;                 // Unique, required
  name: string | null;           // Optional display name
  password_hash: string;         // bcrypt hashed password
  created_at: Date;              // Auto-generated
  updated_at: Date;              // Auto-updated
}
```

## Validation Rules

### Email
- **Required**: Yes
- **Format**: Valid email format (regex validation)
- **Unique**: Must not already exist in database
- **Max Length**: 255 characters

### Password
- **Required**: Yes
- **Min Length**: 8 characters
- **Recommendations**: Include uppercase, lowercase, number, special character
- **Storage**: Never stored in plain text, always bcrypt hashed

## UI/UX Requirements

### Signup Page
- Email input field with validation
- Password input field with show/hide toggle
- Password strength indicator
- Submit button (disabled while submitting)
- Link to signin page for existing users
- Display validation errors inline
- Show success message on completion

### Signin Page
- Email input field
- Password input field with show/hide toggle
- "Remember me" checkbox (optional for Phase II)
- Submit button (disabled while submitting)
- Link to signup page for new users
- "Forgot password" link (not implemented in Phase II)
- Display error messages for invalid credentials

### Protected Routes
- Check for valid JWT token before rendering
- Redirect to signin if not authenticated
- Show loading state while verifying token
- Preserve intended destination for post-login redirect

### Header/Navigation
- Display user email when logged in
- Signout button
- Confirmation dialog for signout (optional)

## Security Requirements

### Password Security
- Minimum 8 characters enforced
- Hashed with bcrypt (cost factor 12)
- Never transmitted in plain text except during signup/signin over HTTPS
- Never logged or stored in plain text

### Token Security
- JWT signed with strong secret (min 32 characters)
- Secret stored in environment variables only
- Tokens expire after 7 days
- Tokens include user_id in payload
- Signature verified on every API request

### Session Security
- Tokens stored in localStorage (httpOnly cookies in future enhancement)
- Tokens removed on signout
- Expired tokens automatically cleared
- No sensitive data in JWT payload (only user_id and email)

### HTTPS Requirement
- All authentication endpoints require HTTPS in production
- Development can use HTTP for localhost only

## Error Handling

### Signup Errors
- **400 Bad Request**: Invalid email format, password too short
- **409 Conflict**: Email already exists
- **500 Internal Server Error**: Database error, show generic message

### Signin Errors
- **401 Unauthorized**: Invalid credentials (don't specify if email or password is wrong)
- **500 Internal Server Error**: Database error, show generic message

### Token Errors
- **401 Unauthorized**: Invalid, expired, or missing token
- **403 Forbidden**: Valid token but insufficient permissions (future)

## Environment Variables

### Frontend (.env.local)
```bash
NEXT_PUBLIC_AUTH_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:8000
BETTER_AUTH_SECRET=<shared-secret-key>
```

### Backend (.env)
```bash
DATABASE_URL=postgresql://user:pass@host/db
BETTER_AUTH_SECRET=<same-shared-secret-key>
CORS_ORIGINS=http://localhost:3000
```

## Testing Requirements

### Unit Tests
- JWT token generation and verification
- Password hashing and verification
- Email validation
- User creation with duplicate email

### Integration Tests
- Complete signup flow
- Complete signin flow
- Signout flow
- Protected route access with valid token
- Protected route access with invalid token
- Protected route access with expired token

### Manual Testing
- Signup with valid credentials
- Signup with duplicate email
- Signin with valid credentials
- Signin with invalid credentials
- Access tasks page while authenticated
- Refresh page while authenticated (session persists)
- Signout and verify redirect
- Attempt to access tasks page while not authenticated
