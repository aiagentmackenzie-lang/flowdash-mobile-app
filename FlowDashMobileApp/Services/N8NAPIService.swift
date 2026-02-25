import Foundation

nonisolated struct N8NAPIService: Sendable {
    let baseURL: String
    let apiKey: String

    private var cleanBaseURL: String {
        var url = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if url.hasSuffix("/") { url.removeLast() }
        return url
    }

    private func makeRequest(path: String, method: String = "GET", body: Data? = nil) -> URLRequest {
        let urlString = "\(cleanBaseURL)/api/v1\(path)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "X-N8N-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        if let body { request.httpBody = body }
        return request
    }

    func testConnection() async throws -> Bool {
        let request = makeRequest(path: "/workflows?limit=1")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { return false }
        return http.statusCode == 200
    }

    func fetchWorkflows() async throws -> [Workflow] {
        let request = makeRequest(path: "/workflows?limit=100")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        let decoded = try JSONDecoder().decode(WorkflowListResponse.self, from: data)
        return decoded.data
    }

    func activateWorkflow(id: String) async throws {
        let request = makeRequest(path: "/workflows/\(id)/activate", method: "POST")
        let (_, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
    }

    func deactivateWorkflow(id: String) async throws {
        let request = makeRequest(path: "/workflows/\(id)/deactivate", method: "POST")
        let (_, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
    }

    func triggerWorkflow(id: String) async throws {
        let body = try JSONSerialization.data(withJSONObject: [:] as [String: Any])
        let request = makeRequest(path: "/workflows/\(id)/run", method: "POST", body: body)
        let (_, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
    }

    func fetchExecutions(workflowId: String? = nil, status: String? = nil, limit: Int = 20, cursor: String? = nil) async throws -> ExecutionListResponse {
        var params = ["limit=\(limit)"]
        if let workflowId { params.append("workflowId=\(workflowId)") }
        if let status { params.append("status=\(status)") }
        if let cursor { params.append("cursor=\(cursor)") }
        let query = params.joined(separator: "&")
        let request = makeRequest(path: "/executions?\(query)")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try JSONDecoder().decode(ExecutionListResponse.self, from: data)
    }

    func fetchExecution(id: String) async throws -> ExecutionDetailResponse {
        let request = makeRequest(path: "/executions/\(id)?includeData=true")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try JSONDecoder().decode(ExecutionDetailResponse.self, from: data)
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw N8NError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw N8NError.httpError(http.statusCode)
        }
    }
}

nonisolated enum N8NError: Error, LocalizedError, Sendable {
    case invalidResponse
    case httpError(Int)
    case connectionFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response"
        case .httpError(let code): return "Server error (HTTP \(code))"
        case .connectionFailed: return "Could not connect to server"
        }
    }
}
