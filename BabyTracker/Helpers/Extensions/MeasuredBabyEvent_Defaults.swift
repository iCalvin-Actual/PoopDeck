//
//  MeasuredBabyEvent_Defaults.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension FeedEvent {
    static var defaultMeasurement: Measurement<Unit> {
        return Measurement(
            value: Locale.current.usesMetricSystem ? 90.0 : 3.0,
            unit: defaultUnit
        )
    }
}
extension NapEvent {
    static var defaultMeasurement: Measurement<Unit> {
        return Measurement(
            value: 30.0,
            unit: defaultUnit
        )
    }
}
extension TummyTimeEvent {
    static var defaultMeasurement: Measurement<Unit> {
        return Measurement(
            value: 3.0, 
            unit: defaultUnit)
    }
}
extension WeightEvent {
    static var defaultMeasurement: Measurement<Unit> {
        return Measurement(
            value: Locale.current.usesMetricSystem ? 4.5 : 10.0,
            unit: defaultUnit
        )
    }
}
