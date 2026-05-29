import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = TerminalViewModel()
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TERMINAL")
                .font(.title2.weight(.black))
                .foregroundColor(GhostTheme.neonPink)
                .padding()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(vm.lines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(lineColor(line))
                        }
                        HStack(spacing: 0) {
                            Text("ghost@link:~$ ")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(GhostTheme.neonPink)
                            Text(vm.input)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(GhostTheme.textPrimary)
                            BlinkingCursor()
                        }
                        .id("bottom")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .onChange(of: vm.lines.count) { _ in
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }

            HStack {
                Button(action: { vm.historyUp() }) {
                    Image(systemName: "chevron.up")
                }
                Button(action: { vm.historyDown() }) {
                    Image(systemName: "chevron.down")
                }
                TextField("Wpisz komendę…", text: $vm.input)
                    .focused($focused)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(GhostTheme.textPrimary)
                    .onSubmit { vm.execute(appState: appState) }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(GhostTheme.pureBlack)
        .padding(.bottom, 70)
        .onAppear {
            vm.boot()
            focused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in }
    }

    private func lineColor(_ line: String) -> Color {
        if line.hasPrefix("ghost@") { return GhostTheme.neonPink }
        if line.contains("ERROR") { return .red }
        return GhostTheme.textPrimary
    }
}

struct BlinkingCursor: View {
    @State private var visible = true

    var body: some View {
        Rectangle()
            .fill(GhostTheme.neonPink)
            .frame(width: 8, height: 16)
            .opacity(visible ? 1 : 0)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    visible.toggle()
                }
            }
    }
}

final class TerminalViewModel: ObservableObject {
    @Published var lines: [String] = []
    @Published var input = ""
    private var history: [String] = []
    private var historyIndex = -1

    func boot() {
        lines = [
            "GHOSTLINK Terminal v1.0",
            "Type 'help' for commands."
        ]
    }

    func execute(appState: AppState) {
        let cmd = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cmd.isEmpty else { return }
        history.insert(cmd, at: 0)
        historyIndex = -1
        lines.append("ghost@link:~$ \(cmd)")
        input = ""

        let parts = cmd.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        let verb = parts.first?.lowercased() ?? ""

        switch verb {
        case "help":
            lines.append(contentsOf: [
                "help          – this message",
                "scan          – Wi-Fi scan",
                "deauth [MAC]  – deauth target",
                "logs          – show recent logs",
                "clear         – clear screen",
                "exit          – back to home"
            ])
        case "scan":
            WiFiScannerService.shared.scan()
            lines.append("Scanning… check DEAUTH module.")
            LogStore.shared.add(module: "TERMINAL", message: "scan executed")
        case "deauth":
            let mac = parts.count > 1 ? parts[1] : "FF:FF:FF:FF:FF:FF"
            lines.append("Sending deauth to \(mac) (lab sim)")
            LogStore.shared.add(module: "TERMINAL", message: "deauth \(mac)")
        case "logs":
            let recent = LogStore.shared.entries.prefix(5)
            for e in recent {
                lines.append("[\(e.module)] \(e.message)")
            }
        case "clear":
            lines.removeAll()
            boot()
        case "exit":
            appState.selectedTab = .home
        default:
            lines.append("ERROR: unknown command '\(verb)'")
        }
    }

    func historyUp() {
        guard !history.isEmpty else { return }
        historyIndex = min(historyIndex + 1, history.count - 1)
        input = history[historyIndex]
    }

    func historyDown() {
        guard historyIndex > 0 else {
            historyIndex = -1
            input = ""
            return
        }
        historyIndex -= 1
        input = history[historyIndex]
    }
}
