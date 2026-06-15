import SwiftUI
import ARKit

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            if ARFaceTrackingConfiguration.isSupported {
                FaceTrackingView(maskStyle: appState.selectedMask)
                    .ignoresSafeArea()
            } else {
                UnsupportedDeviceView()
            }

            LinearGradient(
                colors: [.black.opacity(0.75), .clear, .black.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 16) {
                HeaderView()
                Spacer()
                ControlDeck()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .preferredColorScheme(.dark)
    }
}

private struct HeaderView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("FACEZERO")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.orange)

                Text(appState.statusText)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.82))
            }

            Spacer()

            Circle()
                .fill(appState.isRecording ? .red : .green)
                .frame(width: 12, height: 12)
                .shadow(radius: 8)
                .accessibilityLabel(appState.isRecording ? "Recording armed" : "Tracking ready")
        }
    }
}

private struct ControlDeck: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ForEach(MaskStyle.allCases) { style in
                    Button {
                        appState.selectedMask = style
                        appState.statusText = "Mask style: \(style.rawValue)"
                    } label: {
                        Text(style.rawValue)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(appState.selectedMask == style ? .orange : .white.opacity(0.13))
                            .foregroundStyle(appState.selectedMask == style ? .black : .white)
                            .clipShape(Capsule())
                    }
                }
            }

            Button {
                appState.toggleRecording()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: appState.isRecording ? "stop.fill" : "record.circle")
                    Text(appState.isRecording ? "Stop Preview Recording" : "Arm Recording UI")
                }
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(appState.isRecording ? .red : .white)
                .foregroundStyle(appState.isRecording ? .white : .black)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct UnsupportedDeviceView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "faceid")
                .font(.system(size: 52))
                .foregroundStyle(.orange)

            Text("TrueDepth camera required")
                .font(.title2.bold())

            Text("Run Facezero on a real Face ID iPhone. The simulator and non-TrueDepth devices cannot provide AR face tracking.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.72))
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .foregroundStyle(.white)
    }
}
