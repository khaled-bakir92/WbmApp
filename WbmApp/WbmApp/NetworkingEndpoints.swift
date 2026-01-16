//
//  Endpoints.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Alle API-Endpoints zentral definiert
/// Verhindert String-Typos und erhöht Wartbarkeit
enum APIEndpoint {
    
    // MARK: - Root
    case health
    
    // MARK: - Bot Lifecycle
    case botStatus
    case botStart
    case botStop
    case botRestart
    
    // MARK: - Configuration
    case filterConfig
    case userConfig
    
    // MARK: - Monitoring
    case monitorStats
    case monitorLogs(lines: Int)
    case screenshots
    case screenshot(filename: String)
    
    // MARK: - Path Builder
    
    var path: String {
        switch self {
        // Root
        case .health:
            return "/health"
            
        // Bot Lifecycle
        case .botStatus:
            return "/api/bot/status"
        case .botStart:
            return "/api/bot/start"
        case .botStop:
            return "/api/bot/stop"
        case .botRestart:
            return "/api/bot/restart"
            
        // Configuration
        case .filterConfig:
            return "/api/config/filter"
        case .userConfig:
            return "/api/config/user"
            
        // Monitoring
        case .monitorStats:
            return "/api/monitor/stats"
        case .monitorLogs(let lines):
            return "/api/monitor/logs?lines=\(lines)"
        case .screenshots:
            return "/api/monitor/screenshots"
        case .screenshot(let filename):
            return "/api/monitor/screenshots/\(filename)"
        }
    }
    
    // MARK: - HTTP Method
    
    var method: HTTPMethod {
        switch self {
        case .health, .botStatus, .filterConfig, .userConfig, 
             .monitorStats, .monitorLogs, .screenshots, .screenshot:
            return .get
            
        case .botStart, .botStop, .botRestart:
            return .post
        }
    }
}
