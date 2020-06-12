//
//  PreferredColor.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct PreferredColor: Hashable {
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
    
    var color: Color {
        return Color(red: r, green: g, blue: b)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(r)
        hasher.combine(g)
        hasher.combine(b)
    }}

extension PreferredColor {
    static var prebuiltSet: [PreferredColor] {
        return [
            PreferredColor(r: 0, g: 0, b: 0),
            PreferredColor(r: 0, g: 0, b: 1),
            PreferredColor(r: 0, g: 1, b: 0),
            PreferredColor(r: 0, g: 1, b: 1),
            PreferredColor(r: 1, g: 0, b: 0),
            PreferredColor(r: 1, g: 0, b: 1),
            PreferredColor(r: 1, g: 1, b: 0)
        ]
    }
    static var random: PreferredColor {
        return prebuiltSet.randomElement()!
    }
}
extension PreferredColor: Codable { }

struct ColoredCircle: View {
    let color: PreferredColor
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(red: color.r, green: color.g, blue: color.b))
            
            Circle()
                .foregroundColor(Color(UIColor.tertiarySystemBackground.withAlphaComponent(0.75)))
        }
    }
}

struct ColoredCircle_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            VStack {
                ForEach(PreferredColor.prebuiltSet, id: \.self) { color in
                    ColoredCircle(color: color)
                }
            }
            .environment(\.colorScheme, .light)
            VStack {
                ForEach(PreferredColor.prebuiltSet, id: \.self) { color in
                    ColoredCircle(color: color)
                }
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
