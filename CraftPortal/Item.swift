//
//  Item.swift
//  CraftPortal
//
//  Created by Larry Zeng on 8/25/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
