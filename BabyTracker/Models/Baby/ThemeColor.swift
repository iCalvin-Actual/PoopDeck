//
//  PreferredColor.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// Codable struct to hold the RGB values of a 'ThemeColor'
/// Ripe for refactoring
struct ThemeColor {
    let r, g, b: Double
    
    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }
    init(uicolor: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uicolor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.r = Double(r)
        self.g = Double(g)
        self.b = Double(b)
    }
    
    var colorValue: Color {
        return Color(red: r, green: g, blue: b)
    }
}

extension ThemeColor: Codable { }
extension ThemeColor: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(r)
        hasher.combine(g)
        hasher.combine(b)
    }
}
