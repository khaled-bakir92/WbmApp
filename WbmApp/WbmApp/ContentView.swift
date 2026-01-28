//
//  ContentView.swift
//  WbmApp
//
//  Created by khaled Bakir on 1/16/26.
//
//  ✅ Updated to use Phase 2 Architecture (ViewModel + Services)
//

import SwiftUI
import Combine
import UIKit

// MARK: - Dashboard Screen (mit Liquid Glass Design)

struct DashboardScreen: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showBackendCheck = false
    @State private var showAppliedListings = false
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Statistik-Karten (aus MonitorStats)
                    if let _ = viewModel.monitorStats {
                        // Wöchentliches Chart für Vergleich
                        if let listingStats = viewModel.listingStats, !listingStats.weeklyData.isEmpty {
                            GlassCard {
                                WeeklyListingsChart(weeklyData: listingStats.weeklyData)
                            }
                        }
                    } else {
                        // Loading State für Statistiken
                        GlassCard {
                            HStack(spacing: 12) {
                                ProgressView()
                                Text("Statistiken werden geladen...")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                    }
                    
                    // Status Overview Card - Liquid Glass ohne Farbe
                    if let status = viewModel.botStatus {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text(status.statusIndicator)
                                        .font(.system(size: 34))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Bot Status")
                                            .font(.headline)
                                        Text(status.statusText)
                                            .font(.subheadline)
                                            .foregroundStyle(viewModel.statusColor)
                                    }
                                    
                                    Spacer()
                                    
                                    GlassStatusBadge(
                                        status: status.running ? "Aktiv" : "Gestoppt",
                                        color: status.running ? .green : .red
                                    )
                                }
                                
                                if status.running {
                                    Divider()
                                    
                                    VStack(spacing: 8) {
                                        if let uptime = status.formattedUptime {
                                            GlassInfoRow(
                                                label: "Läuft seit",
                                                value: uptime,
                                                icon: "clock"
                                            )
                                        }
                                        
                                        if let cpu = status.formattedCPU {
                                            GlassInfoRow(
                                                label: "CPU",
                                                value: cpu,
                                                icon: "cpu"
                                            )
                                        }
                                        
                                        if let memory = status.formattedMemory {
                                            GlassInfoRow(
                                                label: "RAM",
                                                value: memory,
                                                icon: "memorychip"
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        GlassCard {
                            HStack(spacing: 12) {
                                ProgressView()
                                Text("Status wird geladen...")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                    }
                    
                    // Quick Actions - Liquid Glass ohne Farbe
                    GlassSection("⚡️ Schnellzugriff") {
                        VStack(spacing: 12) {
                            GlassActionButton(
                                title: "Beworbene Wohnungen",
                                icon: "house.fill",
                                action: {
                                    showAppliedListings = true
                                },
                                tint: .green
                            )

                            GlassActionButton(
                                title: "Backend Check",
                                icon: "checkmark.shield",
                                action: {
                                    showBackendCheck = true
                                },
                                tint: .blue
                            )
                            .disabled(viewModel.isLoading)
                            
                            if viewModel.isBotRunning {
                                GlassActionButton(
                                    title: "Bot stoppen",
                                    icon: "stop.fill",
                                    action: {
                                        Task { await viewModel.stopBot() }
                                    },
                                    isDestructive: true
                                )
                                .disabled(viewModel.isLoading)
                            } else {
                                GlassActionButton(
                                    title: "Bot starten",
                                    icon: "play.fill",
                                    action: {
                                        Task { await viewModel.startBot() }
                                    },
                                    tint: .green
                                )
                                .disabled(viewModel.isLoading)
                            }
                        }
                    }
                    
                    // Error Message - Liquid Glass ohne Farbe, nur Icons in Rot
                    if let error = viewModel.errorMessage, !error.contains("cancelled") && !error.contains("canceled") {
                        GlassCard {
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
                    
                    // Loading Indicator
                    if viewModel.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Lädt...")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .glassEffect(.regular, in: .capsule)
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.loadDashboard()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .task {
                // Verhindere doppeltes Laden wenn bereits geladen wurde
                guard viewModel.botStatus == nil else { return }
                await viewModel.loadDashboard()
            }
            .sheet(isPresented: $showBackendCheck) {
                BackendCheckSheet()
            }
            .sheet(isPresented: $showAppliedListings) {
                AppliedListingsView()
                    .presentationDragIndicator(.visible)
            }
            .appBackground(.blue)
        }
    }
}

@MainActor
final class BackendCheckViewModel: ObservableObject {
    private let monitorService = MonitorService()
    private let configService = ConfigService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var stats: MonitorStats?
    @Published var logs: LogResponse?
    @Published var filter: FilterConfig?
    @Published var user: UserConfig?
    
    func loadStats() async { await run { self.stats = try await self.monitorService.getStats() } }
    func loadLogs(_ lines: Int = 50) async { await run { self.logs = try await self.monitorService.getLogs(lines: lines) } }
    func loadFilter() async { await run { self.filter = try await self.configService.getFilterConfig() } }
    func loadUser() async { await run { self.user = try await self.configService.getUserConfig() } }
    
    func saveFilter(_ new: FilterConfig) async {
        await run {
            self.filter = try await self.configService.updateFilterConfig(new)
        }
    }
    
    func saveUserData(_ new: UserData) async {
        await run {
            self.user = try await self.configService.updateUserData(new)
        }
    }
    
    private func run(_ work: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { try await work() } catch { errorMessage = error.localizedDescription }
    }
}

struct BackendCheckSheet: View {
    @StateObject private var vm = BackendCheckViewModel()
    @State private var logLines: Int = 50
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Controls
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Aktionen")
                            .font(.headline)
                        HStack(spacing: 8) {
                            Button("Stats laden") { Task { await vm.loadStats() } }
                                .buttonStyle(.borderedProminent)
                            Button("Logs (50)") { Task { await vm.loadLogs(logLines) } }
                                .buttonStyle(.bordered)
                        }
                    }
                    
                    if vm.isLoading {
                        HStack { ProgressView(); Text("Lade…") }
                            .padding(.vertical, 4)
                    }
                    
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Stats
                    if let stats = vm.stats {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stats")
                                .font(.headline)
                            HStack { Text("Health:").foregroundColor(.secondary); Text(stats.healthStatus.emoji).font(.title3) }
                            HStack { Text("Bekannte Listings:").foregroundColor(.secondary); Text("\(stats.knownListingsCount)") }
                            HStack { Text("Fehler (24h):").foregroundColor(.secondary); Text("\(stats.totalErrors24h)") }
                            HStack { Text("Letzter Check:").foregroundColor(.secondary); Text(stats.formattedLastCheck) }
                            HStack { Text("Letztes Listing:").foregroundColor(.secondary); Text(stats.formattedLastListing) }
                            HStack { Text("Bot läuft:").foregroundColor(.secondary); Text(stats.botRunning ? "Ja" : "Nein") }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.08))
                        .cornerRadius(10)
                    }
                    
                    // Logs
                    if let logs = vm.logs {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Logs")
                                .font(.headline)
                            HStack {
                                Text("Zeilen (zurückgegeben/gesamt):").foregroundColor(.secondary)
                                Text("\(logs.returnedLinesCount) / \(logs.totalLines)")
                            }
                            HStack {
                                Text("Dateigröße:").foregroundColor(.secondary)
                                Text(logs.formattedFileSize)
                            }
                            ScrollView {
                                Text(logs.combinedText)
                                    .font(.system(.footnote, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxHeight: 180)
                            .padding(8)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.08))
                        .cornerRadius(10)
                    } else if vm.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Lade Logs…")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    } else {
                        Text("Noch keine Logs geladen.")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                .padding()
            }
            .navigationTitle("Backend Check")
            .navigationBarTitleDisplayMode(.inline)
            .appBackground(.logs)
        }
    }
}

