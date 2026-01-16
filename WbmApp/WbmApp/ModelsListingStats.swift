//
//  ListingStats.swift
//  WbmApp
//
//  Created by khaled Bakir on 1/17/26.
//

import Foundation

/// Statistiken für Wohnungsangebote
struct ListingStats: Codable, Sendable, Equatable {
    let totalListings: Int           // Gesamt gefundene Angebote
    let matchedListings: Int         // Passende Wohnungen
    let appliedListings: Int         // Beworbene Wohnungen
    let weeklyData: [WeeklyListing]  // Daten pro Woche
    
    enum CodingKeys: String, CodingKey {
        case totalListings = "total_listings"
        case matchedListings = "matched_listings"
        case appliedListings = "applied_listings"
        case weeklyData = "weekly_data"
    }
}

/// Wöchentliche Statistik-Daten für Chart
struct WeeklyListing: Codable, Identifiable, Sendable, Equatable {
    let id: String          // z.B. "2026-W3" (Jahr-Woche)
    let weekNumber: Int     // Wochennummer
    let year: Int          // Jahr
    let count: Int         // Anzahl passender Wohnungen
    let startDate: String  // ISO8601 Format
    
    enum CodingKeys: String, CodingKey {
        case id
        case weekNumber = "week_number"
        case year
        case count
        case startDate = "start_date"
    }
}

// MARK: - Mock Data für Entwicklung

extension ListingStats {
    /// Beispieldaten für Preview/Testing
    static var mock: ListingStats {
        ListingStats(
            totalListings: 127,
            matchedListings: 34,
            appliedListings: 12,
            weeklyData: [
                WeeklyListing(
                    id: "2026-W1",
                    weekNumber: 1,
                    year: 2026,
                    count: 3,
                    startDate: "2026-01-01T00:00:00Z"
                ),
                WeeklyListing(
                    id: "2026-W2",
                    weekNumber: 2,
                    year: 2026,
                    count: 7,
                    startDate: "2026-01-08T00:00:00Z"
                ),
                WeeklyListing(
                    id: "2026-W3",
                    weekNumber: 3,
                    year: 2026,
                    count: 12,
                    startDate: "2026-01-15T00:00:00Z"
                )
            ]
        )
    }
    
    /// Leere Statistiken
    static var empty: ListingStats {
        ListingStats(
            totalListings: 0,
            matchedListings: 0,
            appliedListings: 0,
            weeklyData: []
        )
    }
}

// MARK: - Helper Extensions

extension WeeklyListing {
    /// Formatiertes Datum für Chart-Anzeige
    var displayDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: startDate) ?? Date()
    }
    
    /// Kurze Wochen-Bezeichnung (z.B. "KW 3")
    var shortLabel: String {
        "KW \(weekNumber)"
    }
    
    /// Vollständige Bezeichnung (z.B. "Woche 3, 2026")
    var fullLabel: String {
        "Woche \(weekNumber), \(year)"
    }
}
