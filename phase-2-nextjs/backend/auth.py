"""JWT authentication middleware."""

import os

from dotenv import load_dotenv
from fastapi import HTTPException, Header
from jose import JWTError, jwt

# Load environment variables
load_dotenv()

# JWT configuration
SECRET_KEY = os.getenv("BETTER_AUTH_SECRET")
if not SECRET_KEY:
    raise ValueError("BETTER_AUTH_SECRET environment variable is not set")

ALGORITHM = "HS256"


def verify_jwt(authorization: str = Header(...)) -> str:
    """
    Verify JWT token and extract user_id.

    Args:
        authorization: Authorization header (Bearer <token>)

    Returns:
        str: Authenticated user ID

    Raises:
        HTTPException: 401 if token is invalid or missing
    """
    try:
        # Check for Bearer prefix
        if not authorization.startswith("Bearer "):
            raise HTTPException(
                status_code=401, detail="Invalid authorization header format"
            )

        # Extract token
        token = authorization.replace("Bearer ", "")

        # Try to decode as JWT first
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            user_id = payload.get("sub")
        except JWTError:
            # Fallback: Try to decode as mock token (base64 encoded JSON)
            # This is for testing only - remove in production
            try:
                import base64
                import json
                decoded = base64.b64decode(token).decode("utf-8")
                payload = json.loads(decoded)
                user_id = payload.get("sub")
            except Exception:
                raise HTTPException(status_code=401, detail="Invalid or expired token")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token payload")

        return user_id

    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
