/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view shown inside the immersive space.
*/

import RealityKit
import ARKit
import SwiftUI

@MainActor
struct ObjectTrackingRealityView: View {
    var appState: AppState
    @Binding var arkitSession: ARKitSession
    var root = Entity()
    
    @State private var objectVisualizations: [UUID: ObjectAnchorVisualization] = [:]
    @State var cuttingEntity = Entity ()
    @State var isloaded : Bool = false
    
    
    var body: some View {
        RealityView { content, attachments in
            content.add(root)

            Task {
                let objectTracking = await appState.startTracking()
                guard let objectTracking else {
                    return
                }
                
                // Wait for object anchor updates and maintain a dictionary of visualizations
                // that are attached to those anchors.
                for await anchorUpdate in objectTracking.anchorUpdates {
                    let anchor = anchorUpdate.anchor
                    let id = anchor.id
                    
                    switch anchorUpdate.event {
                    case .added:
                        // Create a new visualization for the reference object that ARKit just detected.
                        // The app displays the USDZ file that the reference object was trained on as
                        // a wireframe on top of the real-world object, if the .referenceobject file contains
                        // that USDZ file. If the original USDZ isn't available, the app displays a bounding box instead.
                        let model = appState.referenceObjectLoader.usdzsPerReferenceObjectID[anchor.referenceObject.id]
                        let visualization = ObjectAnchorVisualization(for: anchor, withModel: model)
                        self.objectVisualizations[id] = visualization
                        root.addChild(visualization.entity)
                        
                        do{
                            if(isloaded == false)
                            {
                                print("loading cutting")
                                cuttingEntity = try! await Entity.init(named: "cutting.usdz")
                                isloaded = true
                            } else {
                                cuttingEntity.isEnabled = true
                            }
                        } catch {
                            fatalError("Failed to load model: \(error)")
                        }

                        cuttingEntity.position = visualization.entity.position
                        
                        root.addChild(cuttingEntity)
                        
                        if let attachmentText = attachments.entity(for: "TextLabel") {
                                  //4. Position the Attachment and add it to the RealityViewContent
                            attachmentText.position = [visualization.entity.position.x, visualization.entity.position.y + 30, visualization.entity.position.z]
                            attachmentText.transform.rotation =  visualization.entity.transform.rotation
                            attachmentText.scale = [50, 50, 50]
                            cuttingEntity.addChild(attachmentText)
                        }
                        
                        
                    case .updated:
                        objectVisualizations[id]?.update(with: anchor)
                        cuttingEntity.position = (objectVisualizations[id]?.entity.position)!
                        cuttingEntity.transform.rotation = (objectVisualizations[id]?.entity.transform.rotation)!
                    case .removed:
                        objectVisualizations[id]?.entity.removeFromParent()
                        objectVisualizations.removeValue(forKey: id)
                        cuttingEntity.isEnabled = false
                    }
                }
            }
        }
        update: { content, attachments in
        }
        attachments: {
            
            Attachment(id: "TextLabel") {
                //2. Define the SwiftUI View
                Text("Cut here")
                    .font(.extraLargeTitle)
                    .padding()
                    .glassBackgroundEffect()
            }
        }
        .onAppear() {
            print("Entering immersive space.")
            appState.isImmersiveSpaceOpened = true
        }
        .onDisappear() {
            print("Leaving immersive space.")
            
            for (_, visualization) in objectVisualizations {
                root.removeChild(visualization.entity)
            }
            objectVisualizations.removeAll()
            
            appState.didLeaveImmersiveSpace()
        }
    }
}

