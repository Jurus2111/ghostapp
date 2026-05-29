import SwiftUI

struct LogsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var logStore = LogStore.shared
    @State private var showClearConfirm = false
    @State private var showShare = false
    @State private var exportURL: URL?

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("LOGI")
                    .font(.title2.weight(.black))
                    .foregroundColor(GhostTheme.neonPink)
                Spacer()
            }
            .padding()

            List {
                ForEach(Array(logStore.entries)) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.module)
                                .font(.caption.weight(.bold))
                                .foregroundColor(GhostTheme.neonPink)
                            Spacer()
                            Text(formatter.string(from: entry.timestamp))
                                .font(.caption2)
                                .foregroundColor(GhostTheme.textSecondary)
                        }
                        Text(entry.message)
                            .font(.subheadline)
                            .foregroundColor(GhostTheme.textPrimary)
                    }
                    .listRowBackground(GhostTheme.background)
                }
            }
            .listStyle(.plain)

            HStack(spacing: 12) {
                Button("Wyczyść logi") { showClearConfirm = true }
                    .foregroundColor(.red)
                Button("Eksport CSV") {
                    exportURL = logStore.exportCSV()
                    showShare = true
                }
                .foregroundColor(GhostTheme.neonPink)
            }
            .padding()
            .padding(.bottom, 70)
        }
        .background(GhostTheme.background)
        .alert("Wyczyścić wszystkie logi?", isPresented: $showClearConfirm) {
            Button("Anuluj", role: .cancel) {}
            Button("Wyczyść", role: .destructive) {
                logStore.clear()
                appState.haptic()
            }
        }
        .sheet(isPresented: $showShare) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }
}
