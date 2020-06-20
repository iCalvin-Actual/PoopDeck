//
//  MeasurementFormatters.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension MeasurementFormatter {
    
    /// Show measured events values in the LogView
    static var natural: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.locale = .autoupdatingCurrent
        measurementFormatter.unitOptions = [.naturalScale]
        measurementFormatter.unitStyle = .medium
        return measurementFormatter
    }
}
