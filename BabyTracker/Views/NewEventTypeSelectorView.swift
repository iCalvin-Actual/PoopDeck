//
//  ContentViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct NewEventTypeSelectorView: View {
    let didSelect: ((BabyEventType) -> Void)?
    
    @State var selected: BabyEventType = .feed
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 2) {
                NewEventButton(type: .feed, didSelect: self.didSelect)
                NewEventButton(type: .diaper, didSelect: self.didSelect)
                NewEventButton(type: .nap, didSelect: self.didSelect)
                NewEventButton(type: .tummyTime, didSelect: self.didSelect)
                NewEventButton(type: .weight, didSelect: self.didSelect)
                NewEventButton(type: .fuss, didSelect: self.didSelect)
                NewEventButton(type: .custom, didSelect: self.didSelect)
            }
        }
    }
}

struct NewEventButton: View {
    let type: BabyEventType
    let didSelect: ((BabyEventType) -> Void)?
    
    var body: some View {
        Button(action: {
            self.didSelect?(self.type)
        }) {
            ZStack {
                Circle()
                    .foregroundColor(type.colorValue)
                
                Text(type.emojiValue)
                    .font(.largeTitle)
            }
            .frame(width: 88.0, height: 88.0)
        }
    }
}

struct NewEventTypeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventTypeSelectorView(didSelect: nil)
    }
}
