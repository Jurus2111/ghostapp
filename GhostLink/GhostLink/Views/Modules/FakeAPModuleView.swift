import SwiftUI

struct FakeAPModuleView: View {
    @EnvironmentObject var appState: AppState
    @State private var ssid: String = "Free Starlink WiFi"
    @State private var isRunning = false
    @State private var connectionLogs: [APConnectionLog] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("FAKE AP")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(.top, 56)

                TextField("Nazwa sieci", text: $ssid)
                    .padding()
                    .foregroundColor(GhostTheme.textPrimary)
                    .background(GhostTheme.pureBlack)
                    .neonBorder()
                    .disabled(isRunning)
                    .onChange(of: ssid) { newValue in
                        FakeAPService.shared.ssid = newValue
                    }

                Toggle(isOn: Binding(
                    get: { isRunning },
                    set: { on in
                        appState.haptic()
                        FakeAPService.shared.ssid = ssid
                        if on { FakeAPService.shared.start() } else { FakeAPService.shared.stop() }
                        syncState()
                    }
                )) {
                    Text("Start AP")
                        .foregroundColor(GhostTheme.textPrimary)
                }
                .tint(GhostTheme.neonPink)

                Text("Live log")
                    .font(.headline)
                    .foregroundColor(GhostTheme.neonPinkLight)

                ForEach(connectionLogs.indices, id: \.self) { index in
                    let log = connectionLogs[index]
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(log.deviceIP) · \(log.deviceMAC)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(GhostTheme.neonPink)
                        Text(log.capturedData)
                            .font(.caption)
                            .foregroundColor(GhostTheme.textPrimary)
                        Text(log.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(GhostTheme.textSecondary)
                    }
                    .padding()
                    .neonBorder()
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(GhostTheme.background)
        .onAppear(perform: syncState)
        .onReceive(FakeAPService.shared.$connectionLogs) { _ in syncState() }
        .onReceive(FakeAPService.shared.$isRunning) { _ in syncState() }
    }

    private func syncState() {
        ssid = FakeAPService.shared.ssid
        isRunning = FakeAPService.shared.isRunning
        connectionLogs = FakeAPService.shared.connectionLogs
    }
}
