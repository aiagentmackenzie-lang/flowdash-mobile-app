import Foundation

@Observable
@MainActor
class StorageService {
    private let urlKey = "n8n_instance_url"
    private let apiKeyKey = "n8n_api_key"

    var instanceURL: String {
        get { UserDefaults.standard.string(forKey: urlKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: urlKey) }
    }

    var apiKey: String {
        get { UserDefaults.standard.string(forKey: apiKeyKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: apiKeyKey) }
    }

    var isConnected: Bool {
        !instanceURL.isEmpty && !apiKey.isEmpty
    }

    func save(url: String, apiKey: String) {
        self.instanceURL = url
        self.apiKey = apiKey
    }

    func disconnect() {
        UserDefaults.standard.removeObject(forKey: urlKey)
        UserDefaults.standard.removeObject(forKey: apiKeyKey)
    }
}
