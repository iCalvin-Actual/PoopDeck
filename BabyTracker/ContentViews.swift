//
//  ContentViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct TimeDurationView: View {
    let startDate: Date
    let duration: TimeInterval?
    var body: some View {
        VStack {
            Text(DateFormatter.timeDisplay.string(from: startDate))
            if duration ?? 0 > 0 {
                Text(DateComponentsFormatter.durationDisplay.string(from: duration ?? 0) ?? "")
            }
        }
    }
}

public struct FeedView: View {
    @State var feed: [BabyEvent] = {
        var feed: [BabyEvent] = []
        feed.append(.fuss(FussEvent(duration: 450)))
        feed.append(.nap(NapEvent(duration: 600)))
        feed.append(.feed(FeedEvent(source: .bottle, size: Measurement(value: 3.5, unit: UnitVolume.fluidOunces))))
        
        feed.append(.feed(FeedEvent.init(source: .breast(.right), size: Measurement(value: 4.2, unit: UnitVolume.fluidOunces))))
        feed.append(.diaper(DiaperEvent(pee: false, poop: true)))
        
        feed.append(.custom(CustomEvent(event: "Smiled!")))
        feed.append(.weight(WeightEvent(weight: .init(value: 5.42, unit: .kilograms))))
        feed.append(.tummyTime(TummyTimeEvent()))
        return feed
    }()
    @State var showDetail: Bool = false
    public var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ForEach(feed) { event in
                    NavigationLink(destination: EventFormView(event: event), isActive: self.$showDetail) {
                        FeedCard(event: event) .contextMenu {
                           Button(action: {
                               // Delete event
                            guard let index = self.feed.firstIndex(where: { feedEvent in
                                switch (event, feedEvent) {
                                case (.feed(let eventA), .feed(let eventB)):
                                    return eventA == eventB
                                case (.diaper(let eventA), .diaper(let eventB)):
                                    return eventA == eventB
                                case (.nap(let eventA), .nap(let eventB)):
                                    return eventA == eventB
                                case (.fuss(let eventA), .fuss(let eventB)):
                                    return eventA == eventB
                                case (.weight(let eventA), .weight(let eventB)):
                                    return eventA == eventB
                                case (.tummyTime(let eventA), .tummyTime(let eventB)):
                                    return eventA == eventB
                                case (.custom(let eventA), .custom(let eventB)):
                                    return eventA == eventB
                                default:
                                    return false
                                }
                                
                            }) else {
                                return
                            }
                            self.feed.remove(at: index)
                           }) {
                               Text("Delete")
                               Image(systemName: "trash.circle.fill")
                           }

                            Button(action: {
                                // Do nothing?
                                print(event)
                            }) {
                                Text("Edit")
                                Image(systemName: "pencil.circle.fill")
                            }
                       }
                    }
                }.padding()
                    .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationBarTitle(Text("Sophia Events"))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    public init() {
    }
}

struct FeedCard: View {
    var event: BabyEvent
    var body: some View {
        cardContent
        .padding()
            .background(Color(UIColor.systemBackground))
    }
    
    var cardContent: AnyView {
        switch event {
            case .fuss(let fussEvent):
            return AnyView(FussView(event: fussEvent))
            case .nap(let napEvent):
            return AnyView(NapView(event: napEvent))
            case .feed(let feedEvent):
            return AnyView(FeedingView(event: feedEvent))
            case .weight(let weightEvent):
            return AnyView(WeightView(event: weightEvent))
            case .diaper(let diaperEvent):
            return AnyView(DiaperView(event: diaperEvent))
            case .custom(let customEvent):
            return AnyView(CustomEventView(event: customEvent))
            case .tummyTime(let tummyEvent):
            return AnyView(TummyTimeView(event: tummyEvent))
        }
    }
}

struct FussView: View {
    var event: FussEvent
    var body: some View {
        HStack {
            Text("Fuss")
            Spacer()
            TimeDurationView(startDate: event.date, duration: event.duration)
        }
    }
}

struct NapView: View {
    let event: NapEvent
    var body: some View {
        HStack {
            if event.held {
                Text("Nap in arms")
            } else {
                Text("Nap in crib")
            }
            Spacer()
            TimeDurationView(startDate: event.date, duration: event.duration)
        }
    }
}

struct FeedingView: View {
    let event: FeedEvent
    var body: some View {
        HStack {
            self.feedingView
            Spacer()
            Text(DateFormatter.timeDisplay.string(from: event.date))
        }
    }
    
    var feedingView: AnyView {
        switch event.source {
        case .bottle:
            return AnyView(BottleFeedingView(size: event.size))
            case .breast(let sides):
                return AnyView(BreastFeedingView(size: event.size, side: sides))
        }
    }
}

struct BottleFeedingView: View {
    let size: Measurement<UnitVolume>
    var body: some View {
        Text("Bottle Feeding ()")
    }
}

struct BreastFeedingView: View {
    let size: Measurement<UnitVolume>
    let side: FeedEvent.Source.BreastSide
    var body: some View {
        Text("Breast Feed ()")
    }
}

struct DiaperView: View {
    let event: DiaperEvent
    var body: some View {
        HStack {
            Text("Diaper")
            if event.pee {
                Text("💦")
            }
            if event.poop {
                Text("💩")
            }
            Spacer()
            TimeDurationView(startDate: event.date, duration: nil)
        }
    }
}

struct TummyTimeView: View {
    let event: TummyTimeEvent
    var body: some View {
        HStack {
            Text("Tummy Time")
            Spacer()
            TimeDurationView(startDate: event.date, duration: event.duration)
        }
    }
}

struct CustomEventView: View {
    let event: CustomEvent
    var body: some View {
        HStack {
            Text(event.event)
            Spacer()
            TimeDurationView(startDate: event.date, duration: nil)
        }
    }
}

struct CustomFormView: View {
    @State var customEvent: CustomEvent = .init(event: "")
    var body: some View {
        Form {
            Section {
                TextField("Event", text: $customEvent.event)
            }
            Section {
                DatePicker(selection: $customEvent.date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
            }
        }.navigationBarTitle(Text("Custom Event"))
        .navigationBarItems(trailing: Button("Save", action: {
            print("Save")
        })
        )
    }
}

struct WeightView: View {
    let event: WeightEvent
    var body: some View {
        HStack {
            Text("Weight Check -  \(MeasurementFormatter.weightFormatter.string(from: event.weight))")
            Spacer()
            TimeDurationView(startDate: event.date, duration: nil)
        }
    }
}


