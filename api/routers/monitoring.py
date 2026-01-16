"""Monitoring Endpoints for Logs, Stats, and Screenshots"""
import json
import os
import re
from collections import deque
from datetime import datetime, timedelta
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import FileResponse

from ..auth import AuthDep
from ..bot_manager import BotManager, get_bot_manager
from ..config import Settings, get_settings
from ..models import BotStats, LogsResponse, ScreenshotInfo, ScreenshotsListResponse


router = APIRouter(prefix="/api/monitor", tags=["Monitoring"])


def parse_log_timestamp(line: str) -> datetime | None:
    """Parse timestamp from log line (format: 2024-01-15 14:30:45,123)."""
    match = re.match(r"(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})", line)
    if match:
        try:
            return datetime.strptime(match.group(1), "%Y-%m-%d %H:%M:%S")
        except ValueError:
            pass
    return None


def tail_file(path: Path, lines: int = 100) -> tuple[list[str], int, int]:
    """
    Efficiently read last N lines of a file.

    Returns:
        Tuple of (lines, total_lines_estimate, file_size)
    """
    if not path.exists():
        return [], 0, 0

    file_size = path.stat().st_size

    with open(path, "r", encoding="utf-8", errors="replace") as f:
        # Use deque for efficient tail reading
        result = deque(f, maxlen=lines)
        # Count approximate total lines (rough estimate)
        f.seek(0)
        total_lines = sum(1 for _ in f)

    return list(result), total_lines, file_size


@router.get("/stats", response_model=BotStats)
async def get_bot_stats(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
    manager: Annotated[BotManager, Depends(get_bot_manager)],
) -> BotStats:
    """
    Get bot statistics from logs and data files.

    Includes known listings count, last check time, error counts, etc.
    """
    stats = BotStats(
        known_listings_count=0,
        bot_running=manager.is_running(),
    )

    # Count known listings
    if settings.known_listings.exists():
        try:
            with open(settings.known_listings, "r") as f:
                listings = json.load(f)
                stats.known_listings_count = len(listings)
        except (json.JSONDecodeError, IOError):
            pass

    # Parse log file for stats
    if settings.log_file.exists():
        lines, _, _ = tail_file(settings.log_file, lines=1000)
        now = datetime.now()
        errors_24h = 0
        last_check = None
        last_listing = None

        for line in reversed(lines):
            ts = parse_log_timestamp(line)

            # Count errors in last 24h
            if " - ERROR - " in line and ts:
                if now - ts < timedelta(hours=24):
                    errors_24h += 1

            # Find last check time
            if last_check is None and "Überprüfe auf neue Angebote" in line and ts:
                last_check = ts

            # Find last listing found
            if last_listing is None and "Neues gefiltertes Angebot gefunden" in line and ts:
                last_listing = ts

            # Count form submissions
            if "Formular für" in line and "erfolgreich abgesendet" in line:
                stats.total_forms_submitted += 1

        stats.last_check_time = last_check
        stats.last_listing_found = last_listing
        stats.total_errors_24h = errors_24h

    return stats


@router.get("/logs", response_model=LogsResponse)
async def get_logs(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
    lines: int = Query(default=100, ge=1, le=5000, description="Number of lines to return"),
) -> LogsResponse:
    """
    Get last N lines of the bot log file.

    - **lines**: Number of lines to return (1-5000, default: 100)
    """
    if not settings.log_file.exists():
        return LogsResponse(lines=[], total_lines=0, file_size_bytes=0)

    log_lines, total, size = tail_file(settings.log_file, lines=lines)

    return LogsResponse(
        lines=log_lines,
        total_lines=total,
        file_size_bytes=size,
    )


@router.get("/screenshots", response_model=ScreenshotsListResponse)
async def list_screenshots(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
) -> ScreenshotsListResponse:
    """List all available screenshot files in the data directory."""
    screenshots = []

    if settings.data_dir.exists():
        for path in settings.data_dir.glob("*.png"):
            try:
                stat = path.stat()
                screenshots.append(ScreenshotInfo(
                    filename=path.name,
                    size_bytes=stat.st_size,
                    modified_at=datetime.fromtimestamp(stat.st_mtime),
                ))
            except OSError:
                continue

    # Sort by modification time (newest first)
    screenshots.sort(key=lambda x: x.modified_at, reverse=True)

    return ScreenshotsListResponse(
        screenshots=screenshots,
        total_count=len(screenshots),
    )


@router.get("/screenshots/{filename}")
async def get_screenshot(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
    filename: str,
) -> FileResponse:
    """
    Serve a specific screenshot file.

    Path traversal is prevented by validating the filename.
    """
    # Security: Prevent path traversal
    if "/" in filename or "\\" in filename or ".." in filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid filename",
        )

    # Validate extension
    if not filename.lower().endswith(".png"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PNG files are allowed",
        )

    # Build safe path
    file_path = settings.data_dir / filename

    # Verify the resolved path is within data_dir (extra security)
    try:
        file_path = file_path.resolve()
        if not str(file_path).startswith(str(settings.data_dir.resolve())):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid file path",
            )
    except (OSError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file path",
        )

    if not file_path.exists():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Screenshot not found: {filename}",
        )

    return FileResponse(
        path=file_path,
        media_type="image/png",
        filename=filename,
    )
