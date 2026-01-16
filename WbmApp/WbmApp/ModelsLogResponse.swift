//
//  LogResponse.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Response-Model für GET /api/monitor/logs
struct LogResponse: Decodable, Sendable {
    let lines: [String]
    let totalLines: Int
    let fileSizeBytes: Int
    
    enum CodingKeys: String, CodingKey {
        case lines
        case totalLines = "total_lines"
        case fileSizeBytes = "file_size_bytes"
    }
}

// MARK: - Computed Properties

extension LogResponse {
    /// Formatierte Dateigröße
    var formattedFileSize: String {
        let kb = Double(fileSizeBytes) / 1024.0
        let mb = kb / 1024.0
        
        if mb >= 1.0 {
            return String(format: "%.2f MB", mb)
        } else {
            return String(format: "%.2f KB", kb)
        }
    }
    
    /// Kombinierter Log-Text
    var combinedText: String {
        lines.joined()
    }
    
    /// Anzahl der zurückgegebenen Zeilen
    var returnedLinesCount: Int {
        lines.count
    }
}
