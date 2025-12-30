# Authentication & Authorization Skills

## JWT Authentication

### Implementation
```javascript
const jwt = require('jsonwebtoken');

// Generate token
function generateToken(user) {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role
    },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );
}

// Verify token middleware
async function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

## Password Security

### Hashing with bcrypt
```javascript
const bcrypt = require('bcrypt');

// Hash password (registration)
async function hashPassword(password) {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
}

// Verify password (login)
async function verifyPassword(password, hashedPassword) {
  return await bcrypt.compare(password, hashedPassword);
}
```

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

## OAuth 2.0

### Authorization Code Flow
1. Redirect user to OAuth provider
2. User grants permission
3. Receive authorization code
4. Exchange code for access token
5. Use token to access resources

### PKCE (for SPAs)
```javascript
// Generate code verifier and challenge
const crypto = require('crypto');

function generateCodeVerifier() {
  return crypto.randomBytes(32).toString('base64url');
}

function generateCodeChallenge(verifier) {
  return crypto
    .createHash('sha256')
    .update(verifier)
    .digest('base64url');
}
```

## Session Management

```javascript
const session = require('express-session');
const RedisStore = require('connect-redis').default;
const redis = require('redis');

const redisClient = redis.createClient();

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));
```

## Role-Based Access Control (RBAC)

```javascript
const ROLES = {
  ADMIN: 'admin',
  USER: 'user',
  GUEST: 'guest'
};

const PERMISSIONS = {
  admin: ['read', 'write', 'delete'],
  user: ['read', 'write'],
  guest: ['read']
};

function checkPermission(requiredRole) {
  return (req, res, next) => {
    if (!PERMISSIONS[req.user.role].includes(requiredRole)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
}

// Usage
app.delete('/api/users/:id', authMiddleware, checkPermission('delete'), deleteUser);
```

## Multi-Factor Authentication (MFA)

### TOTP Implementation
```javascript
const speakeasy = require('speakeasy');

// Generate secret
const secret = speakeasy.generateSecret({ length: 20 });

// Verify token
const verified = speakeasy.totp.verify({
  secret: secret.base32,
  encoding: 'base32',
  token: userToken
});
```

## Security Checklist
- [ ] Use HTTPS everywhere
- [ ] Implement rate limiting
- [ ] Validate all inputs
- [ ] Use secure session management
- [ ] Implement CSRF protection
- [ ] Set security headers (helmet.js)
- [ ] Log authentication events
- [ ] Regular security audits
- [ ] Keep dependencies updated
- [ ] Implement account lockout after failed attempts
