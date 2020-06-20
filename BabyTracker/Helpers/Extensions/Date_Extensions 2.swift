//
//  DateExtensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

// MARK: - Date
extension Date {
    
    /// Defaule option for new baby birthday in BabyForm
    static var oneWeekAgo: Date {
        return apply(DateComponents(
            calendar: .current,
            timeZone: .current,
            day: -7))
    }
    
    /// Single place to apply components keeps logic consistent
    static func apply(_ components: DateComponents, to date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }
}
