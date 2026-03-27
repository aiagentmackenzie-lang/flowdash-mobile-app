import SwiftUI

@Observable
@MainActor
class ExecutionsViewModel {
    var executions: [Execution] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var selectedFilter: String = "all"
    var nextCursor: String?
    var hasMore = true

    private let apiService: N8NAPIService

    let filters = ["all", "success", "error", "running", "waiting"]

    init(apiService: N8NAPIService) {
        self.apiService = apiService
    }

    func fetchExecutions(workflowId: String? = nil) async {
        isLoading = true
        errorMessage = nil
        nextCursor = nil
        hasMore = true
        defer { isLoading = false }
        do {
            let statusParam = selectedFilter == "all" ? nil : selectedFilter
            let response = try await apiService.fetchExecutions(
                workflowId: workflowId,
                status: statusParam,
                limit: 20
            )
            executions = response.data
            nextCursor = response.nextCursor
            hasMore = response.nextCursor != nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMore(workflowId: String? = nil) async {
        guard hasMore, !isLoadingMore, let cursor = nextCursor else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let statusParam = selectedFilter == "all" ? nil : selectedFilter
            let response = try await apiService.fetchExecutions(
                workflowId: workflowId,
                status: statusParam,
                limit: 20,
                cursor: cursor
            )
            executions.append(contentsOf: response.data)
            nextCursor = response.nextCursor
            hasMore = response.nextCursor != nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchExecutionDetail(id: String) async -> ExecutionDetailResponse? {
        do {
            return try await apiService.fetchExecution(id: id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
