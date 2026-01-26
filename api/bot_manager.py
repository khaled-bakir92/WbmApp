"""Bot Process Lifecycle Manager"""
import json
import os
import signal
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Optional

import psutil

from .config import get_settings


class BotManager:
    """Manages the WBM bot subprocess lifecycle."""

    def __init__(self):
        self.settings = get_settings()
        self._process: Optional[subprocess.Popen] = None
        self._start_time: Optional[datetime] = None
        self._interval: Optional[int] = None
        self._gui_mode: Optional[bool] = None

        # Try to recover state from previous API session
        self._load_state()

    def _load_state(self) -> None:
        """Load persisted state from file (for API restart recovery)."""
        state_file = self.settings.state_file
        if not state_file.exists():
            return

        try:
            with open(state_file, "r") as f:
                state = json.load(f)

            pid = state.get("pid")
            if pid and self._is_process_alive(pid):
                # Process is still running, recover state
                self._start_time = datetime.fromisoformat(state["start_time"])
                self._interval = state.get("interval")
                self._gui_mode = state.get("gui_mode")
        except (json.JSONDecodeError, KeyError, ValueError):
            # Invalid state file, ignore
            pass

    def _save_state(self) -> None:
        """Persist state to file for recovery after API restart."""
        state_file = self.settings.state_file
        pid = self.get_pid()

        if pid and self._start_time:
            state = {
                "pid": pid,
                "start_time": self._start_time.isoformat(),
                "interval": self._interval,
                "gui_mode": self._gui_mode,
            }
            with open(state_file, "w") as f:
                json.dump(state, f)
        elif state_file.exists():
            state_file.unlink()

    def _clear_state(self) -> None:
        """Clear persisted state file."""
        if self.settings.state_file.exists():
            self.settings.state_file.unlink()

    def _is_process_alive(self, pid: int) -> bool:
        """Check if a process with given PID is alive and is our bot."""
        try:
            proc = psutil.Process(pid)
            # Verify it's a Python process running our bot
            cmdline = proc.cmdline()
            return (
                proc.is_running()
                and "python" in cmdline[0].lower()
                and any("immobilien_bot.py" in arg for arg in cmdline)
            )
        except (psutil.NoSuchProcess, psutil.AccessDenied, IndexError):
            return False

    def get_pid(self) -> Optional[int]:
        """Get the bot process PID if running."""
        # Check internal process first
        if self._process and self._process.poll() is None:
            return self._process.pid

        # Check state file for recovered process
        if self.settings.state_file.exists():
            try:
                with open(self.settings.state_file, "r") as f:
                    state = json.load(f)
                pid = state.get("pid")
                if pid and self._is_process_alive(pid):
                    return pid
            except (json.JSONDecodeError, KeyError):
                pass

        return None

    def is_running(self) -> bool:
        """Check if the bot is currently running."""
        return self.get_pid() is not None

    def get_process_stats(self) -> dict:
        """Get CPU and memory stats for the bot process."""
        pid = self.get_pid()
        if not pid:
            return {}

        try:
            proc = psutil.Process(pid)
            return {
                "cpu_percent": proc.cpu_percent(interval=0.1),
                "memory_mb": proc.memory_info().rss / (1024 * 1024),
            }
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            return {}

    def start(self, interval: int = None, gui: bool = False) -> tuple[bool, str, Optional[int]]:
        """
        Start the bot as a subprocess.

        Args:
            interval: Check interval in seconds
            gui: Run browser with GUI (non-headless)

        Returns:
            Tuple of (success, message, pid)
        """
        if self.is_running():
            return False, "Bot is already running", self.get_pid()

        # Use default from settings if not provided
        if interval is None:
            interval = self.settings.default_interval

        # Build command
        python_exe = sys.executable
        bot_script = str(self.settings.bot_script)

        cmd = [python_exe, bot_script, "--interval", str(interval)]
        if gui:
            cmd.append("--gui")

        try:
            # Start the process
            self._process = subprocess.Popen(
                cmd,
                cwd=str(self.settings.base_dir),
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,  # Detach from parent
            )

            # Give it a moment to start
            time.sleep(1)

            # Check if it's still running
            if self._process.poll() is not None:
                return False, "Bot process exited immediately", None

            self._start_time = datetime.now()
            self._interval = interval
            self._gui_mode = gui

            # Persist state
            self._save_state()

            return True, "Bot started successfully", self._process.pid

        except FileNotFoundError:
            return False, f"Bot script not found: {bot_script}", None
        except PermissionError:
            return False, "Permission denied to execute bot script", None
        except Exception as e:
            return False, f"Failed to start bot: {str(e)}", None

    def stop(self, timeout: int = 10) -> tuple[bool, str]:
        """
        Stop the bot gracefully (SIGTERM, then SIGKILL).

        Args:
            timeout: Seconds to wait for graceful shutdown

        Returns:
            Tuple of (success, message)
        """
        pid = self.get_pid()
        if not pid:
            return False, "Bot is not running"

        try:
            proc = psutil.Process(pid)

            # Send SIGTERM for graceful shutdown
            proc.terminate()

            # Wait for process to terminate
            try:
                proc.wait(timeout=timeout)
                self._clear_state()
                self._process = None
                self._start_time = None
                self._interval = None
                self._gui_mode = None
                return True, "Bot stopped gracefully"
            except psutil.TimeoutExpired:
                # Force kill if it doesn't respond
                proc.kill()
                proc.wait(timeout=5)
                self._clear_state()
                self._process = None
                self._start_time = None
                self._interval = None
                self._gui_mode = None
                return True, "Bot force-killed after timeout"

        except psutil.NoSuchProcess:
            self._clear_state()
            self._process = None
            return True, "Bot process already terminated"
        except psutil.AccessDenied:
            return False, "Access denied when trying to stop bot"
        except Exception as e:
            return False, f"Failed to stop bot: {str(e)}"

    def restart(self, interval: Optional[int] = None, gui: Optional[bool] = None) -> tuple[bool, str, Optional[int]]:
        """
        Restart the bot with optional new parameters.

        Args:
            interval: New check interval (or use previous)
            gui: New GUI mode (or use previous)

        Returns:
            Tuple of (success, message, pid)
        """
        # Use config default if not specified
        if interval is None:
            interval = self.settings.default_interval
        if gui is None:
            gui = self._gui_mode or not self.settings.default_headless

        # Stop if running
        if self.is_running():
            success, msg = self.stop()
            if not success:
                return False, f"Failed to stop bot: {msg}", None
            time.sleep(2)  # Brief pause before restart

        # Start with new/existing parameters
        return self.start(interval=interval, gui=gui)

    def get_status(self) -> dict:
        """Get comprehensive bot status."""
        pid = self.get_pid()
        running = pid is not None

        status = {
            "running": running,
            "pid": pid,
            "start_time": self._start_time,
            "uptime_seconds": None,
            "interval": self._interval,
            "gui_mode": self._gui_mode,
            "cpu_percent": None,
            "memory_mb": None,
        }

        if running and self._start_time:
            status["uptime_seconds"] = (datetime.now() - self._start_time).total_seconds()
            stats = self.get_process_stats()
            status.update(stats)

        return status


# Singleton instance
_bot_manager: Optional[BotManager] = None


def get_bot_manager() -> BotManager:
    """Get the singleton BotManager instance."""
    global _bot_manager
    if _bot_manager is None:
        _bot_manager = BotManager()
    return _bot_manager
