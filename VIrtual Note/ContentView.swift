//
//  ContentView.swift
//  VIrtual Note
//
//  Created by Pierre Rougeot on 14/09/2024.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
            Button("Open New Window") {
                openWindow(id: "text-editor")
            }
            Button("Open player") {
                openWindow(id: "tutorial")
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
