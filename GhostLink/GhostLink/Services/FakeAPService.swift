import Foundation
import Combine

final class FakeAPService: ObservableObject {
    static let shared = FakeAPService()

    @Published private(set) var isRunning = false
    @Published private(set) var connectionLogs: [APConnectionLog] = []
    @Published var ssid: String = "Free Starlink WiFi"

    private var timer: Timer?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        LogStore.shared.add(module: "FAKE_AP", message: "Rogue AP started: \(ssid)")
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            self?.simulateConnection()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        LogStore.shared.add(module: "FAKE_AP", message: "Rogue AP stopped")
    }

    func clear() {
        stop()
        connectionLogs.removeAll()
    }

    private func simulateConnection() {
        let mac = (0..<6).map { _ in String(format: "%02X", Int.random(in: 0...255)) }.joined(separator: ":")
        let ip = "10.0.0.\(Int.random(in: 2...254))"
        let dataOptions = [
            "POST /login email=test@lab.edu",
            "GET /captive portal probe",
            "DNS query: apple.com",
            "HTTP Basic: dGVzdDp0ZXN0"
        ]
        let log = APConnectionLog(
            deviceMAC: mac,
            deviceIP: ip,
            timestamp: Date(),
            capturedData: dataOptions.randomElement() ?? "probe"
        )
        DispatchQueue.main.async {
            self.connectionLogs.insert(log, at: 0)
            LogStore.shared.add(module: "FAKE_AP", message: "Client \(ip) connected – data captured")
        }
    }
}
