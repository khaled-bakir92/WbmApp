# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a WBM (Wohnungsbaugesellschaft Berlin-Mitte) apartment listing bot that monitors https://www.wbm.de/wohnungen-berlin/angebote/ for new rental listings, filters them based on user criteria, and automatically submits contact forms.

## Setup

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Commands

```bash
# Activate venv first (required before running)
source venv/bin/activate

# Run the bot (headless mode, 30-minute check interval)
python immobilien_bot.py

# Run with GUI (visible browser)
python immobilien_bot.py --gui

# Configure filters interactively
python immobilien_bot.py --config

# Custom check interval (in seconds)
python immobilien_bot.py --interval 900
```

## Configuration

All configuration is stored in JSON files in the `data/` directory.

**`data/user.json`** - Personal data and email settings:
```json
{
    "user_data": {
        "anrede": "Frau/Herr",
        "name": "Nachname",
        "vorname": "Vorname",
        "strasse": "Straße und Hausnummer",
        "plz": "PLZ",
        "ort": "Stadt",
        "email": "email@example.com",
        "telefon": "Telefonnummer"
    },
    "notification_email": {
        "sender": "sender@gmail.com",
        "recipient": "recipient@gmail.com",
        "password": "app-password",
        "smtp_server": "smtp.gmail.com",
        "smtp_port": 587
    }
}
```

**`data/filter.json`** - Apartment filter criteria:
```json
{
    "max_warmmiete": 1950,
    "min_zimmer": 2,
    "wbs_required": false,
    "excluded_areas": ["Marzahn"]
}
```

Filter options:
- `max_warmmiete`: Maximum warm rent in Euro
- `min_zimmer`: Minimum number of rooms
- `wbs_required`: `true` = only with WBS, `false` = only without WBS, `null` = both
- `excluded_areas`: List of districts to exclude

## Architecture

**Single-file bot (`immobilien_bot.py`):**
- `WBMBot` class handles all functionality
- Uses Selenium with Chrome (Firefox fallback) for web scraping
- Loads configuration from `data/user.json` and `data/filter.json`
- Logs to `logs/wbm_bot.log`

**Key methods:**
- `load_user_data()` - Loads user data from `data/user.json`
- `load_filter_settings()` - Loads filters from `data/filter.json`
- `check_for_new_listings()` - Scrapes listing page, extracts apartment data
- `filter_listing()` - Applies user-defined filters (rent, rooms, WBS, area)
- `fill_contact_form()` - Auto-submits interest form for matching listings
- `send_notification_email()` - Sends email alerts via SMTP

**Data files in `data/`:**
- `user.json` - Personal data and SMTP configuration (required)
- `filter.json` - Filter settings (required)
- `known_listings.json` - Previously seen listing IDs (auto-created)
- `*.png` - Debug screenshots

## Dependencies

Requires Chrome/Chromium with ChromeDriver (or Firefox with GeckoDriver as fallback).
