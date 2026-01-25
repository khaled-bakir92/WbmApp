"""Bot Lifecycle Control Endpoints"""
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, status

from ..auth import AuthDep
from ..bot_manager import BotManager, get_bot_manager
from ..models import BotStartRequest, BotStatusResponse, BotActionResponse


router = APIRouter(prefix="/api/bot", tags=["Bot Lifecycle"])


@router.get("/status", response_model=BotStatusResponse)
async def get_bot_status(
    _: AuthDep,
    manager: Annotated[BotManager, Depends(get_bot_manager)],
) -> BotStatusResponse:
    """Get current bot status including PID, uptime, and resource usage."""
    status_data = manager.get_status()
    return BotStatusResponse(**status_data)


@router.post("/start", response_model=BotActionResponse)
async def start_bot(
    _: AuthDep,
    manager: Annotated[BotManager, Depends(get_bot_manager)],
    request: Optional[BotStartRequest] = None,
) -> BotActionResponse:
    """
    Start the bot with optional configuration.

    - **interval**: Check interval in seconds (default: 1800 = 30 minutes)
    - **gui**: Run browser with GUI (default: False = headless)
    """
    if request is None:
        request = BotStartRequest()

    success, message, pid = manager.start(
        interval=request.interval,
        gui=request.gui,
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=message,
        )

    return BotActionResponse(success=success, message=message, pid=pid)


@router.post("/stop", response_model=BotActionResponse)
async def stop_bot(
    _: AuthDep,
    manager: Annotated[BotManager, Depends(get_bot_manager)],
) -> BotActionResponse:
    """Stop the bot gracefully (SIGTERM, then SIGKILL after 10s)."""
    success, message = manager.stop()

    if not success:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=message,
        )

    return BotActionResponse(success=success, message=message, pid=None)


@router.post("/restart", response_model=BotActionResponse)
async def restart_bot(
    _: AuthDep,
    manager: Annotated[BotManager, Depends(get_bot_manager)],
    request: Optional[BotStartRequest] = None,
) -> BotActionResponse:
    """
    Restart the bot with optional new configuration.

    If configuration not provided, uses previous settings.
    """
    interval = request.interval if request else None
    gui = request.gui if request else None

    success, message, pid = manager.restart(interval=interval, gui=gui)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=message,
        )

    return BotActionResponse(success=success, message=message, pid=pid)
