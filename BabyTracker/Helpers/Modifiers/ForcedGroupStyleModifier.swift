//
//  ForcedGroupStyleModifier.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// By default Grouped table style not available on iPhone. Force horizontal size class
struct ForceGroupedStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
    }
}

