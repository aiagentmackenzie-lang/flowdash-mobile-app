import SwiftUI

struct WorkflowDetailView: View {
    let workflow: Workflow
    let apiService: N8NAPIService
    @State private var execViewModel: ExecutionsViewModel
    @State private var workflowsVM: WorkflowsViewModel
    @State private var isTriggering = false
    @State private var toastMessage: String?
    @State private var toastIsError = false
    @State private var triggerBounce = 0
    @State private var isActive: Bool

    init(workflow: Workflow, apiService: N8NAPIService) {
        self.workflow = workflow
        self.apiService = apiService
        _execViewModel = State(initialValue: ExecutionsViewModel(apiService: apiService))
        _workflowsVM = State(initialValue: WorkflowsViewModel(apiService: apiService))
        _isActive = State(initialValue: workflow.active)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        HStack {
                            StatusBadge(
                                text: isActive ? "ACTIVE" : "INACTIVE",
                                color: isActive ? .green : .gray
                            )

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { isActive },
                                set: { newValue in
                                    Task {
                                        if newValue {
                                            try? await apiService.activateWorkflow(id: workflow.id)
                                        } else {
                                            try? await apiService.deactivateWorkflow(id: workflow.id)
                                        }
                                        isActive = newValue
                                    }
                                }
                            ))
                            .labelsHidden()
                            .tint(.green)
                        }

                        Button {
                            Task { await triggerWorkflow() }
                        } label: {
                            HStack(spacing: 10) {
                                if isTriggering {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "play.fill")
                                        .symbolEffect(.bounce, value: triggerBounce)
                                }
                                Text(isTriggering ? "Triggering..." : "Trigger Now")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .disabled(isTriggering)
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Executions")
                            .font(.title3.bold())
                            .foregroundStyle(.white)

                        if execViewModel.isLoading && execViewModel.executions.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView().tint(.blue)
                                Spacer()
                            }
                            .padding(.vertical, 32)
                        } else if execViewModel.executions.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("No executions yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(execViewModel.executions) { execution in
                                    NavigationLink(value: execution) {
                                        ExecutionRow(execution: execution, showWorkflowName: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .refreshable {
                await execViewModel.fetchExecutions(workflowId: workflow.id)
            }
        }
        .navigationTitle(workflow.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Execution.self) { execution in
            ExecutionDetailView(executionId: execution.id, apiService: apiService)
        }
        .overlay(alignment: .top) {
            if let msg = toastMessage {
                ToastView(message: msg, isError: toastIsError)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .animation(.snappy, value: toastMessage)
        .task {
            await execViewModel.fetchExecutions(workflowId: workflow.id)
        }
        .preferredColorScheme(.dark)
    }

    private func triggerWorkflow() async {
        isTriggering = true
        defer { isTriggering = false }
        do {
            try await apiService.triggerWorkflow(id: workflow.id)
            triggerBounce += 1
            showToast("Workflow triggered!", isError: false)
            try? await Task.sleep(for: .seconds(1))
            await execViewModel.fetchExecutions(workflowId: workflow.id)
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
