import SwiftUI

struct SnifferModuleView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var sniffer = SnifferService.shared
    @State private var showShare = false
    @State private var exportURL: URL?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("SNIFFER")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(.top, 56)

                Button(sniffer.isRunning ? "Stop Sniffing" : "Start Sniffing") {
                    appState.haptic()
                    if sniffer.isRunning { sniffer.stop() } else { sniffer.start() }
                }
                .buttonStyle(NeonFillButtonStyle())

                if let url = exportURL {
                    Button("Eksportuj .txt") {
                        showShare = true
                    }
                    .foregroundColor(GhostTheme.neonPinkLight)
                    .sheet(isPresented: $showShare) {
                        ShareSheet(items: [url])
                    }
                }

                ForEach(Array(sniffer.packets)) { packet in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(packet.type.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundColor(packet.isNew ? GhostTheme.neonPink : GhostTheme.textSecondary)
                            Spacer()
                            Text(packet.capturedAt, style: .time)
                                .font(.caption2)
                                .foregroundColor(GhostTheme.textSecondary)
                        }
                        Text(packet.summary)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(packet.isNew ? GhostTheme.neonPinkLight : GhostTheme.textPrimary)
                        Text(packet.detail)
                            .font(.caption)
                            .foregroundColor(GhostTheme.textSecondary)
                    }
                    .padding()
                    .neonBorder(highlighted: packet.isNew)
                    .onAppear { markRead(packet) }
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(GhostTheme.background)
        .onChange(of: sniffer.packets.count) { _ in
            exportURL = sniffer.exportTXT()
        }
        .onAppear { exportURL = sniffer.exportTXT() }
    }

    private func markRead(_ packet: CapturedPacket) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SnifferService.shared.markRead(id: packet.id)
        }
    }
}

struct NeonFillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(GhostTheme.neonPink)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
