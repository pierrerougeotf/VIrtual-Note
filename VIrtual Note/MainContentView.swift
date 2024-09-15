//
//  ContentView.swift
//  GreenNote
//
//  Created by Emmanuel Longere on 15/09/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct MainContentView: View {

    @State private var textNote: String = "Enter your note here"
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var videoStep: AVPlayerViewModel.Video?
    @Binding var avPlayerViewModel: AVPlayerViewModel

    var body: some View {
        ScrollView {

            Text("Orange Juice")
                .font(.largeTitle)
                .padding(.all, 40)

            VStack{

                VStack(alignment: .leading) {
                    HStack{
                        Image(systemName: "info.circle")
                        Text("About this")
                            .font(.title2)
                            .padding(.vertical, 10)
                    }
                    Text ("Composition : this orange juice is crafted from a combination of premium-quality orange juice concentrate and filtered water. There is no artificial flavors or colors, and a minimal amount of natural sugars and citric acid is added.  No preservatives, Vitamin C.")
                    Text ("Packaging : Inside the carton, a thin layer of polyethylene is applied to act as a moisture barrier, a layer of aluminum foil is also used to act as an oxygen and light barrier")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                VStack(alignment: .leading) {
                    HStack{
                        Image(systemName: "plus.circle")
                        Text("Note something about this")
                            .font(.title2)
                            .padding(.vertical, 10)
                    }
                    TextEditor(text: $textNote)
                        .frame(height: 100)
                    .padding()
                    .background(.thinMaterial)
                    .shadow(radius: 5)
                    .hoverEffect()
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                VStack(alignment: .leading) {
                    HStack{
                        Image(systemName: "leaf.arrow.triangle.circlepath")
                        Text("Recycle this")
                            .font(.title2)
                            .padding(.vertical, 10)
                    }

                    VStack(alignment: .center) {
                        Text("Green idea n°1")
                            .font(.title3)
                        Text("Recycle this into a bird feeder")
                        HStack{
//                            Image("OrangeJuice")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 100)
//                            Image("BirdFeeder")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 100)
                            Spacer()

                            Model3D(named: "OrangeJuiceModel.usdz", bundle: realityKitContentBundle) { model in
                                model
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding(.all, 20)
                            .background(.regularMaterial)
                            .hoverEffect()
                            .cornerRadius(20)

                            Image(systemName: "arrow.forward")

                            Model3D(named: "BirdFeederModel.usdz", bundle: realityKitContentBundle) { model in
                                model
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding(.all, 20)
                            .background(.regularMaterial)
                            .hoverEffect()
                            .cornerRadius(20)



                            Spacer()
                        }
                        .padding()
                        HStack {
//                            if videoStep?.previous != nil {
                                Button("Previous") {
                                    videoStep = videoStep?.previous
                                    avPlayerViewModel.play(videoStep)
                                    if videoStep == nil { dismissWindow(id: "tutorial") }
                                }
                                Spacer()
//                            }

                            Button(/* videoStep == nil ? "Start" :*/ "Next") {
                                if videoStep == nil { openWindow(id: "tutorial") }
                                videoStep = nextVideo
                                avPlayerViewModel.play(videoStep)
                                if videoStep == nil { dismissWindow(id: "tutorial") }
                            }
//                        Button(action: {
//                        }) {
//                            Text("Start")
//                                .frame(width: 200, height: 40)
                        }
                    }
                    .padding(.all, 5)
//                    .overlay {
//                    }
                    .padding()
                    .background(.regularMaterial)
                    .hoverEffect()
                    .cornerRadius(20)
                }
                .padding()
            }
            .padding()
        }
        .onChange(of: videoStep) {
        }
    }


    private var nextVideo: AVPlayerViewModel.Video? {
        videoStep == nil ? .step1 : videoStep?.next
    }
//
//    private var previousVideo: AVPlayerViewModel.Video? {
//        videoStep?.previous
//    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
