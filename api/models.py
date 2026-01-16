"""Pydantic Request/Response Models"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, EmailStr


# ============== Bot Lifecycle Models ==============

class BotStartRequest(BaseModel):
    """Request body for starting the bot."""
    interval: int = Field(
        default=1800,
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
    known_listings_count: int = Field(description="Total known listings")
    last_check_time: Optional[datetime] = None
    last_listing_found: Optional[datetime] = None
    total_forms_submitted: int = 0
    total_errors_24h: int = 0
    bot_running: bool = False


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


# ============== Error Models ==============

class ErrorResponse(BaseModel):
    """Standard error response."""
    detail: str
