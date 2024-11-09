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

@MainActor
class Canvas: ObservableObject {
    func configureGroupSession(_ groupSession: GroupSession<PlayTogether>) {
        
        print("in here")
        print(groupSession.$activeParticipants)
    }
}
