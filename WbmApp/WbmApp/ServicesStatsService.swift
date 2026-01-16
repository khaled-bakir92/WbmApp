//
//  StatsService.swift
//  WbmApp
//
//  Created by khaled Bakir on 1/17/26.
//

import Foundation

/// Service für Wohnungsstatistiken
final class StatsService: Sendable {
    private let client = APIClient.shared
    
    /// Lädt Wohnungsstatistiken vom Backend
    /// - Returns: ListingStats mit allen Statistiken
    /// - Throws: APIError bei Netzwerk- oder Parsing-Fehlern
    func getListingStats() async throws -> ListingStats {
        let endpoint = "/api/stats/listings"
        return try await client.request(method: .get, path: endpoint)
    }
    
    /// Lädt nur wöchentliche Daten
    /// - Parameter weeks: Anzahl der zurückliegenden Wochen (Standard: 8)
    /// - Returns: Array von WeeklyListing
    func getWeeklyData(weeks: Int = 8) async throws -> [WeeklyListing] {
        let endpoint = "/api/stats/weekly?weeks=\(weeks)"
        return try await client.request(method: .get, path: endpoint)
    }
}

// MARK: - Mock Implementation für Entwicklung

extension StatsService {
    /// Mock-Daten für Entwicklung (wenn Backend noch nicht verfügbar)
    func getMockStats() async -> ListingStats {
        // Simuliere Netzwerk-Verzögerung
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 Sekunden
        
        return ListingStats(
            totalListings: 156,
            matchedListings: 42,
            appliedListings: 18,
            weeklyData: generateMockWeeklyData()
        )
    }
    
    private func generateMockWeeklyData() -> [WeeklyListing] {
        let calendar = Calendar.current
        let now = Date()
        
        return (0..<8).map { weekOffset in
            let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now)!
            let weekNumber = calendar.component(.weekOfYear, from: date)
            let year = calendar.component(.year, from: date)
            
            let formatter = ISO8601DateFormatter()
            let startDate = formatter.string(from: date)
            
            // Simuliere realistische Werte
            let totalCount = Int.random(in: 15...60)
            let matchedCount = Int.random(in: 2...15)
            
            return WeeklyListing(
                id: "\(year)-W\(weekNumber)",
                weekNumber: weekNumber,
                year: year,
                totalCount: totalCount,
                matchedCount: matchedCount,
                startDate: startDate
            )
        }.reversed()
    }
}
