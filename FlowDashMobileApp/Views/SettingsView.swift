import SwiftUI

struct SettingsView: View {
    let storage: StorageService
    let onDisconnect: () -> Void
    let onEditConnection: () -> Void
    @State private var isTesting = false
    @State private var testResult: Bool?
    @State private var showDisconnectAlert = false
    @AppStorage("prefersDarkMode") private var prefersDarkMode = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        connectionSection
                        actionsSection
                        appearanceSection
                        dangerSection
                        appInfoSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Disconnect?", isPresented: $showDisconnectAlert) {
                Button("Disconnect", role: .destructive) {
                    onDisconnect()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear your stored credentials and return to the welcome screen.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Connection", systemImage: "server.rack")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                settingsRow(label: "Instance URL", value: truncatedURL)
                Divider().background(Color.white.opacity(0.1))
                settingsRow(label: "API Key", value: maskedKey)
            }
            .background(Color.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await testConnection() }
            } label: {
                HStack(spacing: 8) {
                    if isTesting {
                        ProgressView().tint(.white)
                    } else if let result = testResult {
                        Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(result ? .green : .red)
                    }
                    Text(isTesting ? "Testing..." : "Test Connection")
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(.blue)

            Button {
                onEditConnection()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                    Text("Edit Connection")
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Appearance", systemImage: "paintbrush")
                .font(.headline)
                .foregroundStyle(.white)

            HStack {
                Label("Dark Mode", systemImage: "moon.fill")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
                Toggle("", isOn: $prefersDarkMode)
                    .labelsHidden()
                    .tint(.blue)
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var dangerSection: some View {
        Button {
            showDisconnectAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle")
                Text("Disconnect")
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }

    private var appInfoSection: some View {
        VStack(spacing: 4) {
            Text("FlowDash")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text("Version 1.0.0")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    private func settingsRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.monospaced())
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var truncatedURL: String {
        let url = storage.instanceURL
        if url.count > 30 {
            return String(url.prefix(30)) + "..."
        }
        return url
    }

    private var maskedKey: String {
        let key = storage.apiKey
        guard key.count > 8 else { return String(repeating: "•", count: key.count) }
        return String(key.prefix(4)) + String(repeating: "•", count: 8) + String(key.suffix(4))
    }

    private func testConnection() async {
        isTesting = true
        testResult = nil
        defer { isTesting = false }
        let service = N8NAPIService(baseURL: storage.instanceURL, apiKey: storage.apiKey)
        do {
            testResult = try await service.testConnection()
        } catch {
            testResult = false
        }
    }
}
