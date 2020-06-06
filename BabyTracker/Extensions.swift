//
//  Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Foundation

extension DateFormatter {
    static var timeDisplay: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
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

