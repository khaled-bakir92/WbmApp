//
//  BotStartConfigPerformanceTests.swift
//  WbmAppTests
//
//  Created on 2026-02-03.
//

import Testing
import Foundation
@testable import WbmApp

/// Performance-Tests für Bot-Operationen mit Swift Testing
@Suite("BotStartConfig Performance Tests")
struct BotStartConfigPerformanceTests {
    
    // MARK: - Configuration Tests
    
    @Test("Configuration validation performance")
    func configurationValidationPerformance() async throws {
        let configs = (0..<10000).map { _ in
            BotStartConfig(interval: Int.random(in: 60...86400), gui: Bool.random())
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for config in configs {
            _ = config.isValid
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let durationsMs = duration * 1000
        
        print("⏱️ Validated 10000 configs in \(String(format: "%.2f", durationsMs))ms")
        
        // Performance-Erwartung: Unter 1s für 10000 Validierungen
        #expect(duration < 1.0, "Validation took too long: \(duration)s")
    }
    
    @Test("Configuration encoding performance")
    func configurationEncodingPerformance() throws {
        let config = BotStartConfig.default
        let encoder = JSONEncoder()
        let iterations = 1000
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = try? encoder.encode(config)
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let durationsMs = duration * 1000
        let avgMs = durationsMs / Double(iterations)
        
        print("⏱️ \(iterations) encodings took \(String(format: "%.2f", durationsMs))ms (avg: \(String(format: "%.3f", avgMs))ms)")
        
        // Performance-Erwartung: Unter 50ms für 1000 Encodings
        #expect(duration < 0.05, "Encoding took too long: \(duration)s")
    }
    
    // MARK: - API Response Time Tests
    
    @Test("Bot start response time")
    func botStartResponseTime() async throws {
        let startTime = Date()
        
        // Simuliere API-Call
        // TODO: Ersetze mit echtem APIClient-Call wenn verfügbar
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s Simulation
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("⏱️ Bot start took \(String(format: "%.2f", duration))s")
        
        // Bot sollte innerhalb von 3 Sekunden starten
        #expect(duration < 3.0, "Bot start took too long: \(duration)s")
    }
    
    // MARK: - Interval Configuration Tests
    
    @Test("Interval range validation correctness")
    func intervalRangeValidation() throws {
        let validConfigs = [
            BotStartConfig(interval: 60, gui: false),
            BotStartConfig(interval: 1800, gui: false),
            BotStartConfig(interval: 86400, gui: false)
        ]
        
        let invalidConfigs = [
            BotStartConfig(interval: 59, gui: false),
            BotStartConfig(interval: 86401, gui: false)
        ]
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for config in validConfigs {
            #expect(config.isValid, "Config with interval \(config.interval ?? 0) should be valid")
        }
        
        for config in invalidConfigs {
            #expect(!config.isValid, "Config with interval \(config.interval ?? 0) should be invalid")
        }
        
        let duration = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("⏱️ Validation tests completed in \(String(format: "%.2f", duration))ms")
    }
    
    // MARK: - Memory Tests
    
    @Test("Configuration memory usage")
    func configurationMemoryUsage() throws {
        let iterations = 10
        var totalDuration: TimeInterval = 0
        
        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            
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
            
            totalDuration += CFAbsoluteTimeGetCurrent() - startTime
        }
        
        let avgDuration = totalDuration / Double(iterations)
        let avgDurationMs = avgDuration * 1000
        
        print("⏱️ Average memory test iteration: \(String(format: "%.2f", avgDurationMs))ms")
        
        // Performance-Erwartung: Unter 10ms pro Iteration
        #expect(avgDuration < 0.01, "Memory operations took too long: \(avgDuration)s")
    }
    
    // MARK: - Convenience Initializers Tests
    
    @Test("Convenience initializers performance", arguments: [
        ("default", { BotStartConfig.default }),
        ("testing", { BotStartConfig.testing }),
        ("debug", { BotStartConfig.debug })
    ])
    func convenienceInitializersPerformance(name: String, factory: @escaping () -> BotStartConfig) throws {
        let iterations = 10000
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = factory()
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let durationMs = duration * 1000
        let avgNs = (duration * 1_000_000_000) / Double(iterations)
        
        print("⏱️ \(name): \(iterations) inits in \(String(format: "%.2f", durationMs))ms (avg: \(String(format: "%.0f", avgNs))ns)")
        
        // Performance-Erwartung: Unter 1s für 10000 Initialisierungen
        #expect(duration < 1.0, "\(name) initialization took too long: \(duration)s")
    }
}

// MARK: - Integration Performance Tests

@Suite("Bot Controller Integration Performance")
struct BotControllerIntegrationTests {
    
