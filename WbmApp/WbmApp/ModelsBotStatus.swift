//
//  BotStatus.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Response-Model für GET /api/bot/status
struct BotStatus: Decodable, Sendable, Equatable {
    let running: Bool
    let pid: Int?
    let startTime: String?
    let uptimeSeconds: Double?
    let interval: Int?
    let guiMode: Bool?
    let cpuPercent: Double?
    let memoryMb: Double?
    
    enum CodingKeys: String, CodingKey {
        case running
        case pid
        case startTime = "start_time"
        case uptimeSeconds = "uptime_seconds"
        case interval
        case guiMode = "gui_mode"
        case cpuPercent = "cpu_percent"
        case memoryMb = "memory_mb"
    }
}

// MARK: - Computed Properties

extension BotStatus {
    /// Formatierte Uptime als String
    var formattedUptime: String? {
        guard let uptime = uptimeSeconds else { return nil }
        
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        let seconds = Int(uptime) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    /// Formatierte CPU-Nutzung
    var formattedCPU: String? {
        guard let cpu = cpuPercent else { return nil }
        return String(format: "%.1f%%", cpu)
    }
    
    /// Formatierte Speicher-Nutzung
    var formattedMemory: String? {
        guard let memory = memoryMb else { return nil }
        return String(format: "%.1f MB", memory)
    }
    
    /// Status-Indikator für UI
    var statusIndicator: String {
        running ? "🟢" : "🔴"
    }
    
    /// Status-Text für UI
    var statusText: String {
        running ? "Running" : "Stopped"
    }
}
