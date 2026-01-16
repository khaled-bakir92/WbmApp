//
//  StatsDebugView.swift
//  WbmApp
//
//  Created by khaled Bakir on 1/17/26.
//

import SwiftUI

/// Debug-View für Statistik-Daten (temporär)
/// Hilft zu verstehen, woher die Zahlen kommen
struct StatsDebugView: View {
    let stats: ListingStats?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let stats = stats {
                        // Gesamt-Statistiken
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gesamt-Statistiken")
                                    .font(.headline)
                                
                                DebugRow(label: "Total Listings", value: "\(stats.totalListings)")
                                DebugRow(label: "Matched Listings", value: "\(stats.matchedListings)")
                                DebugRow(label: "Applied Listings", value: "\(stats.appliedListings)")
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Wöchentliche Daten
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Wöchentliche Daten (\(stats.weeklyData.count) Wochen)")
                                    .font(.headline)
                                
                                ForEach(stats.weeklyData) { week in
                                    WeekDebugCard(week: week)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Probleme erkennen
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("🔍 Automatische Prüfung")
                                    .font(.headline)
                                
                                ForEach(detectIssues(stats), id: \.self) { issue in
                                    HStack(spacing: 8) {
                                        Text(issue.icon)
                                        Text(issue.message)
                                            .font(.caption)
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(issue.color.opacity(0.15))
                                    .cornerRadius(8)
                                }
                                
                                if detectIssues(stats).isEmpty {
                                    HStack {
                                        Text("✅")
                                        Text("Keine Probleme erkannt")
                                            .font(.caption)
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.green.opacity(0.15))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                    } else {
                        Text("❌ Keine Statistiken geladen")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Stats Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    struct Issue: Hashable {
        let icon: String
        let message: String
        let color: Color
    }
    
    func detectIssues(_ stats: ListingStats) -> [Issue] {
        var issues: [Issue] = []
        
        // Zu hohe Zahlen
        for week in stats.weeklyData {
            if week.totalCount > 150 {
                issues.append(Issue(
                    icon: "⚠️",
                    message: "\(week.id): totalCount (\(week.totalCount)) unrealistisch hoch",
                    color: .orange
                ))
            }
            
            if week.matchedCount > week.totalCount {
                issues.append(Issue(
                    icon: "❌",
                    message: "\(week.id): matchedCount > totalCount (unmöglich!)",
                    color: .red
                ))
            }
            
            if week.totalCount == week.matchedCount && week.totalCount > 0 {
                issues.append(Issue(
                    icon: "🤔",
                    message: "\(week.id): 100% Match-Rate (altes Format?)",
                    color: .yellow
                ))
            }
        }
        
        // Keine Daten
        if stats.weeklyData.isEmpty {
            issues.append(Issue(
                icon: "📭",
                message: "Keine wöchentlichen Daten vorhanden",
                color: .gray
            ))
        }
        
        return issues
    }
}

// MARK: - Supporting Views

private struct DebugRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

private struct WeekDebugCard: View {
    let week: WeeklyListing
    
    var matchRate: Double {
        guard week.totalCount > 0 else { return 0 }
        return Double(week.matchedCount) / Double(week.totalCount) * 100
    }
    
    var statusColor: Color {
        if week.totalCount > 150 { return .red }
        if week.totalCount > 100 { return .orange }
        if week.matchedCount > week.totalCount { return .red }
        return .green
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(week.id)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(week.totalCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Matched")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(week.matchedCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quote")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f%%", matchRate))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }
                
                Spacer()
            }
            
            // Warnungen
            if week.totalCount > 150 {
                Text("⚠️ Total zu hoch (>150)")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            
            if week.matchedCount > week.totalCount {
                Text("❌ Matched > Total (unmöglich!)")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            
            if week.totalCount == week.matchedCount && week.totalCount > 0 {
                Text("🤔 100% Match (altes API-Format?)")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    StatsDebugView(stats: ListingStats.mock)
}

#Preview("Mit Problem-Daten") {
    let problemStats = ListingStats(
        totalListings: 500,
        matchedListings: 100,
        appliedListings: 20,
        weeklyData: [
            WeeklyListing(
                id: "2026-W1",
                weekNumber: 1,
                year: 2026,
                totalCount: 280,  // Zu hoch!
                matchedCount: 280, // 100% Match!
                startDate: "2026-01-01T00:00:00Z"
            ),
            WeeklyListing(
                id: "2026-W2",
                weekNumber: 2,
                year: 2026,
                totalCount: 45,
                matchedCount: 80,  // Matched > Total!
                startDate: "2026-01-08T00:00:00Z"
            )
        ]
    )
    
    StatsDebugView(stats: problemStats)
}
