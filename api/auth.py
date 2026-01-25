"""Bearer Token Authentication"""
import secrets
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from .config import get_settings, Settings


security = HTTPBearer()


def verify_token(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
    settings: Annotated[Settings, Depends(get_settings)],
) -> bool:
    """
    Verify the Bearer token from the Authorization header.

    Uses timing-safe comparison to prevent timing attacks.
    """
    if not settings.api_token:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="API token not configured. Check .env file.",
        )

    token = credentials.credentials

    # Timing-safe comparison
    if not secrets.compare_digest(token.encode(), settings.api_token.encode()):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return True


# Dependency for protected routes
AuthDep = Annotated[bool, Depends(verify_token)]
