# WBM Apartment Bot

Automatisiertes Wohnungssuch-System für mit Python-Backend und nativer iOS-App.

## Features

- **Automatische Wohnungssuche**  mit konfigurierbaren Filtern
- **Automatische Kontaktformular-Einreichung** für passende Wohnungen
- **E-Mail-Benachrichtigungen** bei neuen Treffern
- **REST API** zur Fernsteuerung des Bots
- **Native iOS App** zur Überwachung und Kontrolle
- **Headless oder GUI-Modus** für den Browser

---

## Projektstruktur

```
wbm/
├── Backend (Python)
│   ├── immobilien_bot.py          # Hauptbot (Selenium-basiert)
│   ├── api/                       # FastAPI REST API
│   │   ├── main.py               # API Entry Point
│   │   ├── config.py             # Konfiguration
│   │   ├── auth.py               # Bearer Token Auth
│   │   ├── models.py             # Pydantic Schemas
│   │   ├── bot_manager.py        # Bot Prozessverwaltung
│   │   └── routers/
│   │       ├── lifecycle.py      # Start/Stop/Restart/Status
│   │       ├── configuration.py  # Filter & User Config
│   │       └── monitoring.py     # Logs, Stats, Screenshots
│   ├── data/                      # Konfigurationsdateien
│   │   ├── filter.json           # Suchfilter
│   │   ├── user.json             # Benutzerdaten & SMTP
│   │   └── known_listings.json   # Bekannte Wohnungen
│   ├── logs/
│   │   └── wbm_bot.log
│   ├── requirements.txt
│   └── .env                       # API Token (nicht im Git)
│
├── Frontend (iOS Swift)
│   └── WbmApp/
│       └── WbmApp/
│           ├── ContentView.swift          # Haupt-UI (4 Tabs)
│           ├── Networking/                # API Client
│           ├── Models/                    # Datenmodelle
│           ├── Services/                  # Business Logic
│           ├── ViewModels/                # State Management
│           ├── Views/                     # UI Komponenten
│           ├── Secrets.swift              # Bearer Token (nicht im Git)
│           └── Secrets.xcconfig           # Xcode Config (nicht im Git)
│
└── Dokumentation
    ├── README.md                  # Diese Datei
```

---

## Schnellstart (Lokal)

### 1. Voraussetzungen

- Python 3.10+
- Google Chrome
- Xcode (für iOS App)

### 2. Backend Setup

```bash
# Repository klonen
cd /pfad/zum/wbm

# Virtual Environment erstellen
python3 -m venv venv
source venv/bin/activate

# Abhängigkeiten installieren
pip install -r requirements.txt

# .env Datei erstellen
echo "API_TOKEN=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')" > .env
```

### 3. Konfiguration

**Filter erstellen (`data/filter.json`):**
```json
{
    "max_warmmiete": 1200.0,
    "min_zimmer": 2,
    "wbs_required": false,
    "excluded_areas": ["Marzahn", "Hellersdorf"]
}
```

**Benutzerdaten erstellen (`data/user.json`):**
```json
{
    "user_data": {
        "anrede": "Herr",
        "name": "Mustermann",
        "vorname": "Max",
        "strasse": "Musterstr. 1",
        "plz": "10115",
        "ort": "Berlin",
        "email": "max@example.com",
        "telefon": "030123456"
    },
    "notification_email": {
        "sender": "bot@gmail.com",
        "recipient": "max@example.com",
        "password": "app-password",
        "smtp_server": "smtp.gmail.com",
        "smtp_port": 587
    }
}
```

### 4. Bot starten

**Direkt:**
```bash
source venv/bin/activate
python immobilien_bot.py --interval 1800           # Headless
python immobilien_bot.py --interval 1800 --gui     # Mit Browser-UI
```

**Via API:**
```bash
source venv/bin/activate
uvicorn api.main:app --host 0.0.0.0 --port 8000
```

### 5. iOS App

1. `WbmApp/WbmApp.xcodeproj` in Xcode öffnen
2. `Secrets.swift` erstellen (siehe Templates)
3. API URL in `Networking/NetworkingAPIConfig.swift` anpassen
4. App auf Gerät/Simulator starten

---

## API Dokumentation

Vollständige Dokumentation: [API.md](API.md)

### Wichtige Endpoints

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| GET | `/health` | Health Check |
| GET | `/api/bot/status` | Bot Status & Ressourcen |
| POST | `/api/bot/start` | Bot starten |
| POST | `/api/bot/stop` | Bot stoppen |
| POST | `/api/bot/restart` | Bot neu starten |
| GET | `/api/config/filter` | Filter lesen |
| PUT | `/api/config/filter` | Filter aktualisieren |
| GET | `/api/monitor/stats` | Statistiken abrufen |
| GET | `/api/monitor/logs` | Logs abrufen |

### Beispiel

```bash
# Status abfragen
curl -H "Authorization: Bearer DEIN_TOKEN" http://localhost:8000/api/bot/status

# Bot starten
curl -X POST -H "Authorization: Bearer DEIN_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"interval": 900}' \
     http://localhost:8000/api/bot/start
```

