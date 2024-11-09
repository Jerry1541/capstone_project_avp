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
    var metadata: GroupActivityMetadata {
            var metadata = GroupActivityMetadata()
            metadata.title = "Cross Together"
            metadata.subtitle = "Watch vehicles"
            metadata.previewImage = UIImage(named: "ActivityImage")?.cgImage
            metadata.type = .exploreTogether
            return metadata
        }
    
}