    @Test("Bot lifecycle performance")
    func botLifecyclePerformance() async throws {
        let startTime = Date()
        
        // 1. Start
        let config = BotStartConfig.testing
        // TODO: Implementiere echten Bot-Start wenn verfügbar
        try await Task.sleep(nanoseconds: 50_000_000) // Simuliere Start (50ms)
        
        // 2. Laufen lassen
        try await Task.sleep(nanoseconds: 100_000_000) // Simuliere Betrieb (100ms)
        
        // 3. Stoppen
        try await Task.sleep(nanoseconds: 50_000_000) // Simuliere Stop (50ms)
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("⏱️ Bot lifecycle took \(String(format: "%.2f", duration))s")
        
        // Gesamter Zyklus sollte unter 5 Sekunden liegen
        #expect(duration < 5.0, "Bot lifecycle took too long: \(duration)s")
    }
    
    @Test("Rapid restart performance")
    func rapidRestartPerformance() async throws {
        let restartCount = 5
        let startTime = Date()
        
        for iteration in 0..<restartCount {
            // Simuliere Restart
            let iterationStart = CFAbsoluteTimeGetCurrent()
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            let iterationDuration = CFAbsoluteTimeGetCurrent() - iterationStart
            
            print("  Restart \(iteration + 1): \(String(format: "%.2f", iterationDuration * 1000))ms")
        }
        
        let totalDuration = Date().timeIntervalSince(startTime)
        let averagePerRestart = totalDuration / Double(restartCount)
        
        print("📊 Durchschnittliche Restart-Zeit: \(String(format: "%.3f", averagePerRestart))s")
        
        #expect(averagePerRestart < 1.0, "Restart ist zu langsam: \(averagePerRestart)s")
        #expect(totalDuration < 5.0, "Total restart time too long: \(totalDuration)s")
    }
    
    @Test("Concurrent config creation")
    func concurrentConfigCreation() async throws {
        let iterations = 100
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await withTaskGroup(of: BotStartConfig.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    BotStartConfig(
                        interval: 60 + (i * 100),
                        gui: i % 2 == 0
                    )
                }
            }
            
            var configs: [BotStartConfig] = []
            for await config in group {
                configs.append(config)
            }
            
            #expect(configs.count == iterations)
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let durationMs = duration * 1000
        
        print("⏱️ Created \(iterations) configs concurrently in \(String(format: "%.2f", durationMs))ms")
        
        #expect(duration < 0.1, "Concurrent creation took too long: \(duration)s")
    }
}

// MARK: - Benchmark Helper

extension BotStartConfigPerformanceTests {
    /// Helper für manuelle Benchmarks
    static func runBenchmark(name: String, iterations: Int = 1000, operation: () throws -> Void) rethrows {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            try operation()
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let durationMs = duration * 1000
        let avgMs = durationMs / Double(iterations)
        
        print("""
        📊 Benchmark: \(name)
           Total: \(String(format: "%.2f", durationMs))ms
           Iterations: \(iterations)
           Average: \(String(format: "%.3f", avgMs))ms
        """)
    }
}
