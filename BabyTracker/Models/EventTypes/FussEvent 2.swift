//
//  FussEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

struct FussEvent: MeasuredBabyEvent {
    var type: BabyEventType = .fuss
    static var new: FussEvent {
        return FussEvent()
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var measurement: Measurement<UnitDuration>?
}
