//
//  PreferredColor_Options.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension ThemeColor {
    /// Set of options comes from Pastel iOS app
    static var prebuiltSet: [ThemeColor] {
        return [
            ThemeColor(r: 0.537, g: 0.820, b: 0.863),
            ThemeColor(r: 0.973, g: 0.612, b: 0.980),
            ThemeColor(r: 0.765, g: 0.525, b: 0.945),
            ThemeColor(r: 0.941, g: 0.839, b: 0.537),
            ThemeColor(r: 0.686, g: 0.949, b: 0.545)
        ]
    }
    static var random: ThemeColor {
        return prebuiltSet.randomElement()!
    }
}

