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
    
    var measurement: Measurement<Unit>?
}

struct TummyTimeEventOld: Codable {
    var type: BabyEventType = .tummyTime
    static var new: TummyTimeEvent {
        return TummyTimeEvent()
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var duration: Double
}

extension TummyTimeEvent {
    static var defaultMeasurement: Measurement<UnitDuration> {
        return Measurement(value: 3.0, unit: defaultUnit as! UnitDuration)
    }
}
