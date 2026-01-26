//
//  DashboardViewModel.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation
import SwiftUI
import Combine

/// Haupt-ViewModel für das Dashboard
/// Koordiniert alle Services und verwaltet den UI-State
@MainActor
final class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var botStatus: BotStatus?
    @Published var monitorStats: MonitorStats?
    @Published var filterConfig: FilterConfig?
    @Published var listingStats: ListingStats?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Services
    
    private let botService = BotService()
    private let configService = ConfigService()
    private let monitorService = MonitorService()
    
    // MARK: - Timer für Auto-Refresh
    
    private var refreshTimer: Timer?
    private let refreshInterval: TimeInterval = 10.0 // Alle 10 Sekunden
    
    // MARK: - Initialization
    
    init() {
        // Auto-Refresh starten
        startAutoRefresh()
    }
    
    deinit {
        // Timer direkt invalidieren (synchron, kein Actor-Kontext nötig)
        refreshTimer?.invalidate()
    }
    
    // MARK: - Auto-Refresh
    
    /// Startet automatisches Aktualisieren der Daten
    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.silentRefresh()
            }
        }
    }
    
    /// Stoppt automatisches Aktualisieren
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /// Aktualisiert Daten im Hintergrund ohne Loading-Indicator
    private func silentRefresh() async {
        do {
            // Gleichzeitig Status und Stats laden
            async let statusTask = botService.getStatus()
            async let statsTask = monitorService.getStats()
            
            let (status, stats) = try await (statusTask, statsTask)
            
            self.botStatus = status
            self.monitorStats = stats
            self.listingStats = createListingStatsFromMonitor(stats)
            
        } catch is CancellationError {
            // Ignorieren
        } catch {
            // Bei automatischen Updates nur loggen, kein UI-Fehler
            print("⚠️ Silent Refresh fehlgeschlagen: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Loading
    
    /// Lädt alle Dashboard-Daten (Status, Stats, Config)
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let statusTask = botService.getStatus()
            async let statsTask = monitorService.getStats()
            async let configTask = configService.getFilterConfig()
            
            let (status, stats, config) = try await (statusTask, statsTask, configTask)
            
            self.botStatus = status
            self.monitorStats = stats
            self.filterConfig = config
            
            // Erstelle wöchentliche Daten aus MonitorStats
            self.listingStats = createListingStatsFromMonitor(stats)
            
        } catch is CancellationError {
            // Task wurde abgebrochen - das ist normal, zeige keinen Fehler
            print("⚠️ Dashboard-Laden wurde abgebrochen")
        } catch {
            // Nur echte Fehler anzeigen
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Konvertiert MonitorStats in ListingStats für Chart
    /// Zeigt Gesamtstatistiken: alle gefundenen vs. alle beworbenen Wohnungen
    private func createListingStatsFromMonitor(_ stats: MonitorStats) -> ListingStats {
        let calendar = Calendar.current
        let now = Date()
        let weekNumber = calendar.component(.weekOfYear, from: now)
        let year = calendar.component(.year, from: now)

        let formatter = ISO8601DateFormatter()
        let startDate = formatter.string(from: now)

        // Zeigt Gesamtzahlen: alle gefundenen Wohnungen vs. alle beworbenen
        let weeklyListing = WeeklyListing(
            id: "\(year)-W\(weekNumber)",
            weekNumber: weekNumber,
            year: year,
            totalCount: stats.knownListingsCount,           // Alle jemals gefundenen Wohnungen
            matchedCount: stats.appliedListingsCount,       // Alle beworbenen Wohnungen
            startDate: startDate
        )

        return ListingStats(
            totalListings: stats.knownListingsCount,        // Alle gefundenen
            matchedListings: stats.appliedListingsCount,    // Alle beworbenen
            appliedListings: stats.appliedListingsCount,    // Gleich wie beworbene
            weeklyData: [weeklyListing]
        )
    }
    
    /// Lädt nur den Bot-Status (für häufige Updates)
    func refreshStatus() async {
        do {
            botStatus = try await botService.getStatus()
        } catch is CancellationError {
            print("⚠️ Status-Update wurde abgebrochen")
        } catch {
            errorMessage = "Status-Update fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    
    /// Lädt nur die Statistiken
    func refreshStats() async {
        do {
            let stats = try await monitorService.getStats()
            self.monitorStats = stats
            // ✅ WICHTIG: Auch listingStats aktualisieren!
            self.listingStats = createListingStatsFromMonitor(stats)
        } catch is CancellationError {
            print("⚠️ Stats-Update wurde abgebrochen")
        } catch {
            errorMessage = "Stats-Update fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Bot Actions
    
    /// Startet den Bot mit Standard-Konfiguration
    func startBot() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await botService.startWithDefaults()
            print("✅ Bot gestartet: \(response.message)")
            // ✅ Status UND Stats aktualisieren
            await refreshStatus()
            await refreshStats()
        } catch {
            errorMessage = "Bot-Start fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Stoppt den Bot
    func stopBot() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await botService.stop()
            print("✅ Bot gestoppt: \(response.message)")
            // ✅ Status UND Stats aktualisieren
            await refreshStatus()
            await refreshStats()
        } catch {
            errorMessage = "Bot-Stop fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Startet den Bot neu
    func restartBot() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await botService.restart()
            print("✅ Bot neugestartet: \(response.message)")
            // ✅ Status UND Stats aktualisieren
            await refreshStatus()
            await refreshStats()
        } catch {
            errorMessage = "Bot-Neustart fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Configuration
    
    /// Aktualisiert die Filter-Konfiguration
    func updateFilter(_ newConfig: FilterConfig) async {
        isLoading = true
        errorMessage = nil
        
        do {
            filterConfig = try await configService.updateFilterConfig(newConfig)
            print("✅ Filter aktualisiert")
        } catch {
            errorMessage = "Filter-Update fehlgeschlagen: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Computed Properties
    
    /// Gibt an, ob der Bot läuft
    var isBotRunning: Bool {
        botStatus?.running ?? false
    }
    
    /// Status-Text für UI
    var statusText: String {
        guard let status = botStatus else {
            return "Unbekannt"
        }
        return status.statusText
    }
    
    /// Status-Farbe für UI
    var statusColor: Color {
        isBotRunning ? .green : .red
    }
    
    /// Gesundheitsstatus
    var healthStatus: HealthStatus {
        monitorStats?.healthStatus ?? .stopped
    }
}

