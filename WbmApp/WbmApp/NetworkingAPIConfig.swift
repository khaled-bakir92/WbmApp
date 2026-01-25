//
//  APIConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Zentrale Konfiguration für API-Zugriff
struct APIConfig: Sendable {

    // MARK: - Base URL

    /// Produktions-Backend (VPS mit HTTPS)
    nonisolated(unsafe) static let baseURL = "https://wbm-bot.duckdns.org"


    // MARK: - Bearer Token

    /// Token aus Secrets.swift
    nonisolated(unsafe) static let bearerToken: String = Secrets.bearerToken


    // MARK: - URL Builder

    nonisolated(unsafe) static func url(for path: String) -> URL? {
        URL(string: baseURL + path)
    }
}

