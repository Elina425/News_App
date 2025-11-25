//
//  Item.swift
//  news_app_ios
//
//  Created by Elina Melkonyan on 25.11.25.
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
