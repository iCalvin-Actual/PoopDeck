//
//  SwiftUIView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/6/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct FeedViewModel: Identifiable {
    var id: UUID
    var date: Date
    var type: BabyEventType
    
    var icon: Data?
    var primaryText: String
    var secondaryText: String
    var infoStack: [String]
}

struct FeedCard: View {
    var event: FeedViewModel
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Rectangle().frame(width: 10, height: 10, alignment: .center)
                    Text(event.primaryText)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                Spacer()
                Text(event.secondaryText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(UIColor.label))
            }
            .foregroundColor(color(for: event.type))
            Spacer()
            VStack {
                Text(DateFormatter.shortStackDisplay.string(from: event.date))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.trailing)
                Spacer()
            }
            
        }
        .padding(8)
    }
    
    func color(for type: BabyEventType) -> Color {
        return type.colorValue
    }
}

struct FeedCardView_Previews: PreviewProvider {
    static var feed: [FeedViewModel] = {
        var feed: [FeedViewModel] = []
        
        var components = DateComponents(year: 2020, month: 5, day: 9, hour: 3)
        components.hour = 3
        
        feed.append(FeedEvent(source: .bottle, size: Measurement(value: 4.0, unit: UnitVolume.fluidOunces)).viewModel)
        // 6:15
        feed.append(FeedEvent.init(source: .breast(.right), size: Measurement(value: 4, unit: UnitVolume.fluidOunces)).viewModel)
        // 9.15
        feed.append(FeedEvent.init(source: .breast(.right), size: Measurement(value: 4, unit: UnitVolume.fluidOunces)).viewModel)
        // 12:15
        feed.append(FeedEvent.init(source: .breast(.right), size: Measurement(value: 4, unit: UnitVolume.fluidOunces)).viewModel)
        // 3:30
        feed.append(FeedEvent.init(source: .breast(.right), size: Measurement(value: 4, unit: UnitVolume.fluidOunces)).viewModel)
        
        
        
        feed.append(FussEvent(duration: 450).viewModel)
        feed.append(NapEvent(duration: 600).viewModel)
        feed.append(FeedEvent(source: .bottle, size: Measurement(value: 3.5, unit: UnitVolume.fluidOunces)).viewModel)
        
        feed.append(FeedEvent.init(source: .breast(.right), size: Measurement(value: 4.2, unit: UnitVolume.fluidOunces)).viewModel)
        feed.append(DiaperEvent(pee: false, poop: true).viewModel)
        
        feed.append(CustomEvent(event: "Smiled!").viewModel)
        feed.append(WeightEvent(weight: .init(value: 5.42, unit: .kilograms)).viewModel)
        feed.append(TummyTimeEvent().viewModel)
        return feed
    }()
    static var previews: some View {
        FeedView(feed: feed)
    }
}
