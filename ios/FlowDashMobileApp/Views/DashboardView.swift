import SwiftUI

struct DashboardView: View {
    let apiService: N8NAPIService
    @State private var viewModel: WorkflowsViewModel
    @State private var appeared = false

    init(apiService: N8NAPIService) {
        self.apiService = apiService
        _viewModel = State(initialValue: WorkflowsViewModel(apiService: apiService))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if viewModel.isLoading && viewModel.workflows.isEmpty {
                    ProgressView()
                        .tint(.blue)
                        .scaleEffect(1.2)
                } else if viewModel.workflows.isEmpty {
                    ContentUnavailableView(
                        "No Workflows Found",
                        systemImage: "flowchart",
                        description: Text("Create one in N8N first.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(viewModel.workflows.enumerated()), id: \.element.id) { index, workflow in
                                NavigationLink(value: workflow) {
                                    WorkflowCard(workflow: workflow) {
                                        Task { await viewModel.toggleWorkflow(workflow) }
                                    }
                                }
                                .buttonStyle(.plain)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring(response: 0.4).delay(Double(index) * 0.04), value: appeared)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await viewModel.fetchWorkflows()
                    }
                }
            }
            .navigationTitle("My Workflows")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.fetchWorkflows() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationDestination(for: Workflow.self) { workflow in
                WorkflowDetailView(workflow: workflow, apiService: apiService)
            }
            .overlay(alignment: .top) {
                if let msg = viewModel.toastMessage {
                    ToastView(message: msg, isError: viewModel.toastIsError)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
            .animation(.snappy, value: viewModel.toastMessage)
            .task {
                await viewModel.fetchWorkflows()
                appeared = true
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct WorkflowCard: View {
    let workflow: Workflow
    let onToggle: () -> Void
    @State private var isToggling = false

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 4)
                .fill(workflow.active ? Color.green : Color.gray.opacity(0.4))
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    StatusBadge(
                        text: workflow.active ? "ACTIVE" : "INACTIVE",
                        color: workflow.active ? .green : .gray
                    )

                    Text(timeAgoString(from: workflow.updatedAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { workflow.active },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .tint(.green)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(.rect(cornerRadius: 4))
    }
}
