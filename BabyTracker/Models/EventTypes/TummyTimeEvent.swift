//
//  TummyTimeEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

struct TummyTimeEvent: MeasuredBabyEvent {
    var type: BabyEventType = .tummyTime
    static var new: TummyTimeEvent {
        return TummyTimeEvent()
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var measurement: Measurement<UnitDuration>?
}
