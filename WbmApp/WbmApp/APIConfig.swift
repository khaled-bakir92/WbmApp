//
//  APIConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

struct APIConfig {
    /// Base URL des lokalen FastAPI Backends
    static let baseURL = "http://127.0.0.1:8000"
    
    /// Bearer Token für Authentifizierung
    /// TODO: In Production aus Keychain laden
    static let bearerToken = "YOUR_API_TOKEN_HERE"
    
    /// Vollständige URL für einen Endpoint
    static func url(for path: String) -> URL? {
        return URL(string: baseURL + path)
    }
}
