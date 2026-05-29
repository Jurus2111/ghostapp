import Foundation
import Combine

final class CredentialStore: ObservableObject {
    static let shared = CredentialStore()

    @Published private(set) var credentials: [HarvestedCredential] = []

    private let fileName = "ghostlink_credentials.json"

    private init() { load() }

    func add(username: String, password: String) {
        let cred = HarvestedCredential(username: username, password: password)
        credentials.insert(cred, at: 0)
        persist()
        LogStore.shared.add(module: "HARVESTER", message: "Captured credentials for \(username)")
    }

    func clear() {
        credentials.removeAll()
        try? FileManager.default.removeItem(at: fileURL)
    }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(credentials) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = try? JSONDecoder().decode([HarvestedCredential].self, from: data) else { return }
        credentials = loaded
    }
}
