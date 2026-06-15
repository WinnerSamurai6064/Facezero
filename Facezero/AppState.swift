import Foundation

enum MaskStyle: String, CaseIterable, Identifiable {
    case cleanMesh = "Mesh"
    case shadow = "Shadow"
    case oracle = "Oracle"

    var id: String { rawValue }
}

@MainActor
final class AppState: ObservableObject {
    @Published var selectedMask: MaskStyle = .cleanMesh
    @Published var isRecording = false
    @Published var statusText = "Ready for live face tracking"

    func toggleRecording() {
        isRecording.toggle()
        statusText = isRecording ? "Recording UI armed — export wiring comes next" : "Recording stopped"
    }
}
