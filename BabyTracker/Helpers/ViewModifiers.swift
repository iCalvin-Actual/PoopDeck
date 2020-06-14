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

struct ShadowModifier: ViewModifier {
    var show: Bool = true
    var radius: CGFloat = 8.0
    
    func body(content: Content) -> some View {
        addShadowIfNeeded(content)
    }
    
    func addShadowIfNeeded(_ content: Content) -> AnyView {
        guard show else { return content.anyPlease() }
        return content.shadow(radius: radius).anyPlease()
    }
}
extension View {
    func withShadowPlease(_ show: Bool = true, radius: CGFloat = 8.0) -> some View {
        return self.modifier(ShadowModifier(show: show, radius: radius))
    }
}

struct RaisedButtonStyleModifier: ViewModifier {
    var color: Color
    var padding: CGFloat
    func body(content: Content) -> some View {
        content
        .padding(padding)
        .background(color)
        .accentColor(.primary)
        .cornerRadius(21)
        .withShadowPlease()
    }
}
extension View {
    func raisedButtonPlease(_ overrideColor: Color? = nil, padding: CGFloat = 14.0) -> some View {
        return self.modifier(
            RaisedButtonStyleModifier(
//            color: overrideColor ?? Color(UIColor(named: "PDSecondary") ?? .tertiarySystemBackground),
                color: overrideColor ?? Color(.systemBackground),
                padding: padding
            )
        )
    }
}

extension View {
    func anyPlease() -> AnyView  {
        AnyView(self)
    }
}

