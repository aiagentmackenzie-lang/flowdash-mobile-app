import SwiftUI

struct ExecutionDetailView: View {
    let executionId: String
    let apiService: N8NAPIService
    @State private var detail: ExecutionDetailResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(.blue)
                    .scaleEffect(1.2)
            } else if let detail {
                ScrollView {
                    VStack(spacing: 20) {
                        detailHeader(detail)
                        timingSection(detail)

                        if let errMsg = detail.data?.resultData?.error?.message {
                            errorSection(errMsg)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            } else if let errorMessage {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            }
        }
        .navigationTitle("Execution #\(executionId)")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadDetail() }
        .preferredColorScheme(.dark)
    }

    private func detailHeader(_ detail: ExecutionDetailResponse) -> some View {
        let statusType = executionStatus(detail.status)
        return VStack(spacing: 12) {
            Image(systemName: statusType.icon)
                .font(.system(size: 44))
                .foregroundStyle(statusColor(statusType))

            StatusBadge(text: statusType.label.uppercased(), color: statusColor(statusType))

            if let mode = detail.mode {
                Text("Mode: \(mode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func timingSection(_ detail: ExecutionDetailResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timing")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                timingRow(label: "Started", value: formatDate(detail.startedAt))
                Divider().background(Color.white.opacity(0.1))
                timingRow(label: "Finished", value: formatDate(detail.stoppedAt))
                Divider().background(Color.white.opacity(0.1))
                timingRow(label: "Duration", value: computeDuration(start: detail.startedAt, end: detail.stoppedAt))
            }
            .background(Color.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private func timingRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.monospaced())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func errorSection(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("Error")
                    .font(.headline)
                    .foregroundStyle(.red)
            }

            Text(message)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.red.opacity(0.9))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func loadDetail() async {
        isLoading = true
        defer { isLoading = false }
        do {
            detail = try await apiService.fetchExecution(id: executionId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func executionStatus(_ status: String?) -> ExecutionStatus {
        switch status?.lowercased() {
        case "success": return .success
        case "error", "failed", "crashed": return .failed
        case "running", "new": return .running
        case "waiting": return .waiting
        default: return .unknown
        }
    }

    private func statusColor(_ status: ExecutionStatus) -> Color {
        switch status {
        case .success: return .green
        case .failed: return .red
        case .running: return .orange
        case .waiting: return .yellow
        case .unknown: return .gray
        }
    }

    private func formatDate(_ dateStr: String?) -> String {
        guard let dateStr else { return "—" }
        let date = ISO8601DateFormatter().date(from: dateStr)
            ?? DateFormatter.n8nFormatter.date(from: dateStr)
        guard let date else { return dateStr }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm:ss a"
        return formatter.string(from: date)
    }

    private func computeDuration(start: String?, end: String?) -> String {
        guard let start, let end else { return "—" }
        let startDate = ISO8601DateFormatter().date(from: start)
            ?? DateFormatter.n8nFormatter.date(from: start)
        let endDate = ISO8601DateFormatter().date(from: end)
            ?? DateFormatter.n8nFormatter.date(from: end)
        guard let s = startDate, let e = endDate else { return "—" }
        return formatDuration(e.timeIntervalSince(s))
    }
}
