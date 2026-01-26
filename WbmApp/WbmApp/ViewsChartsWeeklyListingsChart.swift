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
    
    @State private var selectedWeekID: String?
    
    var selectedWeek: WeeklyListing? {
        guard let id = selectedWeekID else { return nil }
        return weeklyData.first { $0.id == id }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wohnungsstatistik")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Gefundene vs. Beworbene Wohnungen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Legend
                HStack(spacing: 12) {
                    LegendItem(color: .blue, label: "Gefunden")
                    LegendItem(color: .indigo, label: "Beworben")
                }
            }
            
            // Chart
            if weeklyData.count > 1 {
                // Multi-Tag Chart
                Chart {
                    ForEach(weeklyData) { week in
                        // Gefundene Angebote (Total)
                        BarMark(
                            x: .value("Tag", week.weekdayLabel),
                            y: .value("Anzahl", week.totalCount)
                        )
                        .foregroundStyle(.blue.opacity(0.6))
                        .position(by: .value("Typ", "Alle"))
                        
                        // Passende Wohnungen (Matched)
                        BarMark(
                            x: .value("Tag", week.weekdayLabel),
                            y: .value("Anzahl", week.matchedCount)
                        )
                        .foregroundStyle(.indigo.opacity(0.7))
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
                .chartLegend(.hidden)
                .frame(height: 220)
                .chartXSelection(value: $selectedWeekID)
            } else if let single = weeklyData.first {
                // Single-Day Ansicht (vereinfacht)
                SingleDayChart(week: single)
            }
            
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

// MARK: - Single Day Chart

/// Vereinfachte Ansicht für einen einzelnen Tag
private struct SingleDayChart: View {
    let week: WeeklyListing

    var body: some View {
        HStack(spacing: 24) {
            // Gefunden
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.15))
                        .frame(width: 80, height: 80)

                    VStack(spacing: 4) {
                        Text("\(week.totalCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)

                        Text("Gefunden")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
                .font(.title3)

            // Beworben
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.indigo.opacity(0.15))
                        .frame(width: 80, height: 80)

                    VStack(spacing: 4) {
                        Text("\(week.matchedCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.indigo)

                        Text("Beworben")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Quote
            VStack(spacing: 8) {
                let rate = week.totalCount > 0 ? Double(week.matchedCount) / Double(week.totalCount) * 100 : 0
                
                ZStack {
                    Circle()
                        .stroke(.blue.opacity(0.25), lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: rate / 100)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text(String(format: "%.0f%%", rate))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                        
                        Text("Quote")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(height: 100)
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
        VStack(spacing: 12) {
            // Woche Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(week.fullLabel)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(week.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Statistiken in einer Reihe
            HStack(spacing: 0) {
                StatColumn(
                    value: "\(week.totalCount)",
                    label: "Gefunden",
                    color: .blue
                )
                .frame(maxWidth: .infinity)

                StatColumn(
                    value: "\(week.matchedCount)",
                    label: "Beworben",
                    color: .indigo
                )
                .frame(maxWidth: .infinity)

                StatColumn(
                    value: String(format: "%.0f%%", matchRate),
                    label: "Quote",
                    color: .blue
                )
                .frame(maxWidth: .infinity)
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
    
    /// Wochentag-Label für X-Achse (Mo, Di, Mi, ...)
    var weekdayLabel: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: startDate) else {
            return shortLabel // Fallback zu "KW X"
        }
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "de_DE")
        weekdayFormatter.dateFormat = "E" // Kurzer Wochentag: Mo, Di, Mi, etc.
        
        return weekdayFormatter.string(from: date)
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
