import Foundation

enum GhostModule: String, CaseIterable, Identifiable {
    case sniffer = "Sniffer"
    case deauth = "Deauth Wave"
    case fakeAP = "Fake AP"
    case smsBomber = "SMS Bomber"
    case credentialHarvester = "Credential Harvester"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sniffer: return "antenna.radiowaves.left.and.right"
        case .deauth: return "wifi.exclamationmark"
        case .fakeAP: return "dot.radiowaves.up.forward"
        case .smsBomber: return "message.badge.filled.fill"
        case .credentialHarvester: return "key.viewfinder"
        }
    }
}

struct LogEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let module: String
    let message: String

    init(id: UUID = UUID(), timestamp: Date = Date(), module: String, message: String) {
        self.id = id
        self.timestamp = timestamp
        self.module = module
        self.message = message
    }
}

enum PacketType: String, Codable {
    case http = "HTTP"
    case dns = "DNS"
    case cookie = "COOKIE"
}

struct CapturedPacket: Identifiable, Codable, Equatable {
    let id: UUID
    let type: PacketType
    let summary: String
    let detail: String
    let capturedAt: Date
    var isNew: Bool

    init(
        id: UUID = UUID(),
        type: PacketType,
        summary: String,
        detail: String,
        capturedAt: Date = Date(),
        isNew: Bool = true
    ) {
        self.id = id
        self.type = type
        self.summary = summary
        self.detail = detail
        self.capturedAt = capturedAt
        self.isNew = isNew
    }
}

struct WiFiNetwork: Identifiable, Equatable {
    let id = UUID()
    let ssid: String
    let bssid: String
    let signal: Int
    var clients: [NetworkClient]
}

struct NetworkClient: Identifiable, Equatable {
    let id = UUID()
    let ip: String
    let mac: String
    let hostname: String
}

struct HarvestedCredential: Identifiable, Codable, Equatable {
    let id: UUID
    let username: String
    let password: String
    let capturedAt: Date
    let source: String

    init(id: UUID = UUID(), username: String, password: String, capturedAt: Date = Date(), source: String = "iCloud Lab") {
        self.id = id
        self.username = username
        self.password = password
        self.capturedAt = capturedAt
        self.source = source
    }
}

struct APConnectionLog: Identifiable, Equatable {
    let id = UUID()
    let deviceMAC: String
    let deviceIP: String
    let timestamp: Date
    let capturedData: String
}

enum MainTab: Int, CaseIterable {
    case home = 0
    case logs = 1
    case terminal = 2
    case settings = 3
    case powerOff = 4

    var title: String {
        switch self {
        case .home: return "Home"
        case .logs: return "Logi"
        case .terminal: return "Terminal"
        case .settings: return "Ustawienia"
        case .powerOff: return "Wyłącz"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .logs: return "list.bullet.rectangle"
        case .terminal: return "terminal.fill"
        case .settings: return "gearshape.fill"
        case .powerOff: return "power"
        }
    }
}
