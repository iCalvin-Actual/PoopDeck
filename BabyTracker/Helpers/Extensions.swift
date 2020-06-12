//
//  Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Date
extension Date {
    static var oneWeekAgo: Date {
        var components = Calendar.current
            .dateComponents([.weekOfYear], from: Date())
        components.weekOfYear! -= 1
        
        return apply(components)
    }
    
    static private func apply(_ components: DateComponents, to date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }
}

// MARK: - JSON
extension JSONDecoder {
    static var safe: JSONDecoder = {
        var decoder = JSONDecoder()
        return decoder
    }()
}
extension JSONEncoder {
    static var safe: JSONEncoder = {
        var encoder = JSONEncoder()
        return encoder
    }()
}

// MARK: - File Versions
extension NSFileVersion {
    var personDisplayName: String? {
        guard let components = self.originatorNameComponents else { return nil }
        return PersonNameComponentsFormatter.shortNameFormatter.string(from: components)
    }
    var deviceDisplayName: String? {
        return self.localizedNameOfSavingComputer
    }
}

// MARK: - Units
extension Unit {
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
        case "hr":
            return 0.25
        case "lb":
            return 0.10
        default:
            return nil
        }
    }
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
        case "hr":
            return 1
        case "lb":
            return 10
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

