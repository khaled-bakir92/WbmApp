//
//  BotStatus.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Datenmodell für GET /api/bot/status Response
struct BotStatus: Decodable {
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
