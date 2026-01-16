//
//  BotService.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Service-Layer für Bot-Lifecycle-Management
/// Abstrahiert API-Calls und bietet High-Level-Funktionen
@MainActor
final class BotService: ObservableObject {
    private let client = APIClient.shared
    
    // MARK: - Status
    
    /// Holt den aktuellen Bot-Status
    func getStatus() async throws -> BotStatus {
        return try await client.request(
            method: .get,
            path: APIEndpoint.botStatus.path
        )
    }
    
    // MARK: - Lifecycle
    
    /// Startet den Bot mit optionaler Konfiguration
    /// - Parameter config: Start-Konfiguration (interval, gui)
    /// - Returns: Success-Response mit PID
    func start(config: BotStartConfig? = nil) async throws -> SuccessResponse {
        return try await client.request(
            method: .post,
            path: APIEndpoint.botStart.path,
            body: config
        )
    }
    
    /// Stoppt den Bot
    func stop() async throws -> SuccessResponse {
        return try await client.requestWithoutResponse(
            method: .post,
            path: APIEndpoint.botStop.path
        )
    }
    
    /// Startet den Bot neu mit optionaler neuer Konfiguration
    /// - Parameter config: Neue Start-Konfiguration
    func restart(config: BotStartConfig? = nil) async throws -> SuccessResponse {
        return try await client.request(
            method: .post,
            path: APIEndpoint.botRestart.path,
            body: config
        )
    }
    
    // MARK: - Convenience Methods
    
    /// Prüft ob der Bot läuft
    func isRunning() async throws -> Bool {
        let status = try await getStatus()
        return status.running
    }
    
    /// Startet den Bot mit Standard-Konfiguration
    func startWithDefaults() async throws -> SuccessResponse {
        return try await start(config: .default)
    }
    
    /// Startet den Bot im Test-Modus (60s Intervall)
    func startInTestMode() async throws -> SuccessResponse {
        return try await start(config: .testing)
    }
    
    /// Startet den Bot im Debug-Modus (mit GUI)
    func startInDebugMode() async throws -> SuccessResponse {
        return try await start(config: .debug)
    }
}
