//
//  ViewModifiers.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// Hide Nav Bar, two step process
struct HideNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}
extension View {
    func hideNavBarPlease() -> some View {
        return self.modifier(HideNavBarModifier())
    }
}

/// By default Grouped table style not available on iPhone. Force horizontal size class
struct ForceGroupedStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
    }
}
extension View {
    func groupedStylePlease() -> some View {
        return self.modifier(ForceGroupedStyleModifier())
    }
}

extension View {
    func anyPlease() -> AnyView  {
        AnyView(self)
    }
}

