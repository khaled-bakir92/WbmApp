//
//  WeeklyListingsChart.swift
//  WbmApp
//
//  Created by khaled Bakir on 1/17/26.
//

import SwiftUI
import Charts

/// Chart-Komponente für wöchentliche Wohnungsstatistiken
/// Zeigt Vergleich zwischen gefundenen Angeboten und passenden Wohnungen
struct WeeklyListingsChart: View {
    let weeklyData: [WeeklyListing]
    
    @State private var selectedWeek: WeeklyListing?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wöchentliche Übersicht")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Gefundene vs. Passende Wohnungen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Legend
                HStack(spacing: 12) {
                    LegendItem(color: .blue, label: "Gefunden")
                    LegendItem(color: .green, label: "Passend")
                }
            }
            
            // Chart
            Chart {
                ForEach(weeklyData) { week in
                    // Gefundene Angebote (Total)
                    BarMark(
                        x: .value("Woche", week.shortLabel),
                        y: .value("Anzahl", week.totalCount)
                    )
                    .foregroundStyle(.blue.opacity(0.6))
                    .position(by: .value("Typ", "Gefunden"))
                    
                    // Passende Wohnungen (Matched)
                    BarMark(
                        x: .value("Woche", week.shortLabel),
                        y: .value("Anzahl", week.matchedCount)
                    )
                    .foregroundStyle(.green.opacity(0.8))
                    .position(by: .value("Typ", "Passend"))
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .chartLegend(.hidden) // Wir haben eigene Legend
            .frame(height: 220)
            .chartXSelection(value: $selectedWeek)
            
            // Details für ausgewählte Woche
            if let selected = selectedWeek {
                DetailCard(week: selected)
            } else if let latest = weeklyData.last {
                // Zeige aktuellste Woche standardmäßig
                DetailCard(week: latest)
            }
        }
    }
}

// MARK: - Supporting Views

/// Legende-Item
private struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

/// Detail-Karte für ausgewählte Woche
private struct DetailCard: View {
    let week: WeeklyListing
    
    var matchRate: Double {
        guard week.totalCount > 0 else { return 0 }
        return Double(week.matchedCount) / Double(week.totalCount) * 100
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Woche Info
            VStack(alignment: .leading, spacing: 4) {
                Text(week.fullLabel)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(week.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Statistiken
            HStack(spacing: 20) {
                StatColumn(
                    value: "\(week.totalCount)",
                    label: "Gefunden",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 30)
                
                StatColumn(
                    value: "\(week.matchedCount)",
                    label: "Passend",
                    color: .green
                )
                
                Divider()
                    .frame(height: 30)
                
                StatColumn(
                    value: String(format: "%.0f%%", matchRate),
                    label: "Match",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Spalte mit Wert und Label
private struct StatColumn: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Helper Extensions

private extension WeeklyListing {
    /// Formatiertes Datum für Detail-Anzeige
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: startDate) else {
            return startDate
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        displayFormatter.locale = Locale(identifier: "de_DE")
        
        return displayFormatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Chart mit Daten") {
    WeeklyListingsChart(weeklyData: ListingStats.mock.weeklyData)
        .padding()
        .background(Color(uiColor: .systemBackground))
}

#Preview("Chart in Card") {
    VStack {
        // Simuliere GlassCard Stil
        WeeklyListingsChart(weeklyData: ListingStats.mock.weeklyData)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .padding()
    }
}
