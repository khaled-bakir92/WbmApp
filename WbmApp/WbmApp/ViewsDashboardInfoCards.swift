//
//  DashboardInfoCards.swift
//  WBM Bot Controller
//
//  Created on 2026-01-17.
//  Read-Only Info Cards für Dashboard (Liquid Glass Design)
//

import SwiftUI

// MARK: - User Info Card

/// Schöne Read-Only Card für Benutzerdaten
struct UserInfoCard: View {
    let userData: UserData
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GlassSection("👤 Benutzerdaten", tint: .purple.opacity(0.1)) {
            VStack(alignment: .leading, spacing: 16) {
                // Name und Anrede
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.purple)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userData.fullName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("Hauptnutzer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Kontaktinformationen
                VStack(spacing: 14) {
                    InfoRow(
                        icon: "envelope.fill",
                        iconColor: .blue,
                        label: "E-Mail",
                        value: userData.email
                    )
                    
                    InfoRow(
                        icon: "phone.fill",
                        iconColor: .green,
                        label: "Telefon",
                        value: userData.telefon
                    )
                    
                    InfoRow(
                        icon: "mappin.circle.fill",
                        iconColor: .red,
                        label: "Adresse",
                        value: userData.fullAddress,
                        isMultiline: true
                    )
                }
            }
        }
    }
}

// MARK: - Filter Info Card

/// Schöne Read-Only Card für Filter-Einstellungen
struct FilterInfoCard: View {
    let filterConfig: FilterConfig
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GlassSection("🔍 Suchfilter", tint: .blue.opacity(0.1)) {
            VStack(alignment: .leading, spacing: 16) {
                // Filter-Header mit Icon
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Aktive Filterkriterien")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("Automatische Suche")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Filter-Kriterien
                VStack(spacing: 14) {
                    InfoRow(
                        icon: "eurosign.circle.fill",
                        iconColor: .green,
                        label: "Max. Warmmiete",
                        value: String(format: "%.2f €", filterConfig.maxWarmmiete)
                    )
                    
                    InfoRow(
                        icon: "door.left.hand.open",
                        iconColor: .orange,
                        label: "Min. Zimmer",
                        value: "\(filterConfig.minZimmer) Zimmer"
                    )
                    
                    InfoRow(
                        icon: "doc.text.fill",
                        iconColor: .purple,
                        label: "WBS-Status",
                        value: filterConfig.wbsStatusText
                    )
                }
                
                // Ausgeschlossene Gebiete
                if !filterConfig.excludedAreas.isEmpty {
                    Divider()
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.slash.fill")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                            
                            Text("Ausgeschlossene Gebiete")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(filterConfig.excludedAreas, id: \.self) { area in
                                ExcludedAreaBadge(area: area)
                            }
                        }
                    }
                } else {
                    Divider()
                        .padding(.vertical, 8)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                        
                        Text("Alle Gebiete werden durchsucht")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }
            }
        }
    }
}

// MARK: - Info Row Component

