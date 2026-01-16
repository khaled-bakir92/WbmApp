//
//  BotStartConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Request-Body für POST /api/bot/start und /api/bot/restart
struct BotStartConfig: Encodable, Sendable {
    var interval: Int? // 60-86400 Sekunden
    var gui: Bool?
    
    /// Validiert die Konfiguration
    var isValid: Bool {
        if let interval = interval {
            return interval >= 60 && interval <= 86400
        }
        return true
    }
}

// MARK: - Convenience Initializers

extension BotStartConfig {
    /// Standard-Konfiguration (1800s, kein GUI)
    static var `default`: BotStartConfig {
        BotStartConfig(interval: 1800, gui: false)
    }
    
    /// Schnelle Test-Konfiguration (60s)
    static var testing: BotStartConfig {
        BotStartConfig(interval: 60, gui: false)
    }
    
    /// Debug-Konfiguration mit GUI
    static var debug: BotStartConfig {
        BotStartConfig(interval: 300, gui: true)
    }
}
