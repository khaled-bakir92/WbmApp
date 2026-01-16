//
//  APIConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Zentrale Konfiguration für API-Zugriff
struct APIConfig {
    /// Base URL des lokalen FastAPI Backends
    static let baseURL = "http://127.0.0.1:8000"
    
    /// Bearer Token für Authentifizierung
    /// TODO: In Production aus Keychain laden
    static let bearerToken = "***REMOVED***"
    
    /// Vollständige URL für einen Endpoint
    static func url(for path: String) -> URL? {
        return URL(string: baseURL + path)
    }
}

// MARK: - Environment-Specific Configs

extension APIConfig {
    /// Entwicklungs-Konfiguration
    static var development: APIConfig.Type {
        return APIConfig.self
    }
    
    /// Produktions-Konfiguration
    /// TODO: Später aus .env oder Keychain laden
    static var production: APIConfig.Type {
        return APIConfig.self
    }
}