struct EditFilterForm: View {
    var initial: FilterConfig?
    var onSave: (FilterConfig) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var maxWarmmiete: Double = 0
    @State private var minZimmer: Int = 1
    @State private var wbsSelection: WBSSelection = .egal
    @State private var excludedAreas: [String] = []
    @State private var newAreaText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    enum WBSSelection: String, CaseIterable, Identifiable {
        case egal = "Egal"
        case nurMitWBS = "Nur mit WBS"
        case ohneWBS = "Ohne WBS"
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Allgemein")) {
                    TextField("Max Warmmiete (€)", value: $maxWarmmiete, format: .number)
                        .keyboardType(.decimalPad)
                    Stepper("Min Zimmer: \(minZimmer)", value: $minZimmer, in: 1...10)
                    Picker("WBS", selection: $wbsSelection) {
                        ForEach(WBSSelection.allCases) { sel in
                            Text(sel.rawValue).tag(sel)
                        }
                    }
                }
                
                Section(header: Text("Ausgeschlossene Gebiete")) {
                    // Eingabefeld mit Hinzufügen-Button
                    HStack {
                        TextField("Gebiet hinzufügen (z.B. Marzahn)", text: $newAreaText)
                            .focused($isTextFieldFocused)
                            .textInputAutocapitalization(.words)
                            .onSubmit {
                                addArea()
                            }
                        
                        Button(action: addArea) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title3)
                        }
                        .disabled(newAreaText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // Tags-Anzeige der hinzugefügten Gebiete
                    if !excludedAreas.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hinzugefügte Gebiete:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(excludedAreas, id: \.self) { area in
                                    AreaTag(area: area) {
                                        removeArea(area)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("Noch keine Gebiete ausgeschlossen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Filter bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let wbs: Bool? = {
                            switch wbsSelection {
                            case .egal: return nil
                            case .nurMitWBS: return true
                            case .ohneWBS: return false
                            }
                        }()
                        let config = FilterConfig(
                            maxWarmmiete: maxWarmmiete,
                            minZimmer: minZimmer,
                            wbsRequired: wbs,
                            excludedAreas: excludedAreas
                        )
                        onSave(config)
                        dismiss()
                    }
                    .disabled(minZimmer < 1 || maxWarmmiete <= 0)
                }
            }
            .onAppear {
                if let initial = initial {
                    maxWarmmiete = initial.maxWarmmiete
                    minZimmer = initial.minZimmer
                    wbsSelection = {
                        if let w = initial.wbsRequired { return w ? .nurMitWBS : .ohneWBS } else { return .egal }
                    }()
                    excludedAreas = initial.excludedAreas
                }
            }
            .appBackground(.config)
        }
    }
    
    private func addArea() {
        let trimmed = newAreaText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !excludedAreas.contains(trimmed) else {
            newAreaText = ""
            return
        }
        excludedAreas.append(trimmed)
        newAreaText = ""
    }
    
    private func removeArea(_ area: String) {
        excludedAreas.removeAll { $0 == area }
    }
}

