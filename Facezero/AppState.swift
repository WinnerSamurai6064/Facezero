import Foundation

enum MaskStyle: String, CaseIterable, Identifiable {
    case cleanMesh = "Mesh"
    case shadow = "Shadow"
    case oracle = "Oracle"
    case sampleHood = "Sample"

    var id: String { rawValue }
}

@MainActor
final class AppState: ObservableObject {
    @Published var selectedMask: MaskStyle = .sampleHood
    @Published var isRecording = false
    @Published var statusText = "Sample character mask ready"

    func toggleRecording() {
        isRecording.toggle()
        statusText = isRecording ? "Recording UI armed — export wiring comes next" : "Recording stopped"
    }
}
