//
//  LaunchViewModel.swift
//  WbmApp
//
//  Created on 2026-01-28.
//

import Foundation
import Combine

/// Ladezustand für den App-Start
enum LaunchLoadingState {
    case idle
    case loading
    case success
    case failed
}

/// ViewModel für den Launch Screen
/// Lädt initiale Daten beim App-Start
@MainActor
final class LaunchViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var loadingState: LaunchLoadingState = .idle
    @Published var errorMessage: String?

    /// Vorgeladene Daten (für spätere Verwendung in ContentView)
    @Published var botStatus: BotStatus?
    @Published var monitorStats: MonitorStats?
    @Published var filterConfig: FilterConfig?

    // MARK: - Services

    private let botService = BotService()
    private let monitorService = MonitorService()
    private let configService = ConfigService()

    // MARK: - Data Loading

    /// Lädt alle initialen Daten parallel
    func loadInitialData() async {
        loadingState = .loading
        errorMessage = nil

        do {
            // Parallel laden wie in DashboardViewModel
            async let statusTask = botService.getStatus()
            async let statsTask = monitorService.getStats()
            async let configTask = configService.getFilterConfig()

            let (status, stats, config) = try await (statusTask, statsTask, configTask)

            self.botStatus = status
            self.monitorStats = stats
            self.filterConfig = config
            self.loadingState = .success

        } catch is CancellationError {
            // Task wurde abgebrochen - ignorieren
            print("⚠️ Launch-Laden wurde abgebrochen")
        } catch {
            self.errorMessage = error.localizedDescription
            self.loadingState = .failed
        }
    }

    /// Setzt den Zustand zurück für einen erneuten Versuch
    func retry() {
        Task {
            await loadInitialData()
        }
    }
}
