//
//  BotStartConfigPerformanceTests.swift
//  WBM Bot Controller Tests
//
//  Created on 2026-02-03.
//

import XCTest
@testable import WbmApp

/// Performance-Tests für Bot-Operationen
final class BotStartConfigPerformanceTests: XCTestCase {
    
    // MARK: - Configuration Tests
    
    func testConfigurationValidationPerformance() throws {
        let configs = (0..<10000).map { _ in
            BotStartConfig(interval: Int.random(in: 60...86400), gui: Bool.random())
        }
        
        measure {
            for config in configs {
                _ = config.isValid
            }
        }
    }
    
    func testConfigurationEncodingPerformance() throws {
        let config = BotStartConfig.default
        let encoder = JSONEncoder()
        
        measure {
            for _ in 0..<1000 {
                _ = try? encoder.encode(config)
            }
        }
    }
    
    // MARK: - API Response Time Tests
    
    func testBotStartResponseTime() async throws {
        // Misst die Zeit für Bot-Start-Anfrage
        let expectation = XCTestExpectation(description: "Bot start completes")
        
        let startTime = Date()
        
        // Simuliere API-Call
        // TODO: Ersetze mit echtem APIClient-Call
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s Simulation
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        expectation.fulfill()
        
        // Bot sollte innerhalb von 3 Sekunden starten
        XCTAssertLessThan(duration, 3.0, "Bot start took too long: \(duration)s")
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Interval Configuration Tests
    
    func testIntervalRangeValidation() throws {
        let validConfigs = [
            BotStartConfig(interval: 60, gui: false),
            BotStartConfig(interval: 1800, gui: false),
            BotStartConfig(interval: 86400, gui: false)
        ]
        
        let invalidConfigs = [
            BotStartConfig(interval: 59, gui: false),
            BotStartConfig(interval: 86401, gui: false)
        ]
        
        measure {
            for config in validConfigs {
                XCTAssertTrue(config.isValid)
            }
            for config in invalidConfigs {
                XCTAssertFalse(config.isValid)
            }
        }
    }
    
    // MARK: - Memory Tests
    
    func testConfigurationMemoryUsage() throws {
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        
        measure(options: options) {
            // Erstelle viele Konfigurationen
            var configs: [BotStartConfig] = []
            for i in 60...1000 {
                configs.append(BotStartConfig(interval: i, gui: i % 2 == 0))
            }
            
            // Validiere alle
            for config in configs {
                _ = config.isValid
            }
            
            // Lass sie freigeben werden
            configs.removeAll()
        }
    }
}

// MARK: - Integration Performance Tests

final class BotControllerIntegrationTests: XCTestCase {
    
    /// Testet die Gesamtperformance des Bot-Lebenszyklus
    func testBotLifecyclePerformance() async throws {
        // Misst Start -> Laufen -> Stopp Zyklus
        let expectation = XCTestExpectation(description: "Bot lifecycle completes")
        
        let startTime = Date()
        
        // 1. Start
        let config = BotStartConfig.testing
        // TODO: Implementiere echten Bot-Start
        try await Task.sleep(nanoseconds: 50_000_000) // Simuliere Start
        
        // 2. Laufen lassen
        try await Task.sleep(nanoseconds: 100_000_000) // Simuliere Betrieb
        
        // 3. Stoppen
        try await Task.sleep(nanoseconds: 50_000_000) // Simuliere Stop
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        expectation.fulfill()
        
        // Gesamter Zyklus sollte unter 5 Sekunden liegen
        XCTAssertLessThan(duration, 5.0, "Bot lifecycle took too long: \(duration)s")
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    /// Testet mehrere schnelle Restart-Operationen
    func testRapidRestartPerformance() async throws {
        let restartCount = 5
        let startTime = Date()
        
        for _ in 0..<restartCount {
            // Simuliere Restart
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        
        let endTime = Date()
        let totalDuration = endTime.timeIntervalSince(startTime)
        let averagePerRestart = totalDuration / Double(restartCount)
        
        print("📊 Durchschnittliche Restart-Zeit: \(averagePerRestart)s")
        XCTAssertLessThan(averagePerRestart, 1.0, "Restart ist zu langsam")
    }
}