// MARK: - Area Tag Component
struct AreaTag: View {
    let area: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(area)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.15))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Flow Layout für Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Neue Zeile
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct EditUserForm: View {
    var initial: UserData?
    var onSave: (UserData) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var anrede: String = ""
    @State private var vorname: String = ""
    @State private var name: String = ""
    @State private var strasse: String = ""
    @State private var plz: String = ""
    @State private var ort: String = ""
    @State private var email: String = ""
    @State private var telefon: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Persönlich")) {
                    TextField("Anrede", text: $anrede)
                    TextField("Vorname", text: $vorname)
                    TextField("Nachname", text: $name)
                }
                Section(header: Text("Kontakt")) {
                    TextField("E-Mail", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Telefon", text: $telefon)
                        .keyboardType(.phonePad)
                }
                Section(header: Text("Adresse")) {
                    TextField("Straße", text: $strasse)
                    TextField("PLZ", text: $plz)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Ort", text: $ort)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("User bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let data = UserData(
                            anrede: anrede,
                            name: name,
                            vorname: vorname,
                            strasse: strasse,
                            plz: plz,
                            ort: ort,
                            email: email,
                            telefon: telefon
                        )
                        onSave(data)
                        dismiss()
                    }
                    .disabled(vorname.isEmpty || name.isEmpty || email.isEmpty || !email.contains("@") || telefon.isEmpty)
                }
            }
            .onAppear {
                if let u = initial {
                    anrede = u.anrede
                    vorname = u.vorname
                    name = u.name
                    strasse = u.strasse
                    plz = u.plz
                    ort = u.ort
                    email = u.email
                    telefon = u.telefon
                }
            }
            .appBackground(.config)
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardScreen()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            BotScreen()
                .tabItem {
                    Label("Bot", systemImage: "play.circle.fill")
                }

            StatusScreen()
                .tabItem {
                    Label("Status", systemImage: "chart.bar.fill")
                }

            SettingsScreen()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape.fill")
                }
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

// MARK: - Bot Screen (mit Liquid Glass Design)

