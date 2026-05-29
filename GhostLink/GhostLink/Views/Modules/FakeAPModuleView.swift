import SwiftUI

struct FakeAPModuleView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var ap = FakeAPService.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("FAKE AP")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(.top, 56)

                TextField("Nazwa sieci", text: $ap.ssid)
                    .padding()
                    .foregroundColor(GhostTheme.textPrimary)
                    .background(GhostTheme.pureBlack)
                    .neonBorder()
                    .disabled(ap.isRunning)

                Toggle(isOn: Binding(
                    get: { ap.isRunning },
                    set: { on in
                        appState.haptic()
                        if on { ap.start() } else { ap.stop() }
                    }
                )) {
                    Text("Start AP")
                        .foregroundColor(GhostTheme.textPrimary)
                }
                .tint(GhostTheme.neonPink)

                Text("Live log")
                    .font(.headline)
                    .foregroundColor(GhostTheme.neonPinkLight)

                ForEach(Array(ap.connectionLogs)) { log in
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
    }
}
