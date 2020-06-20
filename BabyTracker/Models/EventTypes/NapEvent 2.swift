//
//  NapEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

struct NapEvent: MeasuredBabyEvent {
    var type: BabyEventType = .nap
    static var new: NapEvent {
        return NapEvent()
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var measurement: Measurement<Unit>?
}

struct NapEventOld: Codable {
    var type: BabyEventType = .nap
    static var new: NapEvent {
        return NapEvent()
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var duration: Double
}

extension NapEvent {
    static var defaultMeasurement: Measurement<Unit> {
        return Measurement(value: 30.0, unit: defaultUnit as! UnitDuration)
    }
}
