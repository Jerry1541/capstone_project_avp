//
//  PlayGroound.swift
//  masters_project
//
//  Created by AK Puvvada on 11/8/24.
//
import Foundation
import Combine
import SwiftUI
import GroupActivities
import LinkPresentation

@MainActor
class PlayGround: ObservableObject {
    @Published var groupSession: GroupSession<PlayTogether>?
    
    @Published var activityItemsConfiguration: UIActivityItemsConfiguration?
    
    func configureGroupSession(_ groupSession: GroupSession<PlayTogether>) {
        
        print("in here")
        print(groupSession.$activeParticipants)
    }
    
    func startActivity() {
        // Create the activity
        let activity = PlayTogether()

        // Register the activity on the item provider
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(activity)

        // Create the activity items configuration
        let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])

        // Provide the metadata for the group activity
        configuration.metadataProvider = { key in
            guard key == .linkPresentationMetadata else { return nil }
            let metadata = LPLinkMetadata()
            metadata.title = "Explore Together"
            metadata.imageProvider = NSItemProvider(object: UIImage(named: "explore-activity")!)
            return metadata
        }
        self.activityItemsConfiguration = configuration
        
//        Task {
//            do {
//                _ = try await PlayTogether().activate()
//            } catch {
//                print("Failed to activate Playtogether activity: \(error)")
//            }
//        }
    }
}
