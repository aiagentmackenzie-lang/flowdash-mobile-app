import SwiftUI

struct MainTabView: View {
    let appViewModel: AppViewModel
    @State private var selectedTab = 0
    @State private var showSetup = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "square.grid.2x2.fill", value: 0) {
                DashboardView(apiService: appViewModel.apiService)
            }

            Tab("Executions", systemImage: "clock.arrow.circlepath", value: 1) {
                ExecutionsTabView(apiService: appViewModel.apiService)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 2) {
                SettingsView(
                    storage: appViewModel.storage,
                    onDisconnect: {
                        appViewModel.disconnect()
                    },
                    onEditConnection: {
                        showSetup = true
                    }
                )
            }
        }
        .tint(.blue)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSetup) {
            NavigationStack {
                SetupView(storage: appViewModel.storage) {
                    showSetup = false
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showSetup = false }
                    }
                }
            }
        }
    }
}
