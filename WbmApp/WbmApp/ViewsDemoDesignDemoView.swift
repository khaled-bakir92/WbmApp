//
//  DesignDemoView.swift
//  Immobilien Bot Dashboard
//
//  Created on 17.01.2026.
//  Demo der neuen Liquid Glass + Heller Hintergrund Designs
//

import SwiftUI

struct DesignDemoView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Dashboard Demo
            DashboardDemoView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: Config Demo
            ConfigDemoView()
                .tabItem {
                    Label("Config", systemImage: "gearshape.fill")
                }
                .tag(1)
            
            // Tab 3: Stats Demo
            StatsDemoView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            // Tab 4: Components Demo
            ComponentsDemoView()
                .tabItem {
                    Label("Components", systemImage: "square.grid.2x2.fill")
                }
                .tag(3)
        }
    }
}

// MARK: - Dashboard Demo

struct DashboardDemoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    GlassCard(tint: .green.opacity(0.2), interactive: true) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("🤖 Bot Status")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                GlassStatusBadge(status: "Aktiv", color: .green)
                            }
                            
                            Divider()
                            
                            VStack(spacing: 8) {
                                GlassInfoRow(
                                    label: "Läuft seit",
                                    value: "2h 34min",
                                    icon: "clock"
                                )
                                GlassInfoRow(
                                    label: "Nächster Check",
                                    value: "in 3min",
                                    icon: "calendar"
                                )
                                GlassInfoRow(
                                    label: "Status",
                                    value: "Alles OK ✅",
                                    icon: "checkmark.circle"
                                )
                            }
                        }
                    }
                    
                    // Control Buttons
                    GlassSection("Steuerung") {
                        VStack(spacing: 12) {
                            GlassActionButton(
                                title: "Bot starten",
                                icon: "play.fill",
                                action: {},
                                tint: .green
                            )
                            
                            GlassActionButton(
                                title: "Bot neu starten",
                                icon: "arrow.clockwise",
                                action: {},
                                tint: .orange
                            )
                            
                            GlassActionButton(
                                title: "Bot stoppen",
                                icon: "stop.fill",
                                action: {},
                                isDestructive: true
                            )
                        }
                    }
                    
                    // Quick Stats
                    GlassCard(tint: .blue.opacity(0.15)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📊 Heute")
                                .font(.headline)
                            
                            HStack(spacing: 20) {
                                StatItem(
                                    value: "42",
                                    label: "Inserate",
                                    icon: "doc.text"
                                )
                                
                                Divider()
                                
                                StatItem(
                                    value: "12",
                                    label: "E-Mails",
                                    icon: "envelope"
                                )
                                
                                Divider()
                                
                                StatItem(
                                    value: "3",
                                    label: "Fehler",
                                    icon: "exclamationmark.triangle"
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .appBackground(.dashboard)
        }
    }
}

// MARK: - Config Demo

struct ConfigDemoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Filter Section
                    GlassSection("🔍 Filter", tint: .blue.opacity(0.15)) {
                        VStack(alignment: .leading, spacing: 12) {
                            ConfigRow(label: "PLZ", value: "10115")
                            ConfigRow(label: "Umkreis", value: "5 km")
                            ConfigRow(label: "Max. Miete", value: "1.500 €")
                            ConfigRow(label: "Min. Zimmer", value: "2")
                        }
                    }
                    
                    // User Section
                    GlassSection("👤 Benutzer", tint: .purple.opacity(0.15)) {
                        VStack(alignment: .leading, spacing: 12) {
                            ConfigRow(label: "Name", value: "Max Mustermann")
                            ConfigRow(label: "E-Mail", value: "max@example.com")
                            ConfigRow(label: "Telefon", value: "+49 123 456789")
                        }
                    }
                    
                    // Actions
                    GlassContainer(spacing: 20) {
                        VStack(spacing: 12) {
                            GlassActionButton(
                                title: "Speichern",
                                icon: "checkmark.circle.fill",
                                action: {},
                                tint: .green
                            )
                            
                            Button("Abbrechen") {}
                                .buttonStyle(.glass)
                                .tint(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Konfiguration")
            .appBackground(.config)
        }
    }
}

// MARK: - Stats Demo

struct StatsDemoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Health Status
                    GlassCard(tint: .green.opacity(0.2)) {
                        VStack(spacing: 12) {
                            Text("💚 System Health")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                GlassStatusBadge(status: "CPU OK", color: .green)
                                GlassStatusBadge(status: "RAM OK", color: .green)
                                GlassStatusBadge(status: "Disk OK", color: .green)
                            }
                        }
                    }
                    
                    // Statistics
                    GlassSection("📈 Statistiken") {
                        VStack(spacing: 12) {
                            StatsBar(
                                label: "Inserate gesamt",
                                value: 1234,
                                color: .blue
                            )
                            StatsBar(
                                label: "E-Mails gesendet",
                                value: 456,
                                color: .green
                            )
                            StatsBar(
                                label: "Screenshots",
                                value: 789,
                                color: .purple
                            )
                        }
                    }
                    
                    // Recent Activity
                    GlassCard(tint: .orange.opacity(0.15)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🕐 Letzte Aktivität")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ActivityRow(
                                    time: "vor 2min",
                                    text: "5 neue Inserate gefunden"
                                )
                                ActivityRow(
                                    time: "vor 15min",
                                    text: "E-Mail an max@example.com"
                                )
                                ActivityRow(
                                    time: "vor 1h",
                                    text: "Bot neu gestartet"
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Statistiken")
            .appBackground(.stats)
        }
    }
}

// MARK: - Components Demo

struct ComponentsDemoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Interactive Glass Elements
                    Text("🎨 Interaktive Elemente")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    GlassContainer(spacing: 30) {
                        HStack(spacing: 20) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.yellow)
                                .padding()
                                .glassEffect(.regular.interactive(), in: .circle)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.red)
                                .padding()
                                .glassEffect(.regular.interactive(), in: .circle)
                            
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.blue)
                                .padding()
                                .glassEffect(.regular.interactive(), in: .circle)
                        }
                    }
                    
                    Divider()
                    
                    // Button Styles
                    Text("🔘 Button Styles")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        Button("Standard Glass Button") {}
                            .buttonStyle(.glass)
                        
                        Button("Prominent Glass Button") {}
                            .buttonStyle(.glassProminent)
                        
                        GlassActionButton(
                            title: "Custom Glass Button",
                            icon: "sparkles",
                            action: {},
                            tint: .purple
                        )
                    }
                    
                    Divider()
                    
                    // Status Badges
                    Text("🏷️ Status Badges")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            GlassStatusBadge(status: "Erfolgreich", color: .green)
                            GlassStatusBadge(status: "Warten", color: .orange)
                        }
                        HStack {
                            GlassStatusBadge(status: "Fehler", color: .red)
                            GlassStatusBadge(status: "Info", color: .blue)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Komponenten")
            .appBackground(.default)
        }
    }
}

// MARK: - Helper Views

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ConfigRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct StatsBar: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * 0.7)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ActivityRow: View {
    let time: String
    let text: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(.blue)
                .frame(width: 6, height: 6)
            
            Text(time)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Preview

#Preview("Design Demo") {
    DesignDemoView()
}

#Preview("Dashboard") {
    DashboardDemoView()
}

#Preview("Config") {
    ConfigDemoView()
}

#Preview("Stats") {
    StatsDemoView()
}

#Preview("Components") {
    ComponentsDemoView()
}
