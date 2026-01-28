//
//  ModelsAppliedListing.swift
//  WBM Bot Controller
//
//  Created on 2026-01-26.
//

import Foundation

/// Model für eine beworbene Wohnung
struct AppliedListing: Decodable, Sendable, Identifiable, Equatable {
    let id: String?
    let titel: String
    let adresse: String
    let area: String
    let warmmiete: String
    let zimmer: String
    let hasWbs: Bool
    let url: String
    let appliedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case titel
        case adresse
        case area
        case warmmiete
        case zimmer
        case hasWbs = "has_wbs"
        case url
        case appliedAt = "applied_at"
    }

    /// Eindeutige ID für SwiftUI (fallback auf URL wenn keine ID vorhanden)
    var listingId: String {
        id ?? url
    }
}

// MARK: - Computed Properties

extension AppliedListing {
    /// Formatierte Miete mit Euro-Symbol
    var formattedRent: String {
        if let rent = Double(warmmiete) {
            return String(format: "%.0f EUR", rent)
        }
        return "\(warmmiete) EUR"
    }

    /// Formatierte Zimmerzahl
    var formattedRooms: String {
        "\(zimmer) Zimmer"
    }

    /// WBS Status als Text
    var wbsStatusText: String {
        hasWbs ? "WBS erforderlich" : "Ohne WBS"
    }

    /// Formatiertes Datum der Bewerbung
    var formattedAppliedDate: String {
        guard let appliedAt = appliedAt else {
            return "Unbekannt"
        }

        // Versuche einfaches DateFormatter (flexibler als ISO8601)
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        // Format: "2026-01-28T14:55:07.210710" (ohne Timezone)
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]

        for format in formats {
            inputFormatter.dateFormat = format
            if let date = inputFormatter.date(from: appliedAt) {
                return formatDate(date)
            }
        }

        return appliedAt
    }

    private func formatDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "de_DE")
        return displayFormatter.string(from: date)
    }
}

// MARK: - Response Model

/// Response für den Applied Listings Endpoint
struct AppliedListingsResponse: Decodable, Sendable {
    let listings: [AppliedListing]
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case listings
        case totalCount = "total_count"
    }
}
