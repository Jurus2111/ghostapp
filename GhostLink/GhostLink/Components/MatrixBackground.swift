import SwiftUI

struct MatrixBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 120, paused: false)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(GhostTheme.pureBlack))

                for i in 0..<24 {
                    let x = (CGFloat(i) / 24) * size.width + CGFloat(sin(t * 0.4 + Double(i)) * 20)
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: -40))
                    path.addLine(to: CGPoint(x: x + CGFloat(cos(t + Double(i)) * 30), y: size.height + 40))

                    let opacity = 0.15 + 0.25 * abs(sin(t * 0.8 + Double(i)))
                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [
                                GhostTheme.neonPink.opacity(0),
                                GhostTheme.neonPink.opacity(opacity),
                                GhostTheme.neonPinkLight.opacity(opacity * 1.2),
                                GhostTheme.neonPink.opacity(0)
                            ]),
                            startPoint: CGPoint(x: x, y: 0),
                            endPoint: CGPoint(x: x, y: size.height)
                        ),
                        lineWidth: 1.2
                    )
                }

                for j in 0..<40 {
                    let y = CGFloat(j) * (size.height / 40) + CGFloat((t * 60).truncatingRemainder(dividingBy: size.height / 40))
                    let w = size.width * 0.3
                    let rect = CGRect(x: CGFloat(sin(t * 2 + Double(j)) * 40) + size.width * 0.35, y: y, width: w, height: 1)
                    context.fill(Path(rect), with: .color(GhostTheme.neonPink.opacity(0.08)))
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { phase = 1 }
    }
}

struct PinkFlashOverlay: View {
    @Binding var isActive: Bool

    var body: some View {
        if isActive {
            RadialGradient(
                colors: [GhostTheme.neonPinkLight, GhostTheme.neonPink, GhostTheme.pureBlack.opacity(0)],
                center: .center,
                startRadius: 10,
                endRadius: 400
            )
            .ignoresSafeArea()
            .opacity(isActive ? 1 : 0)
            .animation(.easeOut(duration: 0.6), value: isActive)
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 6
    var shakes: CGFloat = 2
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakes), y: 0))
    }
}

struct WaveButtonStyle: ButtonStyle {
    @EnvironmentObject var appState: AppState

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(appState.settings.animationsEnabled ? GhostTheme.springFast : nil, value: configuration.isPressed)
    }
}

struct NeonTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding()
        .foregroundColor(GhostTheme.textPrimary)
        .background(GhostTheme.pureBlack)
        .neonBorder()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
