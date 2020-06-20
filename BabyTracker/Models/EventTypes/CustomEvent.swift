//
//  CustomEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

struct CustomEvent: BabyEvent {
    static var type: BabyEventType = .custom
    static var new: CustomEvent {
        return CustomEvent(event: "")
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var event: String
    var detail: String?
}

extension CustomEvent: Hashable {
    
}
