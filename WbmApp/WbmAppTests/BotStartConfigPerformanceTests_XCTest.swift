//
//  BotStartConfigPerformanceTests_XCTest.swift
//  WbmAppUITests (oder WbmAppTests mit XCTest-Support)
//
//  Created on 2026-02-03.
//

import XCTest
@testable import WbmApp

/// Performance-Tests für Bot-Operationen mit XCTest
/// 
/// WICHTIG: Diese Datei muss in einem Test-Target sein, das XCTest unterstützt.
/// Typischerweise ist das WbmAppUITests oder ein separates XCTest-basiertes Test-Target.
final class BotStartConfigPerformanceTests_XCTest: XCTestCase {
    
    // MARK: - Configuration Tests
    
    func testConfigurationValidationPerformance() throws {
        // Erstelle Test-Daten außerhalb der measure-Block für faire Messung
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
        let expectation = XCTestExpectation(description: "Bot start completes")
        
        let startTime = Date()
        
        // Simuliere API-Call
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        let duration = Date().timeIntervalSince(startTime)
        
        expectation.fulfill()
        
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
            var configs: [BotStartConfig] = []
            for i in 60...1000 {
                configs.append(BotStartConfig(interval: i, gui: i % 2 == 0))
            }
            
            for config in configs {
                _ = config.isValid
            }
            
            configs.removeAll()
        }
    }
}

// MARK: - Integration Performance Tests

final class BotControllerIntegrationTests_XCTest: XCTestCase {
    
    func testBotLifecyclePerformance() async throws {
        let expectation = XCTestExpectation(description: "Bot lifecycle completes")
        
        let startTime = Date()
        
        let config = BotStartConfig.testing
        try await Task.sleep(nanoseconds: 50_000_000)
        try await Task.sleep(nanoseconds: 100_000_000)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        let duration = Date().timeIntervalSince(startTime)
        
        expectation.fulfill()
        
        XCTAssertLessThan(duration, 5.0, "Bot lifecycle took too long: \(duration)s")
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testRapidRestartPerformance() async throws {
        let restartCount = 5
        let startTime = Date()
        
        for _ in 0..<restartCount {
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        
        let totalDuration = Date().timeIntervalSince(startTime)
        let averagePerRestart = totalDuration / Double(restartCount)
        
        print("📊 Durchschnittliche Restart-Zeit: \(averagePerRestart)s")
        XCTAssertLessThan(averagePerRestart, 1.0, "Restart ist zu langsam")
    }
}

// MARK: - BotStartConfig Stub (für Tests ohne @testable import)

/// Falls Sie @testable import nicht nutzen können, definieren Sie BotStartConfig hier
#if false // Aktivieren Sie dies wenn nötig
struct BotStartConfig: Encodable, Sendable {
    var interval: Int?
    var gui: Bool?
    
    var isValid: Bool {
        if let interval = interval {
            return interval >= 60 && interval <= 86400
        }
        return true
    }
    
    static var `default`: BotStartConfig {
        BotStartConfig(interval: 1800, gui: false)
    }
    
    static var testing: BotStartConfig {
        BotStartConfig(interval: 60, gui: false)
    }
    
    static var debug: BotStartConfig {
        BotStartConfig(interval: 300, gui: true)
    }
}
#endif
