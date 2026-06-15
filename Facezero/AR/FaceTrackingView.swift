import SwiftUI
import ARKit
import SceneKit

struct FaceTrackingView: UIViewRepresentable {
    let maskStyle: MaskStyle

    func makeCoordinator() -> Coordinator {
        Coordinator(maskStyle: maskStyle)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.delegate = context.coordinator
        view.automaticallyUpdatesLighting = true
        view.rendersContinuously = true
        view.scene = SCNScene()

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.maskStyle = maskStyle
        context.coordinator.applyCurrentStyle()
    }

    final class Coordinator: NSObject, ARSCNViewDelegate {
        var maskStyle: MaskStyle
        weak var faceNode: SCNNode?
        weak var sampleNode: SCNNode?

        init(maskStyle: MaskStyle) {
            self.maskStyle = maskStyle
        }

        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let device = renderer.device,
                  anchor is ARFaceAnchor,
                  let geometry = ARSCNFaceGeometry(device: device) else {
                return nil
            }

            let node = SCNNode(geometry: geometry)
            let sample = SampleCharacterMask.makeNode()
            node.addChildNode(sample)

            faceNode = node
            sampleNode = sample
            applyCurrentStyle()
            return node
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor,
                  let geometry = node.geometry as? ARSCNFaceGeometry else {
                return
            }

            geometry.update(from: faceAnchor.geometry)
            applyBlendShapeFeedback(faceAnchor.blendShapes, on: node)
        }

        func applyCurrentStyle() {
            applyMaterial(to: faceNode)
            sampleNode?.isHidden = maskStyle != .sampleHood
        }

        func applyMaterial(to node: SCNNode?) {
            guard let material = node?.geometry?.firstMaterial else { return }
            material.lightingModel = .physicallyBased
            material.isDoubleSided = true

            switch maskStyle {
            case .cleanMesh:
                material.diffuse.contents = UIColor.white.withAlphaComponent(0.20)
                material.emission.contents = UIColor.orange.withAlphaComponent(0.15)
                material.metalness.contents = 0.0
                material.roughness.contents = 0.45
                material.transparency = 0.42
            case .shadow:
                material.diffuse.contents = UIColor.black.withAlphaComponent(0.72)
                material.emission.contents = UIColor.black
                material.metalness.contents = 0.1
                material.roughness.contents = 0.8
                material.transparency = 0.82
            case .oracle:
                material.diffuse.contents = UIColor.darkGray.withAlphaComponent(0.66)
                material.emission.contents = UIColor.cyan.withAlphaComponent(0.2)
                material.metalness.contents = 0.2
                material.roughness.contents = 0.38
                material.transparency = 0.78
            case .sampleHood:
                material.diffuse.contents = UIColor.black.withAlphaComponent(0.08)
                material.emission.contents = UIColor.clear
                material.metalness.contents = 0.0
                material.roughness.contents = 0.9
                material.transparency = 0.08
            }
        }

        private func applyBlendShapeFeedback(_ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber], on node: SCNNode) {
            let jawOpen = blendShapes[.jawOpen]?.floatValue ?? 0
            let cheekPuff = blendShapes[.cheekPuff]?.floatValue ?? 0
            let scaleBoost = 1 + (jawOpen * 0.025) + (cheekPuff * 0.015)
            node.scale = SCNVector3(scaleBoost, scaleBoost, scaleBoost)
        }
    }
}

private enum SampleCharacterMask {
    static func makeNode() -> SCNNode {
        let root = SCNNode()
        root.name = "sample_character_mask"

        let hood = SCNSphere(radius: 0.118)
        hood.segmentCount = 32
        hood.firstMaterial = material(
            diffuse: UIColor(red: 0.015, green: 0.018, blue: 0.024, alpha: 0.92),
            emission: UIColor(red: 0.02, green: 0.025, blue: 0.04, alpha: 1),
            roughness: 0.82
        )
        let hoodNode = SCNNode(geometry: hood)
        hoodNode.name = "dark_hood"
        hoodNode.position = SCNVector3(0, 0.015, 0.006)
        hoodNode.scale = SCNVector3(1.08, 1.18, 0.78)
        root.addChildNode(hoodNode)

        let faceCutout = SCNSphere(radius: 0.092)
        faceCutout.segmentCount = 32
        faceCutout.firstMaterial = material(
            diffuse: UIColor(red: 0.05, green: 0.038, blue: 0.030, alpha: 0.86),
            emission: UIColor(red: 0.025, green: 0.015, blue: 0.010, alpha: 1),
            roughness: 0.72
        )
        let facePlate = SCNNode(geometry: faceCutout)
        facePlate.name = "warm_face_plate"
        facePlate.position = SCNVector3(0, 0.005, 0.052)
        facePlate.scale = SCNVector3(0.82, 1.02, 0.18)
        root.addChildNode(facePlate)

        let shoulders = SCNCapsule(capRadius: 0.075, height: 0.32)
        shoulders.radialSegmentCount = 24
        shoulders.firstMaterial = material(
            diffuse: UIColor(red: 0.018, green: 0.020, blue: 0.026, alpha: 0.95),
            emission: UIColor.black,
            roughness: 0.88
        )
        let shoulderNode = SCNNode(geometry: shoulders)
        shoulderNode.name = "upper_shoulder_collar"
        shoulderNode.position = SCNVector3(0, -0.145, -0.01)
        shoulderNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        shoulderNode.scale = SCNVector3(1.35, 0.60, 0.42)
        root.addChildNode(shoulderNode)

        let collar = SCNTorus(ringRadius: 0.070, pipeRadius: 0.012)
        collar.ringSegmentCount = 36
        collar.pipeSegmentCount = 12
        collar.firstMaterial = material(
            diffuse: UIColor(red: 0.95, green: 0.45, blue: 0.06, alpha: 0.95),
            emission: UIColor(red: 0.18, green: 0.06, blue: 0.0, alpha: 1),
            roughness: 0.35
        )
        let collarNode = SCNNode(geometry: collar)
        collarNode.name = "orange_neck_collar"
        collarNode.position = SCNVector3(0, -0.085, 0.025)
        collarNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        root.addChildNode(collarNode)

        root.addChildNode(eyeGlow(x: -0.032))
        root.addChildNode(eyeGlow(x: 0.032))

        let brow = SCNBox(width: 0.090, height: 0.010, length: 0.014, chamferRadius: 0.004)
        brow.firstMaterial = material(
            diffuse: UIColor(red: 0.95, green: 0.45, blue: 0.06, alpha: 0.85),
            emission: UIColor(red: 0.22, green: 0.07, blue: 0.0, alpha: 1),
            roughness: 0.32
        )
        let browNode = SCNNode(geometry: brow)
        browNode.name = "sample_brow_bar"
        browNode.position = SCNVector3(0, 0.040, 0.083)
        root.addChildNode(browNode)

        return root
    }

    private static func eyeGlow(x: Float) -> SCNNode {
        let eye = SCNSphere(radius: 0.010)
        eye.segmentCount = 16
        eye.firstMaterial = material(
            diffuse: UIColor.cyan,
            emission: UIColor.cyan,
            roughness: 0.18
        )
        let node = SCNNode(geometry: eye)
        node.name = x < 0 ? "left_eye_glow" : "right_eye_glow"
        node.position = SCNVector3(x, 0.020, 0.087)
        return node
    }

    private static func material(diffuse: UIColor, emission: UIColor, roughness: CGFloat) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = diffuse
        material.emission.contents = emission
        material.roughness.contents = roughness
        material.metalness.contents = 0.05
        material.isDoubleSided = true
        return material
    }
}
