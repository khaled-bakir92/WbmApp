//
//  BackgroundStyles.swift
//  Immobilien Bot Dashboard
//
//  Created on 17.01.2026.
//  Schöne helle Hintergründe für alle Screens
//

import SwiftUI

// MARK: - Background Styles

/// Wiederverwendbare Hintergrund-Styles für die App
struct AppBackgroundStyle: ViewModifier {
    var variant: BackgroundVariant = .default
    
    func body(content: Content) -> some View {
        content
            .background {
                variant.gradient
                    .ignoresSafeArea()
            }
    }
}

// MARK: - Background Variants

enum BackgroundVariant {
    case `default`      // Heller Blau-Gradient
    case blue           // Kräftiger Blau-Gradient
    case dashboard      // Warmer Gradient für Dashboard
    case config         // Grüner Gradient für Config
    case logs           // Neutraler Gradient für Logs
    case stats          // Lila Gradient für Statistiken
    
    var gradient: LinearGradient {
        switch self {
        case .default:
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),    // Sehr helles Blau
                    Color(red: 0.98, green: 0.99, blue: 1.0)     // Fast Weiß
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .blue:
            return LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.93, blue: 0.99),    // Helles Sky-Blau
                    Color(red: 0.78, green: 0.89, blue: 0.98),    // Sanftes Blau
                    Color(red: 0.82, green: 0.91, blue: 0.99)     // Luftiges Blau
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .dashboard:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.95),    // Warmes Weiß
                    Color(red: 0.98, green: 0.95, blue: 1.0)     // Leichtes Violett
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .config:
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 1.0, blue: 0.97),    // Minzgrün
                    Color(red: 0.97, green: 0.99, blue: 0.98)    // Helles Grün-Weiß
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .logs:
            return LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.97, blue: 0.97),   // Neutral Hell
                    Color(red: 0.99, green: 0.99, blue: 0.99)    // Fast Weiß
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case .stats:
            return LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.95, blue: 1.0),    // Helles Lila
                    Color(red: 0.99, green: 0.97, blue: 1.0)     // Sehr helles Lila
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - View Extension

extension View {
    /// Fügt einen schönen hellen Hintergrund hinzu
    func appBackground(_ variant: BackgroundVariant = .default) -> some View {
        self.modifier(AppBackgroundStyle(variant: variant))
    }
}

// MARK: - Preview

#Preview("Alle Hintergründe") {
    ScrollView {
        VStack(spacing: 20) {
            ForEach([
                ("Default", BackgroundVariant.default),
                ("Blue", BackgroundVariant.blue),
                ("Dashboard", BackgroundVariant.dashboard),
                ("Config", BackgroundVariant.config),
                ("Logs", BackgroundVariant.logs),
                ("Stats", BackgroundVariant.stats)
            ], id: \.0) { name, variant in
                VStack {
                    Text(name)
                        .font(.headline)
                    
                    Rectangle()
                        .fill(variant.gradient)
                        .frame(height: 100)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

