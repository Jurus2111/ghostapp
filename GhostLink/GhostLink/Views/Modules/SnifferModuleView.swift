import SwiftUI

struct SnifferModuleView: View {
    @EnvironmentObject var appState: AppState
    @State private var packets: [CapturedPacket] = []
    @State private var isRunning = false
    @State private var showShare = false
    @State private var exportURL: URL?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("SNIFFER")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                    .padding(.top, 56)

                Button(isRunning ? "Stop Sniffing" : "Start Sniffing") {
                    appState.haptic()
                    if isRunning {
                        SnifferService.shared.stop()
                    } else {
                        SnifferService.shared.start()
                    }
                    syncPackets()
                }
                .buttonStyle(NeonFillButtonStyle())

                if exportURL != nil {
                    Button("Eksportuj .txt") { showShare = true }
                        .foregroundColor(GhostTheme.neonPinkLight)
                }

                ForEach(packets.indices, id: \.self) { index in
                    packetRow(packets[index])
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(GhostTheme.background)
        .onAppear {
            syncPackets()
            exportURL = SnifferService.shared.exportTXT()
        }
        .onReceive(SnifferService.shared.$packets) { _ in
            syncPackets()
            exportURL = SnifferService.shared.exportTXT()
        }
        .onReceive(SnifferService.shared.$isRunning) { running in
            isRunning = running
        }
        .sheet(isPresented: $showShare) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func syncPackets() {
        packets = SnifferService.shared.packets
        isRunning = SnifferService.shared.isRunning
    }

    @ViewBuilder
    private func packetRow(_ packet: CapturedPacket) -> some View {
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                SnifferService.shared.markRead(id: packet.id)
                syncPackets()
            }
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
