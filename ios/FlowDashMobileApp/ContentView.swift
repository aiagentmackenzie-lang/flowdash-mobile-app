import SwiftUI

struct ContentView: View {
    @State private var appViewModel = AppViewModel()

    var body: some View {
        Group {
            switch appViewModel.currentScreen {
            case .welcome:
                WelcomeView(
                    onGetStarted: { appViewModel.goToOnboarding() },
                    onHaveKey: { appViewModel.goToSetup() }
                )
            case .onboarding:
                OnboardingView(onComplete: { appViewModel.goToSetup() })
            case .setup:
                SetupView(
                    storage: appViewModel.storage,
                    onConnected: { appViewModel.connectionSuccessful() }
                )
            case .main:
                MainTabView(appViewModel: appViewModel)
            }
        }
        .onAppear {
            appViewModel.checkExistingConnection()
        }
    }
}
