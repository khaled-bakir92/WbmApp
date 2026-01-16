"""API Configuration & Settings"""
import os
import secrets
from pathlib import Path
from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # API Settings
    api_token: str = ""
    api_host: str = "0.0.0.0"
    api_port: int = 8000

    # Paths
    base_dir: Path = Path(__file__).parent.parent
    data_dir: Path = base_dir / "data"
    logs_dir: Path = base_dir / "logs"

    # Bot defaults
    default_interval: int = 1800  # 30 minutes
    default_headless: bool = True

    # State file for persisting bot PID across API restarts
    state_file: Path = data_dir / "api_state.json"

    # Config files
    filter_config: Path = data_dir / "filter.json"
    user_config: Path = data_dir / "user.json"
    known_listings: Path = data_dir / "known_listings.json"

    # Log file
    log_file: Path = logs_dir / "wbm_bot.log"

    # Bot script
    bot_script: Path = base_dir / "immobilien_bot.py"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"

    def ensure_directories(self) -> None:
        """Ensure required directories exist."""
        self.data_dir.mkdir(exist_ok=True)
        self.logs_dir.mkdir(exist_ok=True)

    def generate_token_if_missing(self) -> str:
        """Generate a secure token if not set, and save to .env."""
        if not self.api_token:
            token = secrets.token_urlsafe(32)
            env_path = self.base_dir / ".env"

            # Write to .env file
            with open(env_path, "a") as f:
                f.write(f"\nAPI_TOKEN={token}\n")

            self.api_token = token
            return token
        return self.api_token


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance."""
    settings = Settings()
    settings.ensure_directories()
    return settings
