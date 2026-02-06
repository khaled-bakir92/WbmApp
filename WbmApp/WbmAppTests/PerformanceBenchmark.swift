//
//  PerformanceBenchmark.swift
//  WBM Bot Controller
//
//  Created on 2026-02-03.
//

import Foundation
import os.log
@testable import WbmApp

/// Utility für detaillierte Performance-Messungen
struct PerformanceBenchmark: Sendable {
    
    private static let logger = Logger(subsystem: "com.wbm.bot", category: "benchmark")
    
    /// Ergebnis einer Performance-Messung
    struct Result: Sendable {
        let operation: String
        let duration: TimeInterval // in Sekunden
        let iterations: Int
        let averageDuration: TimeInterval
        let minDuration: TimeInterval
        let maxDuration: TimeInterval
        
        var durationMs: Double { duration * 1000 }
        var averageDurationMs: Double { averageDuration * 1000 }
        var minDurationMs: Double { minDuration * 1000 }
        var maxDurationMs: Double { maxDuration * 1000 }
        
        /// Gibt eine formatierte Zusammenfassung aus
        func printSummary() {
            print("""
            
            📊 Performance Benchmark: \(operation)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            Iterationen:        \(iterations)
            Gesamtdauer:        \(String(format: "%.2f", durationMs))ms
            Durchschnitt:       \(String(format: "%.2f", averageDurationMs))ms
            Minimum:            \(String(format: "%.2f", minDurationMs))ms
            Maximum:            \(String(format: "%.2f", maxDurationMs))ms
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            """)
        }
    }
    
    /// Führt einen synchronen Benchmark aus
    /// - Parameters:
    ///   - name: Name der Operation
    ///   - iterations: Anzahl der Iterationen (Standard: 100)
    ///   - warmup: Anzahl der Warmup-Iterationen (Standard: 10)
    ///   - block: Die zu messende Operation
    /// - Returns: Benchmark-Ergebnis
    static func measure(
        _ name: String,
        iterations: Int = 100,
        warmup: Int = 10,
        block: () throws -> Void
    ) rethrows -> Result {
        // Warmup-Phase
        for _ in 0..<warmup {
            try block()
        }
        
        // Messung
        var durations: [TimeInterval] = []
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            let iterationStart = CFAbsoluteTimeGetCurrent()
            try block()
            let iterationEnd = CFAbsoluteTimeGetCurrent()
            durations.append(iterationEnd - iterationStart)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalDuration = endTime - startTime
        
        let result = Result(
            operation: name,
            duration: totalDuration,
            iterations: iterations,
            averageDuration: durations.reduce(0, +) / Double(iterations),
            minDuration: durations.min() ?? 0,
            maxDuration: durations.max() ?? 0
        )
        
        logger.info("📊 \(name): avg=\(result.averageDurationMs, format: .fixed(precision: 2))ms")
        
        return result
    }
    
    /// Führt einen asynchronen Benchmark aus
    /// - Parameters:
    ///   - name: Name der Operation
    ///   - iterations: Anzahl der Iterationen (Standard: 100)
    ///   - warmup: Anzahl der Warmup-Iterationen (Standard: 10)
    ///   - block: Die zu messende asynchrone Operation
    /// - Returns: Benchmark-Ergebnis
    static func measure(
        _ name: String,
        iterations: Int = 100,
        warmup: Int = 10,
        block: () async throws -> Void
    ) async rethrows -> Result {
        // Warmup-Phase
        for _ in 0..<warmup {
            try await block()
        }
        
        // Messung
        var durations: [TimeInterval] = []
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            let iterationStart = CFAbsoluteTimeGetCurrent()
            try await block()
            let iterationEnd = CFAbsoluteTimeGetCurrent()
            durations.append(iterationEnd - iterationStart)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalDuration = endTime - startTime
        
        let result = Result(
            operation: name,
            duration: totalDuration,
            iterations: iterations,
            averageDuration: durations.reduce(0, +) / Double(iterations),
            minDuration: durations.min() ?? 0,
            maxDuration: durations.max() ?? 0
        )
        
        logger.info("📊 \(name): avg=\(result.averageDurationMs, format: .fixed(precision: 2))ms")
        
        return result
    }
    
    /// Vergleicht mehrere Operationen
    static func compare(
        _ operations: [(name: String, operation: () throws -> Void)]
    ) throws {
        print("\n🔄 Running comparison benchmark...\n")
        
        var results: [Result] = []
        for (name, operation) in operations {
            let result = try measure(name, iterations: 100, warmup: 10, block: operation)
            results.append(result)
        }
        
        // Sortiere nach durchschnittlicher Dauer
        results.sort { $0.averageDuration < $1.averageDuration }
        
        print("\n📊 Benchmark Comparison (sorted by speed)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        for (index, result) in results.enumerated() {
            let rank = index == 0 ? "🥇" : index == 1 ? "🥈" : index == 2 ? "🥉" : "  "
            print("\(rank) \(result.operation)")
            print("   Avg: \(String(format: "%.2f", result.averageDurationMs))ms | " +
                  "Min: \(String(format: "%.2f", result.minDurationMs))ms | " +
                  "Max: \(String(format: "%.2f", result.maxDurationMs))ms")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}

// MARK: - Usage Examples

extension PerformanceBenchmark {
    /// Beispiel: Benchmarkt BotStartConfig-Operationen
    static func benchmarkBotStartConfig() throws {
        try compare([
            ("Default Config Creation", {
                _ = BotStartConfig.default
            }),
            ("Testing Config Creation", {
                _ = BotStartConfig.testing
            }),
            ("Debug Config Creation", {
                _ = BotStartConfig.debug
            }),
            ("Config Validation", {
                let config = BotStartConfig(interval: 1800, gui: false)
                _ = config.isValid
            }),
            ("Config Encoding", {
                let config = BotStartConfig.default
                let encoder = JSONEncoder()
                _ = try? encoder.encode(config)
            })
        ])
    }
}
