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
    @State private var entity: Entity?
    @State private var first = true

    var body: some View {
        RealityView { content, attachments in
            content.add(root)
        } update: { _,
            attachments in
            if let attachment = attachments.entity(for: "barcode") {
                attachment.transform.rotation = simd_quatf(
                    Rotation3D(
                        eulerAngles: EulerAngles(
                            x: Angle2D(degrees: -90.0),
                            y: .zero,
                            z: .zero,
                            order: .xyz
                        )
                    )
                )
                attachment.position = [0.0, 0.0, -0.5]
                entity?.addChild(attachment)
            }
        } attachments: {
            Attachment(id: "barcode") {
                MainContentView()
                    .padding()
                    .glassBackgroundEffect()
                    .frame(width: 450, height: 1000)
//                button("Open") {
//                    
//                }
//                Text("Glass Cube")
//                    .font(.extraLargeTitle)
//                    .padding()
//                    .glassBackgroundEffect()
            }

        }
        .task {
            // Check if barcode detection is supported; otherwise handle this case.
            guard BarcodeDetectionProvider.isSupported else { return }

            // Spatial barcode & QR code scanning example

            await _ = arkitSession.queryAuthorization(for: [.worldSensing])

            let barcodeDetection = BarcodeDetectionProvider(symbologies: [.code39, .qr, .upce, .ean8, .ean13])

            do {
                try await arkitSession.run([barcodeDetection])
            } catch {
                return
            }

            for await anchorUpdate in barcodeDetection.anchorUpdates {
                switch anchorUpdate.event {
                case .added:
                    // Call our app method to add a box around a new barcode
                    update(anchorUpdate.anchor)
//                    if let payloadString = anchorUpdate.anchor.payloadString {
//                        let string = "shortcuts://run-shortcut?name=VisionNote&input=text&text=\(payloadString)"
//                        await UIApplication.shared.open(URL(string: string)!)
//                    }
                case .updated:
                    // Call our app method to move a barcode's box
                    update(anchorUpdate.anchor)
                case .removed:
                    // Call our app method to remove a barcode's box
                    //                        playAnimation(for: anchorUpdate.anchor)
                    break
                }
            }
        }
    }

    func update(_ anchor: BarcodeAnchor) {
        // Create a plane sized to match the barcode.
        let extent = anchor.extent
        let entity = self.entity
        ?? ModelEntity(mesh: .generatePlane(width: extent.x, depth: extent.z), materials: [UnlitMaterial(color: .green)])
        entity.components.set(OpacityComponent(opacity: 0.5))

        // Position the plane over the barcode.
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)

        if self.entity == nil {
            self.entity = entity
            root.addChild(entity)
        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
