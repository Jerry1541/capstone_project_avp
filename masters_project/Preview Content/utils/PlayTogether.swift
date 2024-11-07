//
//  PlayTogether.swift
//  masters_project
//
//  Created by AK Puvvada on 11/7/24.
//

import Foundation
import GroupActivities
import UIKit

struct PlayTogether: GroupActivity {
    
    static let activityIdentifier = "com.example.apple-avp_sample.Watch.CrossTogether"
    
    var metadata: GroupActivityMetadata {
            var metadata = GroupActivityMetadata()
            metadata.title = "Cross Together"
            metadata.subtitle = "Watch vehicles"
            metadata.previewImage = UIImage(named: "ActivityImage")?.cgImage
            metadata.type = .shopTogether
            return metadata
        }
    
}
