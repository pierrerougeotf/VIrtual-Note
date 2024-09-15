//
//  VIrtual_NoteApp.swift
//  VIrtual Note
//
//  Created by Pierre Rougeot on 14/09/2024.
//

import SwiftUI
import ARKit

@main
struct VIrtual_NoteApp: App {

    @State private var appModel = AppModel()
    @State private var avPlayerViewModel = AVPlayerViewModel()
    @State private var showObjectTracking = true
    @State private var appState = AppState()
    
    @State private var arkitSession = ARKitSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .task {
                    if appState.allRequiredProvidersAreSupported {
                        await appState.referenceObjectLoader.loadBuiltInReferenceObjects()
                    }
                }
        }
        .defaultSize(CGSize(width: 80, height: 30))

        WindowGroup(id: "text-editor") {
            TextEditingView()
        }

        WindowGroup("tutorial", id: "tutorial") {
            AVPlayerView(viewModel: avPlayerViewModel)
//                .onAppear() {
//                    avPlayerViewModel.play(.step1)
//                }
//                .onDisappear {
//                    avPlayerViewModel.play()
//                }

        }

        WindowGroup("Main Content", id: "mainContent") {
            MainContentView(avPlayerViewModel: $avPlayerViewModel, showObjectTracking: $showObjectTracking)
                .padding()
        }
        .defaultSize(CGSize(width: 450, height: 1000))
        

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            if showObjectTracking {
                ObjectTrackingRealityView(appState: appState, arkitSession: $arkitSession)
            }
            ImmersiveView(arkitSession: $arkitSession)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
//        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }

    private func detectBarCodes() {
        
    }
}

struct TextEditingView: View {
    @State private var fullText: String = "This is some editable text..."


    var body: some View {
        TextEditor(text: $fullText)
            .padding()
    }
}
