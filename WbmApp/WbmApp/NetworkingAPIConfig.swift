//
//  APIConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation
// Uses KeychainHelper for production token loading

/// Zentrale Konfiguration für API-Zugriff
struct APIConfig: Sendable {
    /// Base URL des lokalen FastAPI Backends
    nonisolated(unsafe) static let baseURL = "http://127.0.0.1:8000"
    
    #if DEBUG
    /// Bearer Token für Authentifizierung (Debug: Aus Secrets.swift)
    nonisolated(unsafe) static let bearerToken: String = Secrets.bearerToken
    #else
    /// Bearer Token für Authentifizierung (Production: Aus Keychain)
    /// Hinweis: Vor App-Start muss der Token einmalig in die Keychain gespeichert werden.
    /// Beispiel zum Setzen (z.B. in AppDelegate/Setup):
    /// `KeychainHelper.shared.saveBearerToken("<TOKEN>")`
    nonisolated(unsafe) static let bearerToken: String = {
        if let token = KeychainHelper.shared.readBearerToken(), !token.isEmpty {
            return token
        } else {
            assertionFailure("Bearer-Token fehlt in Keychain. Bitte mit KeychainHelper.shared.saveBearerToken(_) setzen.")
            return "" // Fallback: leerer Token → führt zu 401
        }
    }()
    #endif
    
    /// Vollständige URL für einen Endpoint
    nonisolated(unsafe) static func url(for path: String) -> URL? {
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
    /// Lädt den Token in Production aus der Keychain (siehe bearerToken-Implementierung)
    static var production: APIConfig.Type {
        return APIConfig.self
    }
}

