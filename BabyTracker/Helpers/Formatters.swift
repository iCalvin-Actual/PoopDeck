//
//  Formatters.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

// MARK: - Date Formatter
extension DateFormatter {
    static var shortDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    static var shortDateDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    static var shortTimeDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    static var hourFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    static var minuteFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    static var ampmFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
}

// MARK: - Date Components
extension DateComponentsFormatter {
    static var durationDisplay: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return formatter
    }
}

// MARK: - Measurement Formatter
extension MeasurementFormatter {
    static var defaultFormatter: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.locale = .autoupdatingCurrent
        measurementFormatter.unitOptions = [.providedUnit]
        measurementFormatter.unitStyle = .short
        return measurementFormatter
    }
}

// MARK: Person Name Components
extension PersonNameComponentsFormatter {
    static var decodingFormatter: PersonNameComponentsFormatter {
        let formatter = PersonNameComponentsFormatter()
        return formatter
    }
    static var shortNameFormatter: PersonNameComponentsFormatter {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .short
        return formatter
    }
    static var initialFormatter: PersonNameComponentsFormatter {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        return formatter
    }
}