/// Wiederverwendbare Info-Zeile mit Icon und Wert
struct InfoRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    var isMultiline: Bool = false
    
    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 12) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }
            
            // Label und Wert
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if isMultiline {
                    Text(value)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                } else {
                    Text(value)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Excluded Area Badge

/// Badge für ausgeschlossene Gebiete
struct ExcludedAreaBadge: View {
    let area: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "location.slash")
                .font(.caption2)
                .foregroundStyle(.red)
            
            Text(area)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.red.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Stats Summary Card

/// Kompakte Statistik-Übersicht für Dashboard
struct StatsSummaryCard: View {
    let stats: MonitorStats?
    
    var body: some View {
        if let stats = stats {
            GlassCard(tint: healthTint(stats.healthStatus), interactive: true) {
                VStack(spacing: 16) {
                    // Health Status Header
                    HStack {
                        HStack(spacing: 8) {
                            Text(stats.healthStatus.emoji)
                                .font(.title)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("System Health")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text(healthText(stats.healthStatus))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(healthColor(stats.healthStatus))
                            }
                        }
                        
                        Spacer()
                        
                        GlassStatusBadge(
                            status: stats.botRunning ? "Bot Aktiv" : "Bot Gestoppt",
                            color: stats.botRunning ? .green : .gray
                        )
                    }
                    
                    Divider()
                    
                    // Quick Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        QuickStatItem(
                            icon: "doc.text.fill",
                            color: .blue,
                            value: "\(stats.knownListingsCount)",
                            label: "Inserate"
                        )
                        
                        QuickStatItem(
                            icon: "exclamationmark.triangle.fill",
                            color: .orange,
                            value: "\(stats.totalErrors24h)",
                            label: "Fehler (24h)"
                        )
                        
                        QuickStatItem(
                            icon: "clock.fill",
                            color: .purple,
                            value: stats.formattedLastCheck,
                            label: "Letzter Check"
                        )
                        
                        QuickStatItem(
                            icon: "checkmark.circle.fill",
                            color: .green,
                            value: stats.formattedLastListing,
                            label: "Letztes Listing"
                        )
                    }
                }
            }
        }
    }
    
    private func healthTint(_ health: HealthStatus) -> Color {
        switch health {
        case .healthy: return .green.opacity(0.15)
        case .warning: return .orange.opacity(0.15)
        case .unhealthy: return .red.opacity(0.15)
        case .stopped: return .gray.opacity(0.15)
        }
    }
    
    private func healthColor(_ health: HealthStatus) -> Color {
        switch health {
        case .healthy: return .green
        case .warning: return .orange
        case .unhealthy: return .red
        case .stopped: return .gray
        }
    }
    
    private func healthText(_ health: HealthStatus) -> String {
        switch health {
        case .healthy: return "Gesund"
        case .warning: return "Warnung"
        case .unhealthy: return "Kritisch"
        case .stopped: return "Gestoppt"
        }
    }
}

// MARK: - Quick Stat Item

/// Kleines Stat-Element für Grid
struct QuickStatItem: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Previews

#Preview("User Info Card") {
    ScrollView {
        VStack(spacing: 20) {
            UserInfoCard(userData: UserData(
                anrede: "Herr",
                name: "Mustermann",
                vorname: "Max",
                strasse: "Musterstraße 123",
                plz: "10115",
                ort: "Berlin",
                email: "max@example.com",
                telefon: "+49 30 12345678"
            ))
        }
        .padding()
    }
    .appBackground(.dashboard)
}

#Preview("Filter Info Card") {
    ScrollView {
        VStack(spacing: 20) {
            FilterInfoCard(filterConfig: FilterConfig(
                maxWarmmiete: 850.00,
                minZimmer: 2,
                wbsRequired: true,
                excludedAreas: ["Marzahn", "Hellersdorf", "Lichtenberg"]
            ))
            
            FilterInfoCard(filterConfig: FilterConfig(
                maxWarmmiete: 1200.00,
                minZimmer: 3,
                wbsRequired: nil,
                excludedAreas: []
            ))
        }
        .padding()
    }
    .appBackground(.dashboard)
}

#Preview("All Dashboard Cards") {
    ScrollView {
        VStack(spacing: 24) {
            UserInfoCard(userData: UserData(
                anrede: "Frau",
                name: "Schmidt",
                vorname: "Anna",
                strasse: "Alexanderplatz 1",
                plz: "10178",
                ort: "Berlin",
                email: "anna.schmidt@email.de",
                telefon: "+49 176 98765432"
            ))
            
            FilterInfoCard(filterConfig: FilterConfig(
                maxWarmmiete: 950.00,
                minZimmer: 2,
                wbsRequired: false,
                excludedAreas: ["Marzahn", "Hellersdorf"]
            ))
        }
        .padding()
    }
    .appBackground(.dashboard)
}
