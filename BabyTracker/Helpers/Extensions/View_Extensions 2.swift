//
//  View_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// ViewConstructors in SwiftUI can't use variables or complex logic, any view that requires non-trivial preparation (like a `guard let` check).
/// You may instead explicitely return an `AnyView`in a computed variable or function
/// Extension makes it super easy to cast `some View` into `AnyView`
/// Manners act as namespace for easy searching
extension View {
    func anyPlease() -> AnyView {
        return AnyView(self)
    }
}

// MARK: - Modifiers

/// Sets the navigation bar to hidden and gives an empty title
extension View {
    func hideNavBarPlease() -> some View {
        return self.modifier(HideNavBarModifier())
    }
}

/// Forces grouped style on Compact width devices
extension View {
    func groupedStylePlease() -> some View {
        return self.modifier(ForceGroupedStyleModifier())
    }
}

/// Styles for floating buttons
extension View {
    func floatingPlease(_ overrideColor: Color? = nil, padding: CGFloat = 14.0) -> some View {
        return self.modifier(
            FloatingModifier(
                color: overrideColor ?? Color(.systemBackground),
                padding: padding
            )
        )
    }
}
extension View {
    func withShadowPlease(_ show: Bool = true, radius: CGFloat = 8.0) -> some View {
        return self.modifier(ShadowModifier(show: show, radius: radius))
    }
}

/// Default .disabled in swiftUI doesn't change the visual style. This adds some opacity to the value if disabled
extension View {
    func appearDisabledPlease(_ disabled: Bool = false) -> some View {
        return self.modifier(AppearDisabledModifier(disabled: disabled))
    }
}
