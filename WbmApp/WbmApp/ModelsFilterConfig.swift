//
//  FilterConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Response/Request-Model für /api/config/filter
struct FilterConfig: Codable, Sendable, Equatable {
    var maxWarmmiete: Double
    var minZimmer: Int
    var wbsRequired: Bool?
    var excludedAreas: [String]
    
    enum CodingKeys: String, CodingKey {
        case maxWarmmiete = "max_warmmiete"
        case minZimmer = "min_zimmer"
        case wbsRequired = "wbs_required"
        case excludedAreas = "excluded_areas"
    }
}

// MARK: - Validation

extension FilterConfig {
    /// Validiert die Konfiguration
    var isValid: Bool {
        maxWarmmiete > 0 && minZimmer >= 1
    }
    
    /// WBS-Status als lesbarer Text
    var wbsStatusText: String {
        guard let wbsRequired = wbsRequired else {
            return "Egal"
        }
        return wbsRequired ? "Nur mit WBS" : "Ohne WBS"
    }
    
    /// Formatierte ausgeschlossene Gebiete
    var excludedAreasText: String {
        excludedAreas.isEmpty ? "Keine" : excludedAreas.joined(separator: ", ")
    }
}
