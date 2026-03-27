import SwiftUI

struct SetupView: View {
    let storage: StorageService
    let onConnected: () -> Void

    @State private var instanceURL: String = ""
    @State private var apiKey: String = ""
    @State private var showAPIKey = false
    @State private var isTesting = false
    @State private var connectionSuccess = false
    @State private var errorMessage: String?
    @State private var bounceValue = 0
    @FocusState private var focusedField: Field?

    private enum Field { case url, apiKey }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                            .symbolEffect(.bounce, value: bounceValue)

                        Text("Connect to N8N")
                            .font(.title.bold())
                            .foregroundStyle(.white)

                        Text("Enter your instance URL and API key")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instance URL")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)

                            TextField("https://your-n8n.app.n8n.cloud", text: $instanceURL)
                                .textFieldStyle(.plain)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.URL)
                                .focused($focusedField, equals: .url)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .apiKey }
                                .padding(14)
                                .background(Color.white.opacity(0.07))
                                .clipShape(.rect(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("API Key")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)

                            HStack(spacing: 12) {
                                Group {
                                    if showAPIKey {
                                        TextField("Your API key", text: $apiKey)
                                    } else {
                                        SecureField("Your API key", text: $apiKey)
                                    }
                                }
                                .textFieldStyle(.plain)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .apiKey)
                                .submitLabel(.done)

                                Button {
                                    showAPIKey.toggle()
                                } label: {
                                    Image(systemName: showAPIKey ? "eye.slash.fill" : "eye.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 14) {
                        if let errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(.horizontal, 24)
                        }

                        if connectionSuccess {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Connected!")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.green)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }

                        Button {
                            Task { await testConnection() }
                        } label: {
                            HStack(spacing: 8) {
                                if isTesting {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text(isTesting ? "Testing..." : "Test Connection")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(connectionSuccess ? .green : .blue)
                        .disabled(instanceURL.isEmpty || apiKey.isEmpty || isTesting)
                        .padding(.horizontal, 24)

                        if connectionSuccess {
                            Button {
                                storage.save(url: instanceURL, apiKey: apiKey)
                                onConnected()
                            } label: {
                                Text("Save and Continue")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .animation(.snappy, value: connectionSuccess)
                    .animation(.snappy, value: errorMessage)
                }
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if !storage.instanceURL.isEmpty {
                instanceURL = storage.instanceURL
                apiKey = storage.apiKey
            }
        }
    }

    private func testConnection() async {
        focusedField = nil
        isTesting = true
        connectionSuccess = false
        errorMessage = nil
        defer { isTesting = false }

        let service = N8NAPIService(baseURL: instanceURL, apiKey: apiKey)
        do {
            let success = try await service.testConnection()
            if success {
                connectionSuccess = true
                bounceValue += 1
            } else {
                errorMessage = "Invalid credentials or URL — try again"
            }
        } catch {
            errorMessage = "Invalid credentials or URL — try again"
        }
    }
}
