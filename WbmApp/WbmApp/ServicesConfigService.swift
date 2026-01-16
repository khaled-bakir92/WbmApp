//
//  ConfigService.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Service-Layer für Konfigurationsverwaltung
/// Verwaltet Filter- und Benutzer-Konfiguration
@MainActor
final class ConfigService: ObservableObject {
    private let client = APIClient.shared
    
    // MARK: - Filter Configuration
    
    /// Holt die aktuelle Filter-Konfiguration
    func getFilterConfig() async throws -> FilterConfig {
        return try await client.request(
            method: .get,
            path: APIEndpoint.filterConfig.path
        )
    }
    
    /// Aktualisiert die Filter-Konfiguration
    /// - Parameter config: Neue Filter-Konfiguration
    /// - Returns: Aktualisierte Konfiguration vom Server
    func updateFilterConfig(_ config: FilterConfig) async throws -> FilterConfig {
        guard config.isValid else {
            throw ConfigError.invalidConfiguration
        }
        
        return try await client.request(
            method: .put,
            path: APIEndpoint.filterConfig.path,
            body: config
        )
    }
    
    // MARK: - User Configuration
    
    /// Holt die aktuelle Benutzer-Konfiguration
    /// Achtung: SMTP-Passwort ist maskiert
    func getUserConfig() async throws -> UserConfig {
        return try await client.request(
            method: .get,
            path: APIEndpoint.userConfig.path
        )
    }
    
    /// Aktualisiert die Benutzer-Konfiguration
    /// - Parameter config: Neue Benutzer-Konfiguration
    /// - Returns: Aktualisierte Konfiguration vom Server
    func updateUserConfig(_ config: UserConfig) async throws -> UserConfig {
        guard config.userData.isValid else {
            throw ConfigError.invalidUserData
        }
        
        return try await client.request(
            method: .put,
            path: APIEndpoint.userConfig.path,
            body: config
        )
    }
    
    // MARK: - Partial Updates
    
    /// Aktualisiert nur die Filter-Parameter (partial update)
    func updateFilter(
        maxWarmmiete: Double? = nil,
        minZimmer: Int? = nil,
        wbsRequired: Bool? = nil,
        excludedAreas: [String]? = nil
    ) async throws -> FilterConfig {
        var config = try await getFilterConfig()
        
        if let maxWarmmiete = maxWarmmiete {
            config.maxWarmmiete = maxWarmmiete
        }
        if let minZimmer = minZimmer {
            config.minZimmer = minZimmer
        }
        if let wbsRequired = wbsRequired {
            config.wbsRequired = wbsRequired
        }
        if let excludedAreas = excludedAreas {
            config.excludedAreas = excludedAreas
        }
        
        return try await updateFilterConfig(config)
    }
    
    /// Fügt ein ausgeschlossenes Gebiet hinzu
    func addExcludedArea(_ area: String) async throws -> FilterConfig {
        var config = try await getFilterConfig()
        if !config.excludedAreas.contains(area) {
            config.excludedAreas.append(area)
        }
        return try await updateFilterConfig(config)
    }
    
    /// Entfernt ein ausgeschlossenes Gebiet
    func removeExcludedArea(_ area: String) async throws -> FilterConfig {
        var config = try await getFilterConfig()
        config.excludedAreas.removeAll { $0 == area }
        return try await updateFilterConfig(config)
    }
}

// MARK: - Config Error

enum ConfigError: Error, LocalizedError {
    case invalidConfiguration
    case invalidUserData
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Ungültige Filter-Konfiguration"
        case .invalidUserData:
            return "Ungültige Benutzerdaten"
        }
    }
}
