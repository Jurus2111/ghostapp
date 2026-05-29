import Foundation
import Combine

final class LogStore: ObservableObject {
    static let shared = LogStore()

    @Published private(set) var entries: [LogEntry] = []

    private let fileName = "ghostlink_logs.json"

    private init() {
        load()
    }

    func add(module: String, message: String) {
        let entry = LogEntry(module: module, message: message)
        DispatchQueue.main.async {
            self.entries.insert(entry, at: 0)
            self.persist()
        }
    }

    func clear() {
        entries.removeAll()
        persist()
    }

    func exportCSV() -> URL? {
        var csv = "timestamp,module,message\n"
        let formatter = ISO8601DateFormatter()
        for e in entries.reversed() {
            let ts = formatter.string(from: e.timestamp)
            let msg = e.message.replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\"\(ts)\",\"\(e.module)\",\"\(msg)\"\n"
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ghostlink_logs.csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = try? JSONDecoder().decode([LogEntry].self, from: data) else { return }
        entries = loaded
    }

    func wipeAllData() {
        entries.removeAll()
        try? FileManager.default.removeItem(at: fileURL)
        SnifferService.shared.clear()
        FakeAPService.shared.clear()
        CredentialStore.shared.clear()
    }
}
