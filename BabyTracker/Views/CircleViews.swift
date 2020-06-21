//
//  CircleViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct CircleViews: View {
    let color: ThemeColor
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(red: color.r, green: color.g, blue: color.b))
            
            Circle()
                .foregroundColor(Color(UIColor.tertiarySystemBackground.withAlphaComponent(0.4)))
        }
    }
}

struct CircleViews_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            VStack {
                ForEach(ThemeColor.prebuiltSet, id: \.self) { color in
                    CircleViews(color: color)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
            VStack {
                ForEach(ThemeColor.prebuiltSet, id: \.self) { color in
                    CircleViews(color: color)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
        }
    }
}
