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

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
        .task {
//            for await session in PlayTogether.sessions() {
//                guard let systemCoordinator = await session.systemCoordinator else { continue }
//                    var configuration = SystemCoordinator.Configuration()
//                    configuration.supportsGroupImmersiveSpace = true
//                    systemCoordinator.configuration = configuration
//                    session.join()
//            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
