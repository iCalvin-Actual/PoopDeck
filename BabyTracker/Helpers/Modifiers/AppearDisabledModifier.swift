//
//  DisableViewModifier.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// Stardard SwiftUI `.disable` prevents user action, but doesn't have any visual effect
struct AppearDisabledModifier: ViewModifier {
    let disabled: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(disabled ? 0.3 : 1)
    }
}
