import SwiftUI

enum AppScreen {
    case welcome
    case onboarding
    case setup
    case main
}

@Observable
@MainActor
class AppViewModel {
    var currentScreen: AppScreen = .welcome
    var storage = StorageService()

    func checkExistingConnection() {
        if storage.isConnected {
            currentScreen = .main
        }
    }

    func goToOnboarding() {
        withAnimation(.smooth(duration: 0.4)) {
            currentScreen = .onboarding
        }
    }

    func goToSetup() {
        withAnimation(.smooth(duration: 0.4)) {
            currentScreen = .setup
        }
    }

    func connectionSuccessful() {
        withAnimation(.smooth(duration: 0.4)) {
            currentScreen = .main
        }
    }

    func disconnect() {
        storage.disconnect()
        withAnimation(.smooth(duration: 0.4)) {
            currentScreen = .welcome
        }
    }

    var apiService: N8NAPIService {
        N8NAPIService(baseURL: storage.instanceURL, apiKey: storage.apiKey)
    }
}
