//
//  Item.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 22/11/25.
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
