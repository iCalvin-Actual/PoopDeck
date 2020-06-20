//
//  DiaperEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

struct DiaperEvent: BabyEvent {
    static var type: BabyEventType = .diaper
    static var new: DiaperEvent {
        return DiaperEvent()
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var pee: Bool = false
    var poop: Bool = false
}
