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
from ..models import (
    AppliedListing,
    AppliedListingsResponse,
    BotStats,
    DailyApplicationCount,
    LogsResponse,
    PaginatedListingsResponse,
    ScreenshotInfo,
    ScreenshotsListResponse,
    WeeklyStatsResponse,
)


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

    Includes known listings count, applied listings count, last check time, error counts, etc.
    """
    stats = BotStats(
        known_listings_count=0,
        applied_listings_count=0,
        bot_running=manager.is_running(),
    )

    # Count known listings (all listings ever seen)
    if settings.known_listings.exists():
        try:
            with open(settings.known_listings, "r") as f:
                listings = json.load(f)
                stats.known_listings_count = len(listings)
        except (json.JSONDecodeError, IOError):
            pass

    # Count applied listings (forms submitted)
    if settings.applied_listings.exists():
        try:
            with open(settings.applied_listings, "r") as f:
                applied = json.load(f)
                stats.applied_listings_count = len(applied)
        except (json.JSONDecodeError, IOError):
            pass

    # Parse log file for stats
    if settings.log_file.exists():
        lines, _, _ = tail_file(settings.log_file, lines=1000)
        now = datetime.now()
        errors_24h = 0
        last_check = None
        last_listing = None

        total_listings_last = None
        filtered_listings_last = None

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

            # Extract total listings from last check: "Gefunden: X Angebote"
            if total_listings_last is None and "Gefunden:" in line and "Angebote" in line:
                match = re.search(r"Gefunden:\s*(\d+)\s*Angebote", line)
                if match:
                    total_listings_last = int(match.group(1))

            # Extract filtered listings from last check: "Neue gefilterte Angebote gefunden: X"
            if filtered_listings_last is None and "Neue gefilterte Angebote gefunden:" in line:
                match = re.search(r"Neue gefilterte Angebote gefunden:\s*(\d+)", line)
                if match:
                    filtered_listings_last = int(match.group(1))

        stats.last_check_time = last_check
        stats.last_listing_found = last_listing
        stats.total_errors_24h = errors_24h
        stats.total_listings_last_check = total_listings_last or 0
        stats.filtered_listings_last_check = filtered_listings_last or 0

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


@router.get("/stats/weekly", response_model=WeeklyStatsResponse)
async def get_weekly_stats(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
) -> WeeklyStatsResponse:
    """
    Get application counts per day for the last 7 days.
    """
    today = datetime.now().date()
    days = {}
    for i in range(7):
        d = today - timedelta(days=i)
        days[d.isoformat()] = 0

    if settings.applied_listings.exists():
        try:
            with open(settings.applied_listings, "r", encoding="utf-8") as f:
                raw_listings = json.load(f)

            for item in raw_listings:
                applied_at = item.get("applied_at")
                if applied_at:
                    try:
                        dt = datetime.fromisoformat(applied_at)
                        date_str = dt.date().isoformat()
                        if date_str in days:
                            days[date_str] += 1
                    except (ValueError, TypeError):
                        pass
        except (json.JSONDecodeError, IOError):
            pass

    day_list = [
        DailyApplicationCount(date=date, count=count)
        for date, count in sorted(days.items())
    ]

    return WeeklyStatsResponse(
        days=day_list,
        total=sum(d.count for d in day_list),
    )


@router.delete("/known-listings")
async def clear_known_listings(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
) -> dict:
    """
    Clear all known listings.

    This resets the bot's memory of seen listings, so on the next check
    all current listings will be treated as new.
    """
    try:
        with open(settings.known_listings, "w", encoding="utf-8") as f:
            json.dump({}, f)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to clear known listings: {str(e)}",
        )

    return {"success": True, "message": "Known listings cleared"}


@router.get("/listings", response_model=PaginatedListingsResponse)
async def get_applied_listings(
    _: AuthDep,
    settings: Annotated[Settings, Depends(get_settings)],
    page: int = Query(default=1, ge=1, description="Page number"),
    per_page: int = Query(default=20, ge=1, le=100, description="Items per page"),
    search: str = Query(default="", description="Search in title, address, area"),
    status_filter: str = Query(default="", alias="status", description="Filter by verification status: verified, unverified"),
) -> PaginatedListingsResponse:
    """
    Get paginated list of all listings (known + applied) with search and filtering.

    - **unverified**: Known listings the bot has seen but not applied to
    - **verified/unverified**: Applied listings with their submission verification status
    """
    # 1. Load applied listings
    applied_ids: set[str] = set()
    applied_listings: list[AppliedListing] = []

    if settings.applied_listings.exists():
        try:
            with open(settings.applied_listings, "r", encoding="utf-8") as f:
                raw_applied = json.load(f)

            for item in raw_applied:
                lid = item.get("id")
                if lid:
                    applied_ids.add(lid)
                applied_listings.append(AppliedListing(
                    id=lid,
                    titel=item.get("titel", "Unbekannt"),
                    adresse=item.get("adresse", "Unbekannt"),
                    area=item.get("area", "Unbekannt"),
                    warmmiete=str(item.get("warmmiete", "?")),
                    zimmer=str(item.get("zimmer", "?")),
                    has_wbs=item.get("has_wbs", False),
                    url=item.get("url", ""),
                    applied_at=item.get("applied_at"),
                    verification_status=item.get("verification_status") or "verified",
                ))
        except (json.JSONDecodeError, IOError):
            pass

    # 2. Load known listings (dict format, backward-compat for old array)
    known_only: list[AppliedListing] = []

    if settings.known_listings.exists():
        try:
            with open(settings.known_listings, "r", encoding="utf-8") as f:
                raw_known = json.load(f)

            # Backward compat: old format was a list of ID strings
            if isinstance(raw_known, list):
                known_dict = {
                    lid: {"id": lid, "titel": "Unbekannt", "adresse": "Unbekannt",
                          "area": "Unbekannt", "warmmiete": 0, "zimmer": 0,
                          "has_wbs": False, "url": ""}
                    for lid in raw_known
                }
            elif isinstance(raw_known, dict):
                known_dict = raw_known
            else:
                known_dict = {}

            for lid, item in known_dict.items():
                if lid in applied_ids:
                    continue  # Already in applied list
                known_only.append(AppliedListing(
                    id=lid,
                    titel=item.get("titel", "Unbekannt"),
                    adresse=item.get("adresse", "Unbekannt"),
                    area=item.get("area", "Unbekannt"),
                    warmmiete=str(item.get("warmmiete", "?")),
                    zimmer=str(item.get("zimmer", "?")),
                    has_wbs=item.get("has_wbs", False),
                    url=item.get("url", ""),
                    applied_at=None,
                    verification_status="unverified",
                ))
        except (json.JSONDecodeError, IOError):
            pass

    # 3. Merge: applied (newest first), then known-only (alphabetical by title)
    applied_listings.sort(key=lambda x: x.applied_at or "", reverse=True)
    known_only.sort(key=lambda x: x.titel.lower())
    listings = applied_listings + known_only

    # Apply search filter
    if search:
        search_lower = search.lower()
        listings = [
            l for l in listings
            if search_lower in l.titel.lower()
            or search_lower in l.adresse.lower()
            or search_lower in l.area.lower()
        ]

    # Apply status filter
    if status_filter:
        listings = [
            l for l in listings
            if l.verification_status == status_filter
        ]

    total_count = len(listings)
    total_pages = max(1, (total_count + per_page - 1) // per_page)

    # Paginate
    start = (page - 1) * per_page
    end = start + per_page
    paginated = listings[start:end]

    return PaginatedListingsResponse(
        listings=paginated,
        total_count=total_count,
        page=page,
        per_page=per_page,
        total_pages=total_pages,
    )
