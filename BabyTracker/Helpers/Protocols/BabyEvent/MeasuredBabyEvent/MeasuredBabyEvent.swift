//
//  MeasuredBabyEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// Shared components for events with an associated measurement
protocol MeasuredBabyEvent: BabyEvent {
    
    /// Initial value to use when adding a measurement. Should be a reasonable starting point for a new-ish baby in all measures
    static var defaultMeasurement: Measurement<Unit> { get }
    
    /// The active measurement for this event. Nil is allowed, since some events measurements are optional. Arguably Weight is the only one that really demands a non-nil value, but that can be covered up in UI
    var measurement: Measurement<Unit>? { get set }
}
