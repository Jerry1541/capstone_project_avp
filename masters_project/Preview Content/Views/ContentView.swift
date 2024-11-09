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
                    Button("SharePlay", systemImage: "Play Together") {
                        playGround.startActivity()
                    }
                }
                
                Spacer()
            }
            Text(appMode.debugLog)

            ToggleImmersiveSpaceButton()
        }
        .task {
            appMode.debugLog += "window \n"
            for await session in PlayTogether.sessions() {
                guard let systemCoordinator = await session.systemCoordinator else { continue }
                    var configuration = SystemCoordinator.Configuration()
                    configuration.supportsGroupImmersiveSpace = true
                    systemCoordinator.configuration = configuration
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(playGround: PlayGround())
        .environment(AppModel())
}
