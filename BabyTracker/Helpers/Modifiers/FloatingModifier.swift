//
//  RaisedButtonStyleModifier.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct FloatingModifier: ViewModifier {
    var color: Color
    var padding: CGFloat
    func body(content: Content) -> some View {
        content
        .padding(padding)
        .background(color)
        .accentColor(.primary)
        .cornerRadius(22)
        .withShadowPlease()
    }
}
