//
//  VIrtual_NoteApp.swift
//  VIrtual Note
//
//  Created by Pierre Rougeot on 14/09/2024.
//

import SwiftUI

@main
struct VIrtual_NoteApp: App {

    @State private var appModel = AppModel()
    @State private var avPlayerViewModel = AVPlayerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        WindowGroup(id: "text-editor") {
            TextEditingView()
        }

        WindowGroup("tutorial", id: "tutorial") {
            AVPlayerView(viewModel: avPlayerViewModel)
                .onAppear() {
                    avPlayerViewModel.play(.step1)
                }
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
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
