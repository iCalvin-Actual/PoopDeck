//
//  ShadowModifier.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct ShadowModifier: ViewModifier {
    var show: Bool = true
    var radius: CGFloat = 8.0
    
    func body(content: Content) -> some View {
        addShadowIfNeeded(content)
    }
    
    /// Using 0 as the radius when !show would be simpler, but has an odd effect
    func addShadowIfNeeded(_ content: Content) -> AnyView {
        guard show else { return content.anyPlease() }
        return content.shadow(radius: radius).anyPlease()
    }
}
