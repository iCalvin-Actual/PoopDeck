//
//  MeasuredBabyEvent_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension MeasuredBabyEvent {
    static var defaultUnit: Unit {
        switch self.type {
        case .feed:
            return Locale.current.usesMetricSystem ? UnitVolume.milliliters : UnitVolume.fluidOunces
        case .nap, .tummyTime:
            return UnitDuration.minutes
        case .weight:
            return Locale.current.usesMetricSystem ? UnitMass.kilograms : UnitMass.pounds
        default:
            return UnitArea.squareCentimeters
        }
    }
    static var defaultMeasurement: Measurement<Unit> {
        switch type {
        case .feed:
            return Measurement(value: 4.0, unit: defaultUnit)
        case .nap:
            return Measurement(value: 30.0, unit: defaultUnit)
        case .tummyTime:
            return Measurement(value: 3.0, unit: defaultUnit)
        case .weight:
            return Measurement(value: 10.0, unit: defaultUnit)
        default:
            return Measurement(value: 0.0, unit: defaultUnit)
        }
    }
}
