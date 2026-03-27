import Foundation

nonisolated struct Workflow: Codable, Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let active: Bool
    let createdAt: String?
    let updatedAt: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Workflow, rhs: Workflow) -> Bool {
        lhs.id == rhs.id
    }
}

nonisolated struct WorkflowListResponse: Codable, Sendable {
    let data: [Workflow]
    let nextCursor: String?
}
