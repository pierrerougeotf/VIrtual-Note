//
//  ContentView.swift
//  VIrtual Note
//
//  Created by Pierre Rougeot on 14/09/2024.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
