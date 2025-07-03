//
//  Item.swift
//  TrainIA
//
//  Created by Yago Alonso on 3/7/25.
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
