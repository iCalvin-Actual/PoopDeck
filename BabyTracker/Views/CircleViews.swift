//
//  CircleViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct ThemeColorView: View {
    let theme: ThemeColor
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(
                    theme.colorValue)
            
            /// Stacking a semi-transparent system backgroud enables 'dark mode' versions
            Circle()
                .foregroundColor(Color(UIColor.tertiarySystemBackground.withAlphaComponent(0.4)))
        }
    }
}

struct CircleViews_Previews: PreviewProvider {
    static var previews: some View {
        /// Show all the pre-built values in light and dark modes
        HStack {
            VStack {
                ForEach(ThemeColor.prebuiltSet, id: \.self) { color in
                    ThemeColorView(theme: color)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
            
            VStack {
                ForEach(ThemeColor.prebuiltSet, id: \.self) { color in
                    ThemeColorView(theme: color)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
        }
    }
}
