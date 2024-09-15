//
//  ImmersiveView.swift
//  VIrtual Note
//
//  Created by Pierre Rougeot on 14/09/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import Combine

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @State private var root = Entity()
    @State private var arkitSession = ARKitSession()
    @State private var fadeCompleteSubscriptions: Set<AnyCancellable> = []

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            //            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
            content.add(root)
            //            }
        }
        .task {
            // Check if barcode detection is supported; otherwise handle this case.
            guard BarcodeDetectionProvider.isSupported else { return }

            // Spatial barcode & QR code scanning example

            await arkitSession.queryAuthorization(for: [.worldSensing])

            let barcodeDetection = BarcodeDetectionProvider(symbologies: [.code39, .qr, .upce])

            do {
                try await arkitSession.run([barcodeDetection])
            } catch {
                return
            }

            for await anchorUpdate in barcodeDetection.anchorUpdates {
                switch anchorUpdate.event {
                case .added:
                    // Call our app method to add a box around a new barcode
                    playAnimation(for: anchorUpdate.anchor)
//                    if let payloadString = anchorUpdate.anchor.payloadString {
//                        let string = "shortcuts://run-shortcut?name=VisionNote&input=text&text=\(payloadString)"
//                        await UIApplication.shared.open(URL(string: string)!)
//                    }
                case .updated:
                    // Call our app method to move a barcode's box
                    //                        playAnimation(for: anchorUpdate.anchor)
                    break
                case .removed:
                    // Call our app method to remove a barcode's box
                    //                        playAnimation(for: anchorUpdate.anchor)
                    break
                }
            }
        }
    }

    func playAnimation(for anchor: BarcodeAnchor) {
        guard let scene = root.scene else { return }

        // Create a plane sized to match the barcode.
        let extent = anchor.extent
        let entity = ModelEntity(mesh: .generatePlane(width: extent.x, depth: extent.z), materials: [UnlitMaterial(color: .green)])
        entity.components.set(OpacityComponent(opacity: 0.5))

        // Position the plane over the barcode.
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
        root.addChild(entity)

        // Fade the plane in and out.
//        do {
//            let duration = 0.5
//            let fadeIn = try AnimationResource.generate(with: FromToByAnimation<Float>(
//                from: 0,
//                to: 1.0,
//                duration: duration,
//                isAdditive: true,
//                bindTarget: .opacity)
//            )
//            let fadeOut = try AnimationResource.generate(with: FromToByAnimation<Float>(
//                from: 1.0,
//                to: 0,
//                duration: duration,
//                isAdditive: true,
//                bindTarget: .opacity))
//
//            let fadeAnimation = try AnimationResource.sequence(with: [fadeIn, fadeOut])
//
//            _ = scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: entity, { _ in
//                // Remove the plane after the animation completes.
//                entity.removeFromParent()
//            }).store(in: &fadeCompleteSubscriptions)
//
//            entity.playAnimation(fadeAnimation)
//        } catch {
//            // Handle the error.
//        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
