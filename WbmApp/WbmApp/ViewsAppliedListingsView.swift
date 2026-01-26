//
//  ViewsAppliedListingsView.swift
//  WBM Bot Controller
//
//  Created on 2026-01-26.
//

import SwiftUI
import Combine

// MARK: - ViewModel

@MainActor
final class AppliedListingsViewModel: ObservableObject {
    private let monitorService = MonitorService()

    @Published var listings: [AppliedListing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadListings() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await monitorService.getAppliedListings()
            listings = response.listings
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Main View

struct AppliedListingsView: View {
    @StateObject private var viewModel = AppliedListingsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading && viewModel.listings.isEmpty {
                        loadingView
                    } else if viewModel.listings.isEmpty {
                        emptyStateView
                    } else {
                        listingsContent
                    }

                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }
                }
                .padding()
            }
            .navigationTitle("Beworbene Wohnungen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.loadListings() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .refreshable {
                await viewModel.loadListings()
            }
            .task {
                await viewModel.loadListings()
            }
            .appBackground(.dashboard)
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        GlassCard {
            HStack(spacing: 12) {
                ProgressView()
                Text("Lade Wohnungen...")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var emptyStateView: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "house.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("Keine beworbenen Wohnungen")
                    .font(.headline)

                Text("Sobald der Bot passende Wohnungen findet und sich bewirbt, erscheinen sie hier.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 24)
        }
    }

    private var listingsContent: some View {
        VStack(spacing: 16) {
            // Header mit Anzahl
            GlassCard(tint: .green.opacity(0.15)) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.listings.count) Bewerbungen")
                            .font(.headline)
                        Text("Automatisch abgeschickt")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }

            // Listing Cards
            ForEach(viewModel.listings, id: \.listingId) { listing in
                ListingCard(listing: listing)
            }
        }
    }

    private func errorView(_ error: String) -> some View {
        GlassCard(tint: .red.opacity(0.2)) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Fehler")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Listing Card

struct ListingCard: View {
    let listing: AppliedListing
    @Environment(\.openURL) private var openURL

    var body: some View {
        GlassCard(interactive: true) {
            VStack(alignment: .leading, spacing: 12) {
                // Titel
                Text(listing.titel)
                    .font(.headline)
                    .lineLimit(2)

                Divider()

                // Details Grid
                VStack(spacing: 8) {
                    GlassInfoRow(
                        label: "Adresse",
                        value: listing.adresse,
                        icon: "mappin"
                    )

                    GlassInfoRow(
                        label: "Bezirk",
                        value: listing.area,
                        icon: "map"
                    )

                    GlassInfoRow(
                        label: "Warmmiete",
                        value: listing.formattedRent,
                        icon: "eurosign.circle"
                    )

                    GlassInfoRow(
                        label: "Zimmer",
                        value: listing.formattedRooms,
                        icon: "bed.double"
                    )

                    GlassInfoRow(
                        label: "WBS",
                        value: listing.wbsStatusText,
                        icon: listing.hasWbs ? "doc.text.fill" : "doc.text"
                    )

                    GlassInfoRow(
                        label: "Beworben am",
                        value: listing.formattedAppliedDate,
                        icon: "calendar"
                    )
                }

                Divider()

                // Link Button
                Button {
                    if let url = URL(string: listing.url) {
                        openURL(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "safari")
                        Text("Auf WBM.de ansehen")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .buttonStyle(.glass)
                .tint(.blue)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AppliedListingsView()
}