struct BotScreen: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card mit Liquid Glass
                    GlassCard(tint: viewModel.isBotRunning ? .green.opacity(0.2) : .red.opacity(0.15), interactive: true) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(viewModel.botStatus?.statusIndicator ?? "🤖")
                                    .font(.system(size: 40))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Bot Steuerung")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    if let status = viewModel.botStatus {
                                        Text(status.statusText)
                                            .font(.subheadline)
                                            .foregroundStyle(viewModel.statusColor)
                                    } else {
                                        Text("Status wird geladen...")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if let status = viewModel.botStatus {
                                    GlassStatusBadge(
                                        status: status.running ? "Aktiv" : "Gestoppt",
                                        color: status.running ? .green : .red
                                    )
                                }
                            }
                            
                            if let status = viewModel.botStatus {
                                Divider()
                                
                                VStack(spacing: 8) {
                                    if let pid = status.pid {
                                        GlassInfoRow(
                                            label: "Process ID",
                                            value: "\(pid)",
                                            icon: "number"
                                        )
                                    }
                                    
                                    if let uptime = status.formattedUptime {
                                        GlassInfoRow(
                                            label: "Läuft seit",
                                            value: uptime,
                                            icon: "clock"
                                        )
                                    }
                                    
                                    if let cpu = status.formattedCPU {
                                        GlassInfoRow(
                                            label: "CPU Nutzung",
                                            value: cpu,
                                            icon: "cpu"
                                        )
                                    }
                                    
                                    if let memory = status.formattedMemory {
                                        GlassInfoRow(
                                            label: "RAM Nutzung",
                                            value: memory,
                                            icon: "memorychip"
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Fehler-Anzeige
                    if let error = viewModel.errorMessage {
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
                    
                    // Control Buttons mit Liquid Glass
                    GlassSection("⚡️ Steuerung") {
                        VStack(spacing: 12) {
                            // Start Button
                            GlassActionButton(
                                title: "Bot starten",
                                icon: "play.fill",
                                action: {
                                    Task { await viewModel.startBot() }
                                },
                                tint: .green
                            )
                            .disabled(viewModel.isLoading || viewModel.isBotRunning)
                            .opacity((viewModel.isLoading || viewModel.isBotRunning) ? 0.5 : 1.0)
                            
                            // Restart Button
                            GlassActionButton(
                                title: "Bot neu starten",
                                icon: "arrow.clockwise",
                                action: {
                                    Task { await viewModel.restartBot() }
                                },
                                tint: .orange
                            )
                            .disabled(viewModel.isLoading)
                            .opacity(viewModel.isLoading ? 0.5 : 1.0)
                            
                            // Stop Button
                            GlassActionButton(
                                title: "Bot stoppen",
                                icon: "stop.fill",
                                action: {
                                    Task { await viewModel.stopBot() }
                                },
                                isDestructive: true
                            )
                            .disabled(viewModel.isLoading || !viewModel.isBotRunning)
                            .opacity((viewModel.isLoading || !viewModel.isBotRunning) ? 0.5 : 1.0)
                        }
                    }
                    
                    // Loading Indicator
                    if viewModel.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Aktion wird ausgeführt...")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        .padding()
                        .glassEffect(.regular, in: .capsule)
                    }
                }
                .padding()
            }
            .navigationTitle("Bot Steuerung")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.refreshStatus() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                await viewModel.refreshStatus()
            }
            .appBackground(.dashboard)
        }
    }
}

// MARK: - Status Screen (mit Liquid Glass Design)

struct StatusScreen: View {
    @StateObject private var statusVM = DashboardViewModel()
    @StateObject private var backendVM = BackendCheckViewModel()
    @State private var logLines: Int = 100

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Health Status Card
                    if let stats = backendVM.stats {
                        GlassCard(tint: healthColor(stats.healthStatus).opacity(0.2)) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("\(stats.healthStatus.emoji) System Health")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    GlassStatusBadge(
                                        status: healthText(stats.healthStatus),
                                        color: healthColor(stats.healthStatus)
                                    )
                                }
                                
