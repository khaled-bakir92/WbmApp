//
//  WbmAppApp.swift
//  WbmApp
//
//  Created by khaled Bakir on 1/16/26.
//

import SwiftUI

@main
struct WbmAppApp: App {
    @StateObject private var launchViewModel = LaunchViewModel()
    @State private var showMainContent = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main Content
                if showMainContent {
                    ContentView()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                }

                // Launch Screen
                if !showMainContent {
                    LaunchScreenView(
                        loadingState: $launchViewModel.loadingState,
                        errorMessage: launchViewModel.errorMessage,
                        onRetry: {
                            Task {
                                await launchViewModel.loadInitialData()
                                checkAndTransition()
                            }
                        },
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showMainContent = true
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showMainContent)
            .task {
                await launchViewModel.loadInitialData()
                checkAndTransition()
            }
        }
    }

    /// Prüft ob erfolgreich geladen und wechselt zu ContentView
    private func checkAndTransition() {
        if launchViewModel.loadingState == .success {
            // Kurze Verzögerung um Erfolg zu zeigen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMainContent = true
                }
            }
        }
    }
}
