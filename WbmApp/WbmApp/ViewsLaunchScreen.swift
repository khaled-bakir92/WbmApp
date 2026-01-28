//
//  LaunchScreen.swift
//  WbmApp
//
//  Created on 2026-01-28.
//

import SwiftUI

/// Launch Screen der beim App-Start angezeigt wird
struct LaunchScreenView: View {

    // MARK: - Properties

    @Binding var loadingState: LaunchLoadingState
    var errorMessage: String?
    var onRetry: () -> Void
    var onContinue: () -> Void

    // MARK: - Animation States

    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var showContent: Bool = false

    // MARK: - App Icon

    private var appIconImage: Image? {
        if let iconsDict = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = iconsDict["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let iconName = iconFiles.last,
           let uiImage = UIImage(named: iconName) {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Hintergrund
            BackgroundVariant.blue.gradient
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                if let appIcon = appIconImage {
                    appIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                } else {
                    // Fallback falls kein Icon gefunden
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                // App Name
                Text("WBM Bot")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // Loading / Error Content
                Group {
                    switch loadingState {
                    case .idle, .loading, .success:
                        loadingContent
                    case .failed:
                        errorContent
                    }
                }
                .opacity(showContent ? 1 : 0)

                Spacer()
                    .frame(height: 60)
            }
            .padding()
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Subviews

    private var loadingContent: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)

            Text("Verbindung wird hergestellt...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var errorContent: some View {
        VStack(spacing: 20) {
            GlassCard(tint: .red.opacity(0.1)) {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.red)

                    Text("Verbindung fehlgeschlagen")
                        .font(.headline)

                    if let message = errorMessage {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 8)
            }

            VStack(spacing: 12) {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Erneut versuchen")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.glass)
                .tint(.blue)

                Button(action: onContinue) {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("Trotzdem fortfahren")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.glass)
                .tint(.gray)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Logo einblenden
        withAnimation(.easeOut(duration: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Content einblenden mit Verzögerung
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showContent = true
        }

        // Pulsierender Effekt während des Ladens
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
            .delay(0.6)
        ) {
            logoScale = 1.05
        }
    }
}

// MARK: - Preview

#Preview("Loading") {
    LaunchScreenView(
        loadingState: .constant(.loading),
        errorMessage: nil,
        onRetry: {},
        onContinue: {}
    )
}

#Preview("Error") {
    LaunchScreenView(
        loadingState: .constant(.failed),
        errorMessage: "Server nicht erreichbar",
        onRetry: {},
        onContinue: {}
    )
}
