"""Pydantic Request/Response Models"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, EmailStr

from .config import settings


# ============== Bot Lifecycle Models ==============

class BotStartRequest(BaseModel):
    """Request body for starting the bot."""
    interval: int = Field(
        default=settings.default_interval,
        ge=60,
        le=86400,
        description="Check interval in seconds (60-86400)"
    )
    gui: bool = Field(
        default=False,
        description="Run browser with GUI (non-headless mode)"
    )


class BotStatusResponse(BaseModel):
    """Response for bot status endpoint."""
    running: bool
    pid: Optional[int] = None
    start_time: Optional[datetime] = None
    uptime_seconds: Optional[float] = None
    interval: Optional[int] = None
    gui_mode: Optional[bool] = None
    cpu_percent: Optional[float] = None
    memory_mb: Optional[float] = None


class BotActionResponse(BaseModel):
    """Response for bot start/stop/restart actions."""
    success: bool
    message: str
    pid: Optional[int] = None


# ============== Filter Configuration Models ==============

class FilterConfig(BaseModel):
    """Filter configuration for apartment search."""
    max_warmmiete: float = Field(
        ge=0,
        description="Maximum warm rent in EUR"
    )
    min_zimmer: int = Field(
        ge=1,
        description="Minimum number of rooms"
    )
    wbs_required: Optional[bool] = Field(
        default=None,
        description="WBS requirement filter: True=only WBS, False=no WBS, None=any"
    )
    excluded_areas: list[str] = Field(
        default_factory=list,
        description="List of excluded district names"
    )


# ============== User Configuration Models ==============

class UserData(BaseModel):
    """User personal data for form filling."""
    anrede: str = Field(description="Salutation (Herr/Frau)")
    name: str = Field(description="Last name")
    vorname: str = Field(description="First name")
    strasse: str = Field(description="Street address")
    plz: str = Field(description="Postal code")
    ort: str = Field(description="City")
    email: EmailStr = Field(description="Email address")
    telefon: str = Field(description="Phone number")


class NotificationEmail(BaseModel):
    """Email notification settings."""
    sender: EmailStr = Field(description="Sender email address")
    recipient: EmailStr = Field(description="Recipient email address")
    password: str = Field(description="SMTP password (app password)")
    smtp_server: str = Field(description="SMTP server address")
    smtp_port: int = Field(ge=1, le=65535, description="SMTP port")


class UserConfig(BaseModel):
    """Complete user configuration."""
    user_data: UserData
    notification_email: NotificationEmail


class UserConfigResponse(BaseModel):
    """User config response with masked password."""
    user_data: UserData
    notification_email: dict  # Using dict to allow masked password


class UserConfigUpdate(BaseModel):
    """Partial user config update."""
    user_data: Optional[UserData] = None
    notification_email: Optional[NotificationEmail] = None


# ============== Monitoring Models ==============

class BotStats(BaseModel):
    """Bot statistics extracted from logs and data files."""
    known_listings_count: int = Field(description="Total known listings (all ever seen)")
    applied_listings_count: int = Field(
        default=0,
        description="Total listings that were applied to (forms submitted)"
    )
    last_check_time: Optional[datetime] = None
    last_listing_found: Optional[datetime] = None
    total_forms_submitted: int = 0
    total_errors_24h: int = 0
    bot_running: bool = False
    # Legacy fields for listing statistics (kept for backwards compatibility)
    total_listings_last_check: int = Field(
        default=0,
        description="Total listings found in last check (before filtering)"
    )
    filtered_listings_last_check: int = Field(
        default=0,
        description="Listings matching filter criteria in last check"
    )


class LogEntry(BaseModel):
    """Single log entry."""
    timestamp: str
    level: str
    message: str


class LogsResponse(BaseModel):
    """Response for logs endpoint."""
    lines: list[str]
    total_lines: int
    file_size_bytes: int


class ScreenshotInfo(BaseModel):
    """Information about a screenshot file."""
    filename: str
    size_bytes: int
    modified_at: datetime


class ScreenshotsListResponse(BaseModel):
    """Response for screenshots list endpoint."""
    screenshots: list[ScreenshotInfo]
    total_count: int


# ============== Applied Listings Models ==============

class AppliedListing(BaseModel):
    """Details of an applied/contacted listing."""
    id: Optional[str] = Field(default=None, description="Listing ID")
    titel: str = Field(description="Listing title")
    adresse: str = Field(description="Street address")
    area: str = Field(description="District/Area")
    warmmiete: str = Field(description="Warm rent in EUR")
    zimmer: str = Field(description="Number of rooms")
    has_wbs: bool = Field(default=False, description="WBS requirement")
    url: str = Field(description="Listing URL")
    applied_at: Optional[datetime] = Field(default=None, description="When the form was submitted")
    verification_status: Optional[str] = Field(
        default=None,
        description="Form submission verification: verified, unverified, or None for legacy entries"
    )


class AppliedListingsResponse(BaseModel):
    """Response for applied listings endpoint."""
    listings: list[AppliedListing]
    total_count: int


class PaginatedListingsResponse(BaseModel):
    """Paginated response for applied listings endpoint."""
    listings: list[AppliedListing]
    total_count: int
    page: int
    per_page: int
    total_pages: int


class DailyApplicationCount(BaseModel):
    """Application count for a single day."""
    date: str = Field(description="Date in YYYY-MM-DD format")
    count: int = Field(description="Number of applications on this day")


class WeeklyStatsResponse(BaseModel):
    """Weekly application statistics."""
    days: list[DailyApplicationCount]
    total: int = Field(description="Total applications in the last 7 days")


# ============== Error Models ==============

class ErrorResponse(BaseModel):
    """Standard error response."""
    detail: str
