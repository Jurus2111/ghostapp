import Foundation
import Combine
import Network

final class SnifferService: ObservableObject {
    static let shared = SnifferService()

    @Published private(set) var packets: [CapturedPacket] = []
    @Published private(set) var isRunning = false

    private var timer: Timer?
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ghost.sniffer")

    private let samplePayloads: [(PacketType, String, String)] = [
        (.http, "GET /api/session", "Host: lab.university.edu | User-Agent: GhostLink/1.0"),
        (.dns, "A record query", "login.icloud.com -> 17.253.144.10"),
        (.cookie, "Set-Cookie", "session_id=abc123; Secure; HttpOnly"),
        (.http, "POST /auth", "Content-Type: application/json | body: {\"user\":\"test\"}"),
        (.dns, "PTR lookup", "192.168.1.42 -> device.lab.local"),
        (.http, "GET /assets/logo.png", "304 Not Modified"),
        (.cookie, "document.cookie", "auth_token=eyJhbGciOiJIUzI1NiJ9..."),
        (.dns, "AAAA query", "ipv6.google.com -> 2607:f8b0:4004:c09::65")
    ]

    private var sampleIndex = 0

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            self?.injectNetworkStatus(path: path)
        }
        monitor.start(queue: queue)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        LogStore.shared.add(module: "SNIFFER", message: "Capture started on lab interface")
        timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
            self?.captureNext()
        }
        RunLoop.main.add(timer!, forMode: .common)
        captureNext()
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        LogStore.shared.add(module: "SNIFFER", message: "Capture stopped")
    }

    func markAllRead() {
        packets = packets.map { p in
            var copy = p
            copy.isNew = false
            return copy
        }
    }

    func markRead(id: UUID) {
        guard let i = packets.firstIndex(where: { $0.id == id }) else { return }
        var copy = packets[i]
        copy.isNew = false
        packets[i] = copy
    }

    func clear() {
        stop()
        packets.removeAll()
    }

    func exportTXT() -> URL? {
        var text = "GHOSTLINK Packet Export\n"
        text += "Generated: \(ISO8601DateFormatter().string(from: Date()))\n\n"
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss.SSS"
        for p in packets {
            text += "[\(df.string(from: p.capturedAt))] \(p.type.rawValue)\n"
            text += "  \(p.summary)\n"
            text += "  \(p.detail)\n\n"
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ghostlink_packets.txt")
        try? text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func captureNext() {
        let sample = samplePayloads[sampleIndex % samplePayloads.count]
        sampleIndex += 1
        let packet = CapturedPacket(type: sample.0, summary: sample.1, detail: sample.2)
        DispatchQueue.main.async {
            self.packets.insert(packet, at: 0)
            if self.packets.count > 200 { self.packets.removeLast() }
            LogStore.shared.add(module: "SNIFFER", message: "\(packet.type.rawValue): \(packet.summary)")
        }
    }

    private func injectNetworkStatus(path: NWPath) {
        let iface = path.availableInterfaces.first?.name ?? "en0"
        let type: PacketType = .dns
        let packet = CapturedPacket(
            type: type,
            summary: "Interface \(iface) active",
            detail: "path: \(path.status) | expensive: \(path.isExpensive)"
        )
        DispatchQueue.main.async {
            if self.isRunning {
                self.packets.insert(packet, at: 0)
            }
        }
    }
}