                                HStack(spacing: 12) {
                                    if stats.botRunning {
                                        GlassStatusBadge(status: "Bot läuft", color: .green)
                                    }
                                    GlassStatusBadge(status: "CPU OK", color: .green)
                                    GlassStatusBadge(status: "RAM OK", color: .green)
                                }
                            }
                        }
                    }
                    
                    // Bot Status Card
                    if let status = statusVM.botStatus {
                        GlassCard(tint: status.running ? .green.opacity(0.15) : .gray.opacity(0.15)) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(status.statusIndicator)
                                        .font(.system(size: 32))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Bot Status")
                                            .font(.headline)
                                        Text(status.statusText)
                                            .font(.subheadline)
                                            .foregroundStyle(statusVM.statusColor)
                                    }
                                    
                                    Spacer()
                                }
                                
                                if status.running {
                                    Divider()
                                    
                                    VStack(spacing: 8) {
                                        if let pid = status.pid {
                                            GlassInfoRow(label: "Process ID", value: "\(pid)", icon: "number")
                                        }
                                        if let uptime = status.formattedUptime {
                                            GlassInfoRow(label: "Uptime", value: uptime, icon: "clock")
                                        }
                                        if let cpu = status.formattedCPU {
                                            GlassInfoRow(label: "CPU", value: cpu, icon: "cpu")
                                        }
                                        if let memory = status.formattedMemory {
                                            GlassInfoRow(label: "RAM", value: memory, icon: "memorychip")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Statistics Card
                    if let stats = backendVM.stats {
                        GlassSection("📈 Statistiken") {
                            VStack(spacing: 12) {
                                GlassInfoRow(
                                    label: "Bekannte Inserate",
                                    value: "\(stats.knownListingsCount)",
                                    icon: "doc.text"
                                )
                                
                                GlassInfoRow(
                                    label: "Fehler (24h)",
                                    value: "\(stats.totalErrors24h)",
                                    icon: "exclamationmark.triangle"
                                )
                                
                                GlassInfoRow(
                                    label: "Letzter Check",
                                    value: stats.formattedLastCheck,
                                    icon: "clock"
                                )
                                
                                GlassInfoRow(
                                    label: "Letztes Listing",
                                    value: stats.formattedLastListing,
                                    icon: "clock.badge.checkmark"
                                )
                            }
                        }
                    }
                    
                    // Logs Card
                    GlassSection("📄 Logs") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Picker("Zeilen", selection: $logLines) {
                                    Text("50").tag(50)
                                    Text("100").tag(100)
                                    Text("200").tag(200)
                                }
                                .pickerStyle(.segmented)
                                
                                Spacer()
                                
                                Button {
                                    Task { await backendVM.loadLogs(logLines) }
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .buttonStyle(.glass)
                            }

                            if let logs = backendVM.logs {
                                HStack(spacing: 8) {
                                    Text("\(logs.returnedLinesCount) / \(logs.totalLines) Zeilen")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("•")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(logs.formattedFileSize)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }

                                ScrollView {
                                    Text(logs.combinedText)
                                        .font(.system(.footnote, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxHeight: 220)
                                .padding(8)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(8)
                            } else if backendVM.isLoading {
                                HStack(spacing: 12) {
                                    ProgressView()
                                    Text("Lade Logs…")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            } else {
                                Text("Noch keine Logs geladen.")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // Error Message
                    if let error = backendVM.errorMessage {
                        GlassCard(tint: .red.opacity(0.2)) {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                
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
                .padding()
            }
            .navigationTitle("Status & Logs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await statusVM.refreshStatus()
                            await backendVM.loadLogs(logLines)
                            await backendVM.loadStats()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await statusVM.refreshStatus()
                await backendVM.loadLogs(logLines)
                await backendVM.loadStats()
            }
            .appBackground(.logs)
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

// MARK: - Settings Screen (mit Liquid Glass Design)

struct SettingsScreen: View {
    @StateObject private var vm = BackendCheckViewModel()
    @State private var showEditFilter = false
    @State private var showEditUser = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Filter Config Card
                    GlassSection("🔍 Filter Einstellungen", tint: .blue.opacity(0.15)) {
                        VStack(alignment: .leading, spacing: 12) {
                            if let filter = vm.filter {
                                GlassInfoRow(
                                    label: "Max Warmmiete",
                                    value: String(format: "%.2f €", filter.maxWarmmiete)
                                )
                                
                                GlassInfoRow(
                                    label: "Min Zimmer",
                                    value: "\(filter.minZimmer)"
                                )
                                
                                GlassInfoRow(
                                    label: "WBS Erforderlich",
                                    value: filter.wbsStatusText
                                )
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ausgeschlossene Gebiete")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    if filter.excludedAreas.isEmpty {
                                        Text("Keine")
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                            .italic()
                                    } else {
                                        FlowLayout(spacing: 8) {
                                            ForEach(filter.excludedAreas, id: \.self) { area in
                                                Text(area)
                                                    .font(.subheadline)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.blue.opacity(0.15))
                                                    .clipShape(Capsule())
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Button {
                                        Task { await vm.loadFilter() }
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Aktualisieren")
                                        }
                                    }
                                    .buttonStyle(.glass)
                                    
                                    Spacer()
                                    
                                    Button("Bearbeiten") {
                                        showEditFilter = true
                                    }
                                    .buttonStyle(.glass)
                                    .tint(.blue)
                                }
                            } else if vm.isLoading {
                                HStack(spacing: 12) {
                                    ProgressView()
                                    Text("Lädt Filter...")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            } else {
                                Text("Noch keine Filter geladen.")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // User Config Card
                    GlassSection("👤 Benutzer", tint: .purple.opacity(0.15)) {
                        VStack(alignment: .leading, spacing: 16) {
                            if let user = vm.user {
                                // Name Section
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Text(user.userData.fullName)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                Divider()
                                
                                // Adresse Section
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Adresse")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(user.userData.strasse)
                                            .font(.body)
                                        Text("\(user.userData.plz) \(user.userData.ort)")
                                            .font(.body)
                                    }
                                }
                                
                                Divider()
                                
                                // Kontakt Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Kontakt")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "envelope.fill")
                                            .foregroundStyle(.blue)
                                            .frame(width: 24)
                                        
                                        Text(user.userData.email)
                                            .font(.body)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "phone.fill")
                                            .foregroundStyle(.green)
                                            .frame(width: 24)
                                        
                                        Text(user.userData.telefon)
                                            .font(.body)
                                    }
                                }
                                
                                // Benachrichtigungen-Teil ausgeblendet auf Benutzerwunsch
                                /*
                                if let mail = user.notificationEmail {
                                    Divider()
                                    
                                    Text("📧 Benachrichtigungen")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    GlassInfoRow(
                                        label: "Sender",
                                        value: mail.sender
                                    )
                                    
                                    GlassInfoRow(
                                        label: "Empfänger",
                                        value: mail.recipient
                                    )
                                    
                                    GlassInfoRow(
                                        label: "SMTP Server",
                                        value: "\(mail.smtpServer):\(mail.smtpPort)"
                                    )
                                    
                                    GlassInfoRow(
                                        label: "Passwort",
                                        value: String(repeating: "•", count: mail.password.count)
                                    )
                                }
                                */
                                
                                Divider()
                                
                                HStack {
                                    Button {
                                        Task { await vm.loadUser() }
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Aktualisieren")
                                        }
                                    }
                                    .buttonStyle(.glass)
                                    
                                    Spacer()
                                    
                                    Button("Bearbeiten") {
                                        showEditUser = true
                                    }
                                    .buttonStyle(.glass)
                                    .tint(.purple)
                                }
                            } else if vm.isLoading {
                                HStack(spacing: 12) {
                                    ProgressView()
                                    Text("Lädt Benutzer...")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            } else {
                                Text("Noch keine User-Daten geladen.")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // App Info Card
                    GlassCard(tint: .gray.opacity(0.1)) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                
                                Text("App Information")
                                    .font(.headline)
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            GlassInfoRow(
                                label: "Version",
                                value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                            )
                            
                            GlassInfoRow(
                                label: "Build",
                                value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                            )
                        }
                    }
                    
                    // Error Message
                    if let error = vm.errorMessage {
                        GlassCard(tint: .red.opacity(0.2)) {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                
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
                    
                    // Loading Indicator
                    if vm.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Lädt...")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .glassEffect(.regular, in: .capsule)
                    }
                }
                .padding()
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await vm.loadFilter()
                            await vm.loadUser()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await vm.loadFilter()
                await vm.loadUser()
            }
            .appBackground(.config)
        }
        .sheet(isPresented: $showEditFilter) {
            EditFilterForm(initial: vm.filter) { newConfig in
                Task { await vm.saveFilter(newConfig) }
            }
        }
        .sheet(isPresented: $showEditUser) {
            EditUserForm(initial: vm.user?.userData) { newData in
                Task { await vm.saveUserData(newData) }
            }
        }
    }
}

// MARK: - Statistik Card Komponente

struct StatisticCard: View {
    let title: String
    let value: String
    var subtitle: String?
    let icon: String
    let tint: Color
    
    var body: some View {
        GlassCard(tint: tint.opacity(0.15), interactive: true) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundStyle(tint)
                    
                    Spacer()
                }
                
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private extension HealthStatus {
    var displayText: String {
        switch self {
        case .healthy: return "Gesund"
        case .warning: return "Warnung"
        case .unhealthy: return "Kritisch"
        case .stopped: return "Gestoppt"
        }
    }
}

#Preview("Dashboard") {
    DashboardScreen()
}

#Preview("ContentView") {
    ContentView()
}

