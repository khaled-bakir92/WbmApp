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
    let id: String              // z.B. "2026-W3" (Jahr-Woche)
    let weekNumber: Int         // Wochennummer
    let year: Int              // Jahr
    let totalCount: Int        // Anzahl aller gefundenen Angebote
    let matchedCount: Int      // Anzahl passender Wohnungen
    let startDate: String      // ISO8601 Format
    
    enum CodingKeys: String, CodingKey {
        case id
        case weekNumber = "week_number"
        case year
        case totalCount = "total_count"
        case matchedCount = "matched_count"
        case startDate = "start_date"
        case count // Altes Format
    }
    
    // Für Backward-Kompatibilität mit altem API-Format
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        weekNumber = try container.decode(Int.self, forKey: .weekNumber)
        year = try container.decode(Int.self, forKey: .year)
        startDate = try container.decode(String.self, forKey: .startDate)
        
        // Versuche neue Felder zu lesen, falls nicht vorhanden, nutze altes Format
        if let total = try? container.decode(Int.self, forKey: .totalCount),
           let matched = try? container.decode(Int.self, forKey: .matchedCount) {
            // Neues Format mit total_count und matched_count
            totalCount = total
            matchedCount = matched
        } else if let count = try? container.decode(Int.self, forKey: .count) {
            // Altes Format: "count" wird als matched_count interpretiert
            // totalCount schätzen wir als 3x matched (realistischer)
            matchedCount = count
            totalCount = count * 3
        } else {
            // Keine Daten verfügbar
            totalCount = 0
            matchedCount = 0
        }
    }
    
    // Encoder für neues Format
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(weekNumber, forKey: .weekNumber)
        try container.encode(year, forKey: .year)
        try container.encode(totalCount, forKey: .totalCount)
        try container.encode(matchedCount, forKey: .matchedCount)
        try container.encode(startDate, forKey: .startDate)
    }
    
    init(id: String, weekNumber: Int, year: Int, totalCount: Int, matchedCount: Int, startDate: String) {
        self.id = id
        self.weekNumber = weekNumber
        self.year = year
        self.totalCount = totalCount
        self.matchedCount = matchedCount
        self.startDate = startDate
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
                    totalCount: 15,
                    matchedCount: 3,
                    startDate: "2026-01-01T00:00:00Z"
                ),
                WeeklyListing(
                    id: "2026-W2",
                    weekNumber: 2,
                    year: 2026,
                    totalCount: 28,
                    matchedCount: 7,
                    startDate: "2026-01-08T00:00:00Z"
                ),
                WeeklyListing(
                    id: "2026-W3",
                    weekNumber: 3,
                    year: 2026,
                    totalCount: 42,
                    matchedCount: 12,
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
