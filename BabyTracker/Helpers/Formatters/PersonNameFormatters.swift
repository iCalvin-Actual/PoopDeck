//
//  PersonNameFormatters.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension PersonNameComponentsFormatter {
    
    /// Standard, empty formatter to return components from a name string
    static var decoding: PersonNameComponentsFormatter {
        let formatter = PersonNameComponentsFormatter()
        return formatter
    }
    static var short: PersonNameComponentsFormatter {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .short
        return formatter
    }
    static var abbreviated: PersonNameComponentsFormatter {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        return formatter
    }
}
