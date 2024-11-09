//
//  ImmersiveView.swift
//  masters_project
//
//  Created by AK Puvvada on 11/5/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GroupActivities

struct ImmersiveView: View {

    @Environment(AppModel.self) private var appModel
    @ObservedObject var playGround: PlayGround

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
//        .task {
//            playGround.configureGroupSession()
//        }
//        .task {
//            playGround.registerActivity()
//        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(playGround: PlayGround())
        .environment(AppModel())
}
