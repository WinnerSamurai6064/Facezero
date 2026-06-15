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
        context.coordinator.applyMaterial(to: context.coordinator.faceNode)
    }

    final class Coordinator: NSObject, ARSCNViewDelegate {
        var maskStyle: MaskStyle
        weak var faceNode: SCNNode?

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
            applyMaterial(to: node)
            addOracleEyes(to: node)
            faceNode = node
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
            }
        }

        private func addOracleEyes(to node: SCNNode) {
            let leftEye = makeEyeGlowNode()
            leftEye.position = SCNVector3(-0.032, 0.028, 0.055)

            let rightEye = makeEyeGlowNode()
            rightEye.position = SCNVector3(0.032, 0.028, 0.055)

            node.addChildNode(leftEye)
            node.addChildNode(rightEye)
        }

        private func makeEyeGlowNode() -> SCNNode {
            let sphere = SCNSphere(radius: 0.009)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.cyan
            material.emission.contents = UIColor.cyan
            sphere.firstMaterial = material
            return SCNNode(geometry: sphere)
        }

        private func applyBlendShapeFeedback(_ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber], on node: SCNNode) {
            let jawOpen = blendShapes[.jawOpen]?.floatValue ?? 0
            let cheekPuff = blendShapes[.cheekPuff]?.floatValue ?? 0
            let scaleBoost = 1 + (jawOpen * 0.025) + (cheekPuff * 0.015)
            node.scale = SCNVector3(scaleBoost, scaleBoost, scaleBoost)
        }
    }
}
