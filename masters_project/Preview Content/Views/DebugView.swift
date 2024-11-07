//
//  DebugView.swift
//  masters_project
//
//  Created by AK Puvvada on 11/7/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct DebugView: View {

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Debug window")

        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    DebugView()
        .environment(AppModel())
}
