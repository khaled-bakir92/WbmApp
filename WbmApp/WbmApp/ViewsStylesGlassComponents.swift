//
//  GlassComponents.swift
//  Immobilien Bot Dashboard
//
//  Created on 17.01.2026.
//  Liquid Glass UI-Komponenten (iOS 26 Design)
//

import SwiftUI

// MARK: - Glass Card

/// Eine schöne Liquid Glass Card für Content
struct GlassCard<Content: View>: View {
    let content: Content
    var tint: Color? = nil
    var interactive: Bool = false
    
    init(
        tint: Color? = nil,
        interactive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.tint = tint
        self.interactive = interactive
    }
    
    var body: some View {
        content
            .padding()
            .glassEffect(
                glassStyle,
                in: .rect(cornerRadius: 16)
            )
    }
    
    private var glassStyle: Glass {
        var style = Glass.regular
        if let tint {
            style = style.tint(tint)
        }
        if interactive {
            style = style.interactive()
        }
        return style
    }
}

// MARK: - Glass Section

/// Eine Sektion mit Liquid Glass Background
struct GlassSection<Content: View>: View {
    let title: String
    let content: Content
    var tint: Color? = nil
    
    init(
        _ title: String,
        tint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
        self.tint = tint
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            content
        }
        .padding()
        .glassEffect(
            tint != nil ? Glass.regular.tint(tint!) : .regular,
            in: .rect(cornerRadius: 16)
        )
    }
}

// MARK: - Glass Button

/// Ein interaktiver Button mit Liquid Glass
struct GlassActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var tint: Color? = nil
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.glass)
        .tint(isDestructive ? .red : tint)
    }
}

// MARK: - Glass Status Badge

/// Ein Status-Badge mit Liquid Glass
struct GlassStatusBadge: View {
    let status: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(status)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassEffect(
            Glass.regular.tint(color.opacity(0.2)),
            in: .capsule
        )
    }
}

// MARK: - Glass Info Row

/// Eine Info-Zeile mit Label und Wert
struct GlassInfoRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    
    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
            }
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Glass Container

/// Ein Container für mehrere Liquid Glass Elemente
struct GlassContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(
        spacing: CGFloat = 40,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}

// MARK: - Preview

#Preview("Glass Components") {
    ScrollView {
        VStack(spacing: 30) {
            // Glass Card
            GlassCard(tint: .blue, interactive: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bot Status")
                        .font(.headline)
                    Text("Läuft erfolgreich")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Glass Section
            GlassSection("Statistiken", tint: .green.opacity(0.2)) {
                VStack(spacing: 8) {
                    GlassInfoRow(
                        label: "Inserate gefunden",
                        value: "42",
                        icon: "doc.text"
                    )
                    GlassInfoRow(
                        label: "E-Mails gesendet",
                        value: "12",
                        icon: "envelope"
                    )
                }
            }
            
            // Glass Buttons Container
            GlassContainer(spacing: 20) {
                VStack(spacing: 12) {
                    GlassActionButton(
                        title: "Bot starten",
                        icon: "play.fill",
                        action: {},
                        tint: .green
                    )
                    
                    GlassActionButton(
                        title: "Bot stoppen",
                        icon: "stop.fill",
                        action: {},
                        isDestructive: true
                    )
                }
            }
            
            // Status Badges
            HStack {
                GlassStatusBadge(status: "Aktiv", color: .green)
                GlassStatusBadge(status: "Warten", color: .orange)
                GlassStatusBadge(status: "Fehler", color: .red)
            }
        }
        .padding()
    }
    .appBackground(.dashboard)
}

#Preview("Interactive Demo") {
    GlassContainer(spacing: 30) {
        VStack(spacing: 20) {
            Text("Interaktive Elemente")
                .font(.title)
                .fontWeight(.bold)
                .glassEffect(.regular, in: .capsule)
                .padding()
            
            HStack(spacing: 20) {
                Image(systemName: "star.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.yellow)
                    .padding()
                    .glassEffect(.regular.interactive(), in: .circle)
                
                Image(systemName: "heart.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                    .padding()
                    .glassEffect(.regular.interactive(), in: .circle)
                
                Image(systemName: "bell.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                    .padding()
                    .glassEffect(.regular.interactive(), in: .circle)
            }
        }
        .padding()
    }
    .appBackground(.stats)
}
