import SwiftUI

struct ExecutionsTabView: View {
    let apiService: N8NAPIService
    @State private var viewModel: ExecutionsViewModel

    init(apiService: N8NAPIService) {
        self.apiService = apiService
        _viewModel = State(initialValue: ExecutionsViewModel(apiService: apiService))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    filterBar

                    if viewModel.isLoading && viewModel.executions.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(.blue)
                            .scaleEffect(1.2)
                        Spacer()
                    } else if viewModel.executions.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "No Executions",
                            systemImage: "clock",
                            description: Text("No executions match this filter.")
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.executions) { execution in
                                    NavigationLink(value: execution) {
                                        ExecutionRow(execution: execution, showWorkflowName: true)
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        if execution.id == viewModel.executions.last?.id {
                                            Task { await viewModel.loadMore() }
                                        }
                                    }
                                }

                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .tint(.blue)
                                        .padding()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 100)
                        }
                        .refreshable {
                            await viewModel.fetchExecutions()
                        }
                    }
                }
            }
            .navigationTitle("Executions")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Execution.self) { execution in
                ExecutionDetailView(executionId: execution.id, apiService: apiService)
            }
            .task {
                await viewModel.fetchExecutions()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.filters, id: \.self) { filter in
                    Button {
                        viewModel.selectedFilter = filter
                        Task { await viewModel.fetchExecutions() }
                    } label: {
                        Text(filter.capitalized)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : .secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedFilter == filter
                                    ? Color.blue
                                    : Color.white.opacity(0.08)
                            )
                            .clipShape(.capsule)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

struct ExecutionRow: View {
    let execution: Execution
    let showWorkflowName: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: execution.statusType.icon)
                .font(.title3)
                .foregroundStyle(executionColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                if showWorkflowName, let name = execution.workflowData?.name {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    StatusBadge(text: execution.statusType.label.uppercased(), color: executionColor)

                    Text(timeAgoString(from: execution.startedAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let dur = execution.durationSeconds {
                        Text(formatDuration(dur))
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var executionColor: Color {
        switch execution.statusType {
        case .success: return .green
        case .failed: return .red
        case .running: return .orange
        case .waiting: return .yellow
        case .unknown: return .gray
        }
    }
}
