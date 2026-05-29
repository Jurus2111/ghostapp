import SwiftUI

struct DeauthModuleView: View {
    @EnvironmentObject var appState: AppState
    @State private var networks: [WiFiNetwork] = []
    @State private var isScanning = false
    @State private var selectedNetwork: WiFiNetwork?
    @State private var selectedClient: NetworkClient?
    @State private var packetCount: Double = 25
    @State private var flash = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("DEAUTH WAVE")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(.top, 56)

                Button("Skanuj Wi-Fi") {
                    appState.haptic()
                    WiFiScannerService.shared.scan()
                }
                .buttonStyle(NeonFillButtonStyle())

                if isScanning {
                    ProgressView().tint(GhostTheme.neonPink)
                }

                ForEach(networks.indices, id: \.self) { index in
                    networkSection(networks[index])
                }

                if selectedClient != nil {
                    Text("Pakiety: \(Int(packetCount))")
                        .foregroundColor(GhostTheme.textSecondary)
                    Slider(value: $packetCount, in: 1...100, step: 1)
                        .tint(GhostTheme.neonPink)

                    Button("WYPIERDOL Z SIECI") {
                        guard let net = selectedNetwork, let client = selectedClient else { return }
                        appState.haptic(.heavy)
                        flash = true
                        WiFiScannerService.shared.simulateDeauth(
                            network: net,
                            client: client,
                            packetCount: Int(packetCount)
                        ) {
                            flash = false
                        }
                    }
                    .buttonStyle(NeonFillButtonStyle())
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(GhostTheme.background)
        .overlay(flash ? GhostTheme.neonPink.opacity(0.35).ignoresSafeArea() : nil)
        .animation(.easeOut(duration: 0.3), value: flash)
        .onAppear(perform: syncScanner)
        .onReceive(WiFiScannerService.shared.$networks) { _ in syncScanner() }
        .onReceive(WiFiScannerService.shared.$isScanning) { _ in syncScanner() }
    }

    @ViewBuilder
    private func networkSection(_ net: WiFiNetwork) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                selectedNetwork = net
                selectedClient = nil
                appState.haptic(.light)
            } label: {
                HStack {
                    Image(systemName: "wifi")
                    Text(net.ssid)
                    Spacer()
                    Text("\(net.signal) dBm")
                        .font(.caption)
                }
                .foregroundColor(selectedNetwork?.id == net.id ? GhostTheme.neonPink : GhostTheme.textPrimary)
            }

            if selectedNetwork?.id == net.id {
                ForEach(net.clients.indices, id: \.self) { clientIndex in
                    let client = net.clients[clientIndex]
                    Button {
                        selectedClient = client
                    } label: {
                        VStack(alignment: .leading) {
                            Text(client.hostname).font(.caption.weight(.bold))
                            Text("\(client.ip) · \(client.mac)")
                                .font(.caption2)
                                .foregroundColor(GhostTheme.textSecondary)
                        }
                        .foregroundColor(selectedClient?.id == client.id ? GhostTheme.neonPinkLight : GhostTheme.textPrimary)
                    }
                    .padding(.leading, 12)
                }
            }
        }
        .padding()
        .neonBorder(highlighted: selectedNetwork?.id == net.id)
    }

    private func syncScanner() {
        networks = WiFiScannerService.shared.networks
        isScanning = WiFiScannerService.shared.isScanning
    }
}
