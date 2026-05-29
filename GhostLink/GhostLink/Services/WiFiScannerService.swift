import Foundation
import Combine
import SystemConfiguration.CaptiveNetwork

final class WiFiScannerService: ObservableObject {
    static let shared = WiFiScannerService()

    @Published private(set) var networks: [WiFiNetwork] = []
    @Published private(set) var isScanning = false

    private init() {}

    func scan() {
        isScanning = true
        LogStore.shared.add(module: "DEAUTH", message: "Wi-Fi scan initiated")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var found: [WiFiNetwork] = []
            if let current = Self.currentSSID() {
                found.append(Self.labNetwork(ssid: current, signal: -42))
            }
            found.append(contentsOf: Self.labNetworks())

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.networks = found
                self?.isScanning = false
                LogStore.shared.add(module: "DEAUTH", message: "Found \(found.count) networks")
            }
        }
    }

    func simulateDeauth(
        network: WiFiNetwork,
        client: NetworkClient,
        packetCount: Int,
        completion: @escaping () -> Void
    ) {
        LogStore.shared.add(
            module: "DEAUTH",
            message: "Sending \(packetCount) deauth frames to \(client.mac) on \(network.ssid)"
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(packetCount) * 0.02) {
            LogStore.shared.add(
                module: "DEAUTH",
                message: "Target \(client.ip) disconnected (lab simulation)"
            )
            completion()
        }
    }

    private static func currentSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        for iface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(iface as CFString) as? [String: AnyObject],
                  let ssid = info[kCNNetworkInfoKeySSID as String] as? String else { continue }
            return ssid
        }
        return nil
    }

    private static func labNetwork(ssid: String, signal: Int) -> WiFiNetwork {
        WiFiNetwork(
            ssid: ssid,
            bssid: randomMAC(),
            signal: signal,
            clients: labClients(prefix: String(ssid.prefix(3)))
        )
    }

    private static func labNetworks() -> [WiFiNetwork] {
        [
            WiFiNetwork(ssid: "UNI_LAB_SECURE", bssid: "AA:BB:CC:11:22:33", signal: -55, clients: labClients(prefix: "uni")),
            WiFiNetwork(ssid: "Free Starlink WiFi", bssid: "DE:AD:BE:EF:00:01", signal: -68, clients: labClients(prefix: "star")),
            WiFiNetwork(ssid: "GhostLink_Test", bssid: "12:34:56:78:9A:BC", signal: -48, clients: labClients(prefix: "gl"))
        ]
    }

    private static func labClients(prefix: String) -> [NetworkClient] {
        [
            NetworkClient(ip: "192.168.1.\(Int.random(in: 10...99))", mac: randomMAC(), hostname: "\(prefix)-iphone"),
            NetworkClient(ip: "192.168.1.\(Int.random(in: 100...199))", mac: randomMAC(), hostname: "\(prefix)-laptop"),
            NetworkClient(ip: "192.168.1.\(Int.random(in: 200...250))", mac: randomMAC(), hostname: "\(prefix)-iot")
        ]
    }

    private static func randomMAC() -> String {
        (0..<6).map { _ in String(format: "%02X", Int.random(in: 0...255)) }.joined(separator: ":")
    }
}
