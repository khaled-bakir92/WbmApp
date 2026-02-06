//
//  BotStartConfig.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation
import os.log

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

// MARK: - Performance Monitoring

extension BotStartConfig {
    /// Logger für Performance-Messungen
    private static let performanceLogger = Logger(subsystem: "com.wbm.bot", category: "performance")
    
    /// Misst die Zeit für eine Bot-Operation
    /// - Parameters:
    ///   - operation: Name der Operation
    ///   - block: Die auszuführende Operation
    /// - Returns: Ergebnis der Operation
    static func measure<T>(
        _ operation: String,
        block: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let result = try block()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = (endTime - startTime) * 1000 // in Millisekunden
        
        performanceLogger.info("⏱️ \(operation) took \(duration, format: .fixed(precision: 2))ms")
        
        return result
    }
    
    /// Misst die Zeit für eine asynchrone Bot-Operation
    /// - Parameters:
    ///   - operation: Name der Operation
    ///   - block: Die auszuführende asynchrone Operation
    /// - Returns: Ergebnis der Operation
    static func measure<T>(
        _ operation: String,
        block: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let result = try await block()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = (endTime - startTime) * 1000 // in Millisekunden
        
        performanceLogger.info("⏱️ \(operation) took \(duration, format: .fixed(precision: 2))ms")
        
        return result
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