---

## VPS Deployment (Ubuntu 22.04)

Vollständige Anleitung: [VPS.md](VPS.md)

### Kurzübersicht

```bash
# 1. Code auf VPS kopieren
scp -r /pfad/zum/wbm root@DEINE-VPS-IP:/opt/

# 2. VPS einrichten (via SSH)
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv nginx certbot python3-certbot-nginx

# 3. Chrome installieren
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt --fix-broken install -y

# 4. Python Setup
cd /opt/wbm
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Wichtige VPS Befehle

#### Service Management

```bash
# Service starten
sudo systemctl start wbm-api

# Service stoppen
sudo systemctl stop wbm-api

# Service neu starten
sudo systemctl restart wbm-api

# Service Status
sudo systemctl status wbm-api

# Service beim Boot aktivieren
sudo systemctl enable wbm-api

# Service beim Boot deaktivieren
sudo systemctl disable wbm-api
```

#### Logs & Debugging

```bash
# API Service Logs (live)
sudo journalctl -u wbm-api -f

# API Service Logs (letzte 100 Zeilen)
sudo journalctl -u wbm-api -n 100

# Bot Logs
tail -f /opt/wbm/logs/wbm_bot.log

# Nginx Fehler-Logs
sudo tail -f /var/log/nginx/error.log

# Nginx Zugriffs-Logs
sudo tail -f /var/log/nginx/access.log
```

#### Nginx

```bash
# Konfiguration testen
sudo nginx -t

# Nginx neu laden
sudo systemctl reload nginx

# Nginx neu starten
sudo systemctl restart nginx
```

#### SSL-Zertifikat

```bash
# Neues Zertifikat erstellen
sudo certbot --nginx -d deine-domain.duckdns.org

# Zertifikate anzeigen
sudo certbot certificates

# Erneuerung testen
sudo certbot renew --dry-run

# Manuell erneuern
sudo certbot renew
```

#### Firewall

```bash
# Status anzeigen
sudo ufw status

# Ports öffnen
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS

# Firewall aktivieren
sudo ufw enable
```

#### System

```bash
# Ressourcen-Übersicht
htop

# Speicherplatz
df -h

# Laufende Python-Prozesse
ps aux | grep python

# Bot-Prozess finden
ps aux | grep immobilien_bot

# Code aktualisieren
cd /opt/wbm
git pull

# Abhängigkeiten aktualisieren
source venv/bin/activate
pip install -r requirements.txt

# Berechtigungen reparieren
sudo chown -R www-data:www-data /opt/wbm
sudo chmod -R 755 /opt/wbm
```

### Systemd Service Datei

```ini
# /etc/systemd/system/wbm-api.service
[Unit]
Description=WBM Bot API
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/wbm
Environment="PATH=/opt/wbm/venv/bin"
EnvironmentFile=/opt/wbm/.env
ExecStart=/opt/wbm/venv/bin/uvicorn api.main:app --host 127.0.0.1 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Nach Änderung:
```bash
sudo systemctl daemon-reload
sudo systemctl restart wbm-api
```

---

## Token-Management

Bei Token-Änderung müssen **3 Dateien** aktualisiert werden:

| Datei | Beschreibung |
|-------|--------------|
| `.env` | Backend: `API_TOKEN=<token>` |
| `WbmApp/WbmApp/Secrets.swift` | iOS: `static let bearerToken = "<token>"` |
| `WbmApp/WbmApp/Secrets.xcconfig` | Xcode: `BEARER_TOKEN = <token>` |

**Neuen Token generieren:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## Filter-Optionen

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `max_warmmiete` | float | Maximale Warmmiete in EUR |
| `min_zimmer` | int | Mindestanzahl Zimmer |
| `wbs_required` | bool/null | `true`=nur WBS, `false`=kein WBS, `null`=egal |
| `excluded_areas` | string[] | Ausgeschlossene Bezirke |

---

## Troubleshooting

### Bot startet nicht
```bash
# Logs prüfen
tail -50 /opt/wbm/logs/wbm_bot.log

# Chrome installiert?
google-chrome --version

# Python-Fehler?
cd /opt/wbm && source venv/bin/activate && python immobilien_bot.py --interval 60
```

### API nicht erreichbar
```bash
# Service läuft?
sudo systemctl status wbm-api

# Port belegt?
sudo lsof -i :8000

# Nginx-Konfiguration?
sudo nginx -t
```

### iOS App verbindet nicht
1. API URL korrekt? (HTTPS erforderlich für externe Server)
2. Token identisch in `.env` und `Secrets.swift`?
3. VPS-Firewall: Port 443 offen?

---

## Entwicklung

```bash
# API im Dev-Modus (mit Auto-Reload)
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

# Interaktive Filter-Konfiguration
python immobilien_bot.py --config

# Swagger UI
open http://localhost:8000/docs
```

---

## Lizenz

Dieses Projekt ist unter der [MIT License](LICENSE) lizenziert.
