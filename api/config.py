"""
API Configuration & Settings
"""
from pathlib import Path
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # =========================
    # Security
    # =========================
    # Loaded from ENV/.env: API_TOKEN
    api_token: str = ""
    
    # =========================
    # API
    # =========================
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    
    # =========================
    # Paths
    # =========================
    base_dir: Path = Path(__file__).parent.parent
    data_dir: Path = base_dir / "data"
    logs_dir: Path = base_dir / "logs"
    temp_dir: Path = base_dir / "temp"
    cache_dir: Path = base_dir / "cache"
    screenshots_dir: Path = base_dir / "screenshots"
    
    # State & Config files
    state_file: Path = data_dir / "api_state.json"
    filter_config: Path = data_dir / "filter.json"
    user_config: Path = data_dir / "user.json"
    known_listings: Path = data_dir / "known_listings.json"
    applied_listings: Path = data_dir / "applied_listings.json"
    archived_listings: Path = data_dir / "archived_listings.json"
    blacklist_file: Path = data_dir / "blacklist.json"
    
    # Log files
    log_file: Path = logs_dir / "wbm_bot.log"
    error_log: Path = logs_dir / "errors.log"
    access_log: Path = logs_dir / "access.log"
    
    # Script paths
    bot_script: Path = base_dir / "immobilien_bot.py"
    main_script: Path = base_dir / "main.py"
    
    # =========================
    # Bot defaults
    # =========================
    default_interval: int = 900
    default_headless: bool = True
    max_retries: int = 3
    timeout: int = 30
    screenshot_on_error: bool = True
    
    # =========================
    # Pydantic Config
    # =========================
    model_config = SettingsConfigDict(
        env_file="/opt/wbm/.env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"
    )
    
    def __init__(self, **kwargs):
        """Initialize settings and ensure all directories exist."""
        super().__init__(**kwargs)
        self._ensure_directories()
    
    def ensure_directories(self) -> None:

        """Public alias for directory creation."""

        self._ensure_directories()


    def _ensure_directories(self) -> None:
        """Create all necessary directories if they don't exist."""
        directories = [
            self.data_dir,
            self.logs_dir,
            self.temp_dir,
            self.cache_dir,
            self.screenshots_dir
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)


@lru_cache()
def get_settings() -> Settings:
    """
    Get cached settings instance.
    
    Returns:
        Settings: Application settings
    """
    return Settings()


# Export settings instance
settings = get_settings()
