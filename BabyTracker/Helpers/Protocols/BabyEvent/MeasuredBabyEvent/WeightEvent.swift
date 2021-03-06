//
//  WeightEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

struct WeightEvent: MeasuredBabyEvent {
    static var type: BabyEventType = .weight
    static var new: WeightEvent {
        return WeightEvent(measurement: Measurement.init(value: 4.5, unit: UnitMass.kilograms))
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var measurement: Measurement<Unit>?
}
