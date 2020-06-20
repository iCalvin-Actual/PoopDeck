//
//  MeasuredBabyEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation
protocol MeasuredBabyEvent: BabyEvent {
    var measurement: Measurement<Unit>? { get set }
    static var defaultMeasurement: Measurement<Unit> { get }
}
