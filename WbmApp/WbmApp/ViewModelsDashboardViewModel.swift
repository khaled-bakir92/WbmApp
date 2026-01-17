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
    
    // MARK: - Initialization
    
    init() {
        // Initial load könnte hier stattfinden
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
    /// Zeigt nur den aktuellen Tag (letzter Check)
    private func createListingStatsFromMonitor(_ stats: MonitorStats) -> ListingStats {
        let calendar = Calendar.current
        let now = Date()
        let weekNumber = calendar.component(.weekOfYear, from: now)
        let year = calendar.component(.year, from: now)
        
        let formatter = ISO8601DateFormatter()
        let startDate = formatter.string(from: now)
        
        let weeklyListing = WeeklyListing(
            id: "\(year)-W\(weekNumber)",
            weekNumber: weekNumber,
            year: year,
            totalCount: stats.totalListingsLastCheck ?? 0,
            matchedCount: stats.filteredListingsLastCheck ?? 0,
            startDate: startDate
        )
        
        return ListingStats(
            totalListings: stats.knownListingsCount,
            matchedListings: stats.filteredListingsLastCheck ?? 0,
            appliedListings: stats.totalFormsSubmitted,
            weeklyData: [weeklyListing] // Nur ein Eintrag: der letzte Check
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
            monitorStats = try await monitorService.getStats()
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
            await refreshStatus()
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
            await refreshStatus()
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
            await refreshStatus()
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

