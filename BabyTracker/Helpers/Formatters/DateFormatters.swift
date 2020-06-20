//
//  DateFormatters.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    /// Shown in Conflict Resolution view to give full date to versions
    static var shortDateTime: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    
    /// Current date display in LogView
    static var shortDate: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    /// Current hour for time picker
    static var hour: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    /// Current minute for time picker
    static var minute: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    /// Current am/pm status for time picker
    static var ampm: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
}
