#!/bin/bash

# Performance Testing Setup Script
# Verschiebt Test-Dateien ins richtige Target

set -e

echo "🔧 WBM Bot Controller - Performance Testing Setup"
echo "=================================================="
echo ""

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Projekt-Root finden
if [ ! -f "WbmApp.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Error: Nicht im Projekt-Root-Verzeichnis!${NC}"
    echo "Bitte führen Sie das Script aus dem Verzeichnis aus, das WbmApp.xcodeproj enthält."
    exit 1
fi

echo "📁 Projekt gefunden: $(pwd)"
echo ""

# Backup erstellen
BACKUP_DIR="WbmApp_backup_$(date +%Y%m%d_%H%M%S)"
echo "💾 Erstelle Backup: $BACKUP_DIR"
cp -r WbmApp "$BACKUP_DIR"
echo -e "${GREEN}✓${NC} Backup erstellt"
echo ""

# Test-Verzeichnis sicherstellen
if [ ! -d "WbmAppTests" ]; then
    echo -e "${YELLOW}⚠️  WbmAppTests Verzeichnis nicht gefunden. Wird erstellt...${NC}"
    mkdir -p WbmAppTests
fi

# Dateien verschieben
MOVED_COUNT=0

# Swift Testing Version
if [ -f "WbmApp/BotStartConfigPerformanceTests_SwiftTesting.swift" ]; then
    echo "📦 Verschiebe Swift Testing Performance Tests..."
    mv "WbmApp/BotStartConfigPerformanceTests_SwiftTesting.swift" \
       "WbmAppTests/BotStartConfigPerformanceTests.swift"
    echo -e "${GREEN}✓${NC} BotStartConfigPerformanceTests.swift → WbmAppTests/"
    ((MOVED_COUNT++))
fi

# Alte fehlerhafte Dateien aufräumen
if [ -f "WbmApp/BotStartConfigPerformanceTests.swift" ]; then
    echo "🧹 Entferne alte fehlerhafte Datei..."
    rm "WbmApp/BotStartConfigPerformanceTests.swift"
    echo -e "${GREEN}✓${NC} Alte Datei entfernt"
fi

# XCTest Version (optional ins UITests Target)
if [ -f "WbmApp/BotStartConfigPerformanceTests_XCTest.swift" ]; then
    if [ -d "WbmAppUITests" ]; then
        read -p "Möchten Sie die XCTest Version nach WbmAppUITests verschieben? (j/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[JjYy]$ ]]; then
            mv "WbmApp/BotStartConfigPerformanceTests_XCTest.swift" \
               "WbmAppUITests/BotStartConfigPerformanceTests_XCTest.swift"
            echo -e "${GREEN}✓${NC} XCTest Version → WbmAppUITests/"
            ((MOVED_COUNT++))
        else
            rm "WbmApp/BotStartConfigPerformanceTests_XCTest.swift"
            echo -e "${GREEN}✓${NC} XCTest Version entfernt"
        fi
    else
        echo -e "${YELLOW}⚠️  WbmAppUITests nicht gefunden. Entferne XCTest Version...${NC}"
        rm "WbmApp/BotStartConfigPerformanceTests_XCTest.swift"
        echo -e "${GREEN}✓${NC} XCTest Version entfernt"
    fi
fi

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Setup abgeschlossen!${NC}"
echo ""
echo "📋 Nächste Schritte in Xcode:"
echo ""
echo "1. Öffnen Sie Xcode"
echo "2. Gehen Sie zu WbmAppTests/ im Project Navigator"
echo "3. Falls die Datei nicht angezeigt wird:"
echo "   - Rechtsklick auf WbmAppTests → 'Add Files to WbmApp...'"
echo "   - Wählen Sie BotStartConfigPerformanceTests.swift"
echo "   - Target: Nur 'WbmAppTests' auswählen!"
echo ""
echo "4. Oder: File Inspector öffnen (⌥⌘1) und Target Membership prüfen:"
echo "   - ☑ WbmAppTests"
echo "   - □ WbmApp (deaktiviert)"
echo ""
echo "5. Tests ausführen: ⌘U"
echo ""
echo "📚 Weitere Infos: siehe PERFORMANCE_TESTING_SETUP.md"
echo ""
echo -e "${YELLOW}💡 Tipp: Falls Probleme auftreten:${NC}"
echo "   - Clean Build Folder: ⇧⌘K"
echo "   - Rebuild: ⌘B"
echo ""

if [ $MOVED_COUNT -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Keine Dateien zum Verschieben gefunden.${NC}"
    echo "Möglicherweise wurden sie bereits verschoben."
fi

exit 0
