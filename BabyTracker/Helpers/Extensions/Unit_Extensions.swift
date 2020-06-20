//
//  Unit_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension Unit {
    
    /// How much to adjust the value when the user increments the picker
    var modifier: Double {
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
            return 0.1
        default:
            return 0
        }
    }
    
    /// Default value to use when adding a new measurement
    var defaultValue: Double {
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
            return 0
        }
    }
}
