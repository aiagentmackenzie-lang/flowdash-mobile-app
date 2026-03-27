import Foundation

nonisolated struct Execution: Codable, Identifiable, Sendable, Hashable {
    let id: String
    let finished: Bool?
    let mode: String?
    let status: String?
    let startedAt: String?
    let stoppedAt: String?
    let workflowId: String?

    nonisolated struct WorkflowData: Codable, Sendable, Hashable {
        let id: String?
        let name: String?
    }

    let workflowData: WorkflowData?

    var statusType: ExecutionStatus {
        switch status?.lowercased() {
        case "success": return .success
        case "error", "failed", "crashed": return .failed
        case "running", "new": return .running
        case "waiting": return .waiting
        default: return .unknown
        }
    }

    var startDate: Date? {
        guard let startedAt else { return nil }
        return ISO8601DateFormatter().date(from: startedAt)
            ?? DateFormatter.n8nFormatter.date(from: startedAt)
    }

    var endDate: Date? {
        guard let stoppedAt else { return nil }
        return ISO8601DateFormatter().date(from: stoppedAt)
            ?? DateFormatter.n8nFormatter.date(from: stoppedAt)
    }

    var durationSeconds: Double? {
        guard let start = startDate, let end = endDate else { return nil }
        return end.timeIntervalSince(start)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Execution, rhs: Execution) -> Bool {
        lhs.id == rhs.id
    }
}

nonisolated enum ExecutionStatus: String, Sendable {
    case success, failed, running, waiting, unknown

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .running: return "hourglass"
        case .waiting: return "clock.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    var label: String {
        switch self {
        case .success: return "Success"
        case .failed: return "Failed"
        case .running: return "Running"
        case .waiting: return "Waiting"
        case .unknown: return "Unknown"
        }
    }
}

nonisolated struct ExecutionListResponse: Codable, Sendable {
    let data: [Execution]
    let nextCursor: String?
}

nonisolated struct ExecutionDetailResponse: Codable, Sendable {
    let id: String
    let finished: Bool?
    let mode: String?
    let status: String?
    let startedAt: String?
    let stoppedAt: String?
    let workflowId: String?
    let data: ExecutionData?

    nonisolated struct ExecutionData: Codable, Sendable {
        let resultData: ResultData?
    }

    nonisolated struct ResultData: Codable, Sendable {
        let error: ExecutionError?
    }

    nonisolated struct ExecutionError: Codable, Sendable {
        let message: String?
    }
}

extension DateFormatter {
    nonisolated(unsafe) static let n8nFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
