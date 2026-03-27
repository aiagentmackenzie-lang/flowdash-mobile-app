import SwiftUI

@Observable
@MainActor
class WorkflowsViewModel {
    var workflows: [Workflow] = []
    var isLoading = false
    var errorMessage: String?
    var toastMessage: String?
    var toastIsError = false

    private let apiService: N8NAPIService

    init(apiService: N8NAPIService) {
        self.apiService = apiService
    }

    func fetchWorkflows() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            workflows = try await apiService.fetchWorkflows()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleWorkflow(_ workflow: Workflow) async {
        do {
            if workflow.active {
                try await apiService.deactivateWorkflow(id: workflow.id)
            } else {
                try await apiService.activateWorkflow(id: workflow.id)
            }
            await fetchWorkflows()
            showToast("\(workflow.name) \(workflow.active ? "deactivated" : "activated")", isError: false)
        } catch {
            showToast(error.localizedDescription, isError: true)
        }
    }

    func triggerWorkflow(_ workflow: Workflow) async {
        do {
            try await apiService.triggerWorkflow(id: workflow.id)
            showToast("Workflow triggered!", isError: false)
        } catch {
            showToast(error.localizedDescription, isError: true)
        }
    }

    private func showToast(_ message: String, isError: Bool) {
        toastMessage = message
        toastIsError = isError
        Task {
            try? await Task.sleep(for: .seconds(3))
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}
