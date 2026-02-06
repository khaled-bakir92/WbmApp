//
//  PerformanceTestingExamples.swift
//  WBM Bot Controller
//
//  Created on 2026-02-03.
//

import Foundation
@testable import WbmApp

/// Beispiele für Performance-Tests in der Praxis
struct PerformanceTestingExamples {
    
    // MARK: - 1. Einfache Zeit-Messung
    
    /// Misst die Zeit einer Bot-Start-Operation
    static func exampleSimpleTiming() async {
        print("🔍 Example 1: Simple Timing\n")
        
        let result = await BotStartConfig.measure("Bot Start") {
            let config = BotStartConfig.default
            
            // Simuliere API-Call
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            
            return config
        }
        
        print("✅ Operation completed: \(result)")
    }
    
    // MARK: - 2. Detaillierter Benchmark
    
    /// Führt einen detaillierten Benchmark aus
    static func exampleDetailedBenchmark() {
        print("\n🔍 Example 2: Detailed Benchmark\n")
        
        let result = PerformanceBenchmark.measure(
            "Config Validation",
            iterations: 1000,
            warmup: 50
        ) {
            let config = BotStartConfig(interval: 1800, gui: false)
            _ = config.isValid
        }
        
        result.printSummary()
    }
    
    // MARK: - 3. Vergleichs-Benchmark
    
    /// Vergleicht verschiedene Konfigurationen
    static func exampleComparisonBenchmark() throws {
        print("\n🔍 Example 3: Comparison Benchmark\n")

        try PerformanceBenchmark.benchmarkBotStartConfig()
    }
    
    // MARK: - 4. Async/Await Performance
    
    /// Misst asynchrone Operationen
    static func exampleAsyncPerformance() async {
        print("\n🔍 Example 4: Async Performance\n")
        
        let result = await PerformanceBenchmark.measure(
            "Simulated API Call",
            iterations: 10,
            warmup: 2
        ) {
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        
        result.printSummary()
    }
    
    // MARK: - 5. Memory Profiling
    
    /// Misst Speichernutzung
    static func exampleMemoryProfiling() {
        print("\n🔍 Example 5: Memory Profiling\n")
        
        let beforeMemory = reportMemoryUsage()
        
        // Erstelle viele Konfigurationen
        var configs: [BotStartConfig] = []
        for i in 60...10000 {
            configs.append(BotStartConfig(interval: i, gui: i % 2 == 0))
        }
        
        let afterMemory = reportMemoryUsage()
        
        print("Memory before: \(formatBytes(beforeMemory))")
        print("Memory after: \(formatBytes(afterMemory))")
        print("Memory increase: \(formatBytes(afterMemory - beforeMemory))")
        
        // Cleanup
        configs.removeAll()
        
        let finalMemory = reportMemoryUsage()
        print("Memory after cleanup: \(formatBytes(finalMemory))\n")
    }
    
    // MARK: - 6. Real-World Scenario
    
    /// Simuliert ein realistisches Szenario
    static func exampleRealWorldScenario() async {
        print("\n🔍 Example 6: Real-World Scenario\n")
        print("Simulating bot lifecycle...\n")
        
        // Start
        let startResult = await BotStartConfig.measure("Bot Start") {
            let config = BotStartConfig.default
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
            return config
        }
        print("✅ Started: \(startResult)")
        
        // Laufen lassen
        _ = await BotStartConfig.measure("Bot Running (5 cycles)") {
            for i in 1...5 {
                print("  Cycle \(i)...")
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms pro Zyklus
            }
        }
        
        // Restart
        _ = await BotStartConfig.measure("Bot Restart") {
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
        }
        
        // Stop
        _ = await BotStartConfig.measure("Bot Stop") {
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
        
        print("\n✅ Lifecycle complete\n")
    }
    
    // MARK: - Helper Functions
    
    private static func reportMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    private static func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

