//
//  Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

extension DateFormatter {
    static var timeDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    static var shortDateDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
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
    static var shortDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    static var shortStackDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "M/d\nh:mm a"
        return formatter
    }()
}
class TickPublisher {
    let currentTimePublisher = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)
    let cancellable: AnyCancellable?

    init() {
        self.cancellable = currentTimePublisher.connect() as? AnyCancellable
    }

    deinit {
        self.cancellable?.cancel()
    }
}
extension DateComponentsFormatter {
    static var durationDisplay: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return formatter
    }
}
extension MeasurementFormatter {
    static var defaultFormatter: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.locale = .autoupdatingCurrent
        measurementFormatter.unitOptions = [.providedUnit]
        measurementFormatter.unitStyle = .short
        return measurementFormatter
    }
    static var weightFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .medium
        formatter.numberFormatter = .weightEntryFormatter
        return formatter
    }
}
extension NumberFormatter {
    static var weightEntryFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        return formatter
    }
}

extension View {
    func anyify() -> AnyView {
        return AnyView(self)
    }
}

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

extension NSFileVersion {
    var personDisplayName: String? {
        guard let components = self.originatorNameComponents else { return nil }
        return PersonNameComponentsFormatter.shortNameFormatter.string(from: components)
    }
    var deviceDisplayName: String? {
        return self.localizedNameOfSavingComputer
    }
}

extension Unit {
    var defaultValue: Double? {
        switch symbol {
        case "mL":
            return 120.0
        case "fl oz":
            return 3.0
        case "s":
            return 60
        case "min":
            return 5
        case "h":
            return 1
        case "lb":
            return 10
        default:
            return nil
        }
    }
    var modifier: Double? {
        switch symbol {
        case "mL":
            return 10.0
        case "fl oz":
            return 0.25
        case "s":
            return 60
        case "min":
            return 5
        case "h":
            return 0.25
        case "lb":
            return 0.10
        default:
            return nil
        }
    }
}

extension UnitVolume {
    static var supported: [UnitVolume] {
        return [
            .milliliters,
            .fluidOunces
        ]
    }
}

extension UnitMass {
    static var supported: [UnitMass] {
        return [
            .kilograms,
            .pounds
        ]
    }
}

extension UnitDuration {
    static var supported: [UnitDuration] {
        return [
            .hours,
            .minutes
        ]
    }
}

