"""Configuration File Management Endpoints"""
import fcntl
import json
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status

from ..auth import AuthDep
from ..config import Settings, get_settings
from ..models import FilterConfig, UserConfig, UserConfigResponse, UserConfigUpdate


router = APIRouter(prefix="/api/config", tags=["Configuration"])


def read_json_file(path) -> dict:
    """Read JSON file with file locking."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            fcntl.flock(f.fileno(), fcntl.LOCK_SH)
            try:
                return json.load(f)
            finally:
                fcntl.flock(f.fileno(), fcntl.LOCK_UN)
    except FileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Configuration file not found: {path.name}",
        )
    except json.JSONDecodeError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Invalid JSON in {path.name}: {str(e)}",
        )


def write_json_file(path, data: dict) -> None:
    """Write JSON file with file locking."""
    try:
        with open(path, "w", encoding="utf-8") as f:
            fcntl.flock(f.fileno(), fcntl.LOCK_EX)
            try:
                json.dump(data, f, indent=4, ensure_ascii=False)
            finally:
                fcntl.flock(f.fileno(), fcntl.LOCK_UN)
    except PermissionError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Permission denied writing to {path.name}",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to write {path.name}: {str(e)}",
        )


# ============== Filter Configuration ==============

@router.get("/filter", response_model=FilterConfig)
async def get_filter_config(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
) -> FilterConfig:
    """Get current filter configuration."""
    data = read_json_file(settings.filter_config)
    return FilterConfig(**data)


@router.put("/filter", response_model=FilterConfig)
async def update_filter_config(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
    config: FilterConfig,
) -> FilterConfig:
    """
    Update filter configuration.

    Note: Changes take effect on the bot's next check cycle.
    The bot reloads filter.json on each iteration.
    """
    # Validate and convert to dict
    data = config.model_dump()

    # Write to file
    write_json_file(settings.filter_config, data)

    return config


# ============== User Configuration ==============

def mask_password(password: str) -> str:
    """Mask password showing only first and last 2 characters."""
    if len(password) <= 4:
        return "****"
    return f"{password[:2]}{'*' * (len(password) - 4)}{password[-2:]}"


@router.get("/user", response_model=UserConfigResponse)
async def get_user_config(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
) -> UserConfigResponse:
    """
    Get current user configuration.

    Note: SMTP password is masked for security.
    """
    data = read_json_file(settings.user_config)

    # Mask the SMTP password
    notification_email = data.get("notification_email", {}).copy()
    if "password" in notification_email:
        notification_email["password"] = mask_password(notification_email["password"])

    return UserConfigResponse(
        user_data=data.get("user_data", {}),
        notification_email=notification_email,
    )


@router.put("/user", response_model=UserConfigResponse)
async def update_user_config(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
    config: UserConfigUpdate,
) -> UserConfigResponse:
    """
    Update user configuration (partial update supported).

    Only provided fields will be updated. Omit fields to keep existing values.
    """
    # Read existing config
    existing = read_json_file(settings.user_config)

    # Update only provided fields
    if config.user_data is not None:
        existing["user_data"] = config.user_data.model_dump()

    if config.notification_email is not None:
        existing["notification_email"] = config.notification_email.model_dump()

    # Write updated config
    write_json_file(settings.user_config, existing)

    # Return with masked password
    notification_email = existing.get("notification_email", {}).copy()
    if "password" in notification_email:
        notification_email["password"] = mask_password(notification_email["password"])

    return UserConfigResponse(
        user_data=existing.get("user_data", {}),
        notification_email=notification_email,
    )
