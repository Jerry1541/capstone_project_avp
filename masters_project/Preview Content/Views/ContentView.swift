//
//  ContentView.swift
//  masters_project
//
//  Created by AK Puvvada on 11/5/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GroupActivities

struct ContentView: View {

    @Environment(AppModel.self) private var appMode
    @ObservedObject var playGround: PlayGround
    @StateObject var groupStateObserver = GroupStateObserver()

    var body: some View {
        VStack {
            VStack {
                Text("Masters Project")
            }
            HStack {
                if playGround.groupSession == nil && groupStateObserver.isEligibleForGroupSession {
                    Button("SharePlay", systemImage: "shareplay") {
                        playGround.startActivity()
                    }
                }
                Spacer()
            }
            Text(appMode.debugLog)

            ToggleImmersiveSpaceButton()
        }.task {
            playGround.configureGroupSession()
        }
        .task {
            playGround.registerActivity()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(playGround: PlayGround())
        .environment(AppModel())
}
