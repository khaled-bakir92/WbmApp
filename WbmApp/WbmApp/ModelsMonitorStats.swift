//
//  MonitorStats.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Response-Model für GET /api/monitor/stats
struct MonitorStats: Decodable, Sendable, Equatable {
    let knownListingsCount: Int
    let lastCheckTime: String?
    let lastListingFound: String?
    let totalFormsSubmitted: Int
    let totalErrors24h: Int
    let botRunning: Bool
    
    enum CodingKeys: String, CodingKey {
        case knownListingsCount = "known_listings_count"
        case lastCheckTime = "last_check_time"
        case lastListingFound = "last_listing_found"
        case totalFormsSubmitted = "total_forms_submitted"
        case totalErrors24h = "total_errors_24h"
        case botRunning = "bot_running"
    }
}

// MARK: - Computed Properties

extension MonitorStats {
    /// Formatierte letzte Check-Zeit
    var formattedLastCheck: String {
        guard let lastCheck = lastCheckTime else {
            return "Noch nie"
        }
        return formatTimestamp(lastCheck)
    }
    
    /// Formatierte letzte Listing-Zeit
    var formattedLastListing: String {
        guard let lastListing = lastListingFound else {
            return "Noch nie"
        }
        return formatTimestamp(lastListing)
    }
    
    /// Status-Indikator für Fehler
    var errorIndicator: String {
        totalErrors24h == 0 ? "✅" : "⚠️"
    }
    
    /// Gesundheitsstatus
    var healthStatus: HealthStatus {
        if !botRunning {
            return .stopped
        } else if totalErrors24h > 10 {
            return .unhealthy
        } else if totalErrors24h > 0 {
            return .warning
        } else {
            return .healthy
        }
    }
    
    private func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: timestamp) else {
            return timestamp
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "de_DE")
        
        return displayFormatter.string(from: date)
    }
}

// MARK: - Health Status

enum HealthStatus {
    case healthy
    case warning
    case unhealthy
    case stopped
    
    var color: String {
        switch self {
        case .healthy: return "green"
        case .warning: return "orange"
        case .unhealthy: return "red"
        case .stopped: return "gray"
        }
    }
    
    var emoji: String {
        switch self {
        case .healthy: return "✅"
        case .warning: return "⚠️"
        case .unhealthy: return "❌"
        case .stopped: return "⏸️"
        }
    }
}
