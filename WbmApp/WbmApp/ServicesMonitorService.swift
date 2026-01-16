//
//  MonitorService.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation
import Combine

/// Service-Layer für Monitoring und Logging
/// Verwaltet Statistiken, Logs und Screenshots
@MainActor
final class MonitorService: ObservableObject {
    private let client = APIClient.shared
    
    // MARK: - Statistics
    
    /// Holt die aktuellen Bot-Statistiken
    func getStats() async throws -> MonitorStats {
        return try await client.request(
            method: .get,
            path: APIEndpoint.monitorStats.path
        )
    }
    
    // MARK: - Logs
    
    /// Holt die letzten N Zeilen aus dem Bot-Log
    /// - Parameter lines: Anzahl der Zeilen (1-5000, Default: 100)
    func getLogs(lines: Int = 100) async throws -> LogResponse {
        let validLines = min(max(lines, 1), 5000)
        return try await client.request(
            method: .get,
            path: APIEndpoint.monitorLogs(lines: validLines).path
        )
    }
    
    /// Holt alle verfügbaren Log-Zeilen
    func getAllLogs() async throws -> LogResponse {
        return try await getLogs(lines: 5000)
    }
    
    /// Holt die letzten 50 Log-Zeilen (Quick View)
    func getRecentLogs() async throws -> LogResponse {
        return try await getLogs(lines: 50)
    }
    
    /// Alias: Logs abrufen (Deutsch)
    func fetchLogs(lines: Int = 100) async throws -> LogResponse {
        return try await getLogs(lines: lines)
    }
    
    // MARK: - Screenshots
    
    /// Listet alle verfügbaren Screenshots auf
    func listScreenshots() async throws -> ScreenshotListResponse {
        return try await client.request(
            method: .get,
            path: APIEndpoint.screenshots.path
        )
    }
    
    /// Lädt einen spezifischen Screenshot herunter
    /// - Parameter filename: Name der Screenshot-Datei
    /// - Returns: Bild-Daten als Data
    func downloadScreenshot(_ filename: String) async throws -> Data {
        return try await client.dataRequest(
            method: .get,
            path: APIEndpoint.screenshot(filename: filename).path
        )
    }
    
    // MARK: - Health Check
    
    /// Führt einen vollständigen Health-Check durch
    /// Kombiniert Bot-Status und Statistiken
    func performHealthCheck() async throws -> HealthCheckResult {
        async let statsTask = getStats()
        
        let stats = try await statsTask
        
        return HealthCheckResult(
            isHealthy: stats.healthStatus == .healthy,
            status: stats.healthStatus,
            knownListings: stats.knownListingsCount,
            errors24h: stats.totalErrors24h,
            lastCheck: stats.lastCheckTime
        )
    }
}

// MARK: - Screenshot List Response

struct ScreenshotListResponse: Decodable, Sendable {
    let screenshots: [ScreenshotInfo]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case screenshots
        case totalCount = "total_count"
    }
}

struct ScreenshotInfo: Decodable, Sendable, Identifiable {
    let filename: String
    let sizeBytes: Int
    let modifiedAt: String
    
    var id: String { filename }
    
    enum CodingKeys: String, CodingKey {
        case filename
        case sizeBytes = "size_bytes"
        case modifiedAt = "modified_at"
    }
    
    /// Formatierte Dateigröße
    var formattedSize: String {
        let kb = Double(sizeBytes) / 1024.0
        if kb > 1024 {
            return String(format: "%.2f MB", kb / 1024.0)
        }
        return String(format: "%.2f KB", kb)
    }
}

// MARK: - Health Check Result

struct HealthCheckResult {
    let isHealthy: Bool
    let status: HealthStatus
    let knownListings: Int
    let errors24h: Int
    let lastCheck: String?
    
    var summary: String {
        """
        Status: \(status.emoji)
        Bekannte Listings: \(knownListings)
        Fehler (24h): \(errors24h)
        Letzter Check: \(lastCheck ?? "Nie")
        """
    }
}

