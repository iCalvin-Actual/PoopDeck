//
//  HavNavBarModifier.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
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
