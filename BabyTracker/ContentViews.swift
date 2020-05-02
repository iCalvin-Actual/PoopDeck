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
    var feed: [BabyEvent] = {
        var feed: [BabyEvent] = []
        feed.append(.fuss(FussEvent(duration: 450)))
        feed.append(.nap(NapEvent(duration: 600)))
        feed.append(.feed(FeedEvent(source: .bottle(size: Measurement(value: 3.0, unit: UnitVolume.fluidOunces)))))
        
        feed.append(.feed(FeedEvent(source: .breast(.init()))))
        
        feed.append(.custom(CustomEvent(event: "Smiled!")))
        feed.append(.tummyTime(TummyTimeEvent()))
        return feed
    }()
    public var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    ForEach(feed) { event in
                        NavigationLink(destination: EventFormView(event: event)) {
                            FeedCard(event: event)
                        }
                    }
                    Spacer()
                }.padding()
                    .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationBarTitle(Text("Sophia Events"))
        }
    }
    public init() {
    }
}

struct EventFormView: View {
    @State var event: BabyEvent
    var body: some View {
        cardContent
    }
    
    var cardContent: AnyView {
        switch event {
        case .fuss(let fussEvent):
            return AnyView(FussFormView(fussEvent: fussEvent))
        case .nap(let napEvent):
            return AnyView(NapFormView(napEvent: napEvent))
        case .feed(let feedEvent):
            return AnyView(FeedingView(event: feedEvent))
        case .weight(let weightEvent):
            return AnyView(WeightView(event: weightEvent))
        case .diaper(let diaperEvent):
            return AnyView(DiaperView(event: diaperEvent))
        case .custom(let customEvent):
            return AnyView(CustomFormView(customEvent: customEvent))
        case .tummyTime(let tummyEvent):
            return AnyView(TummyTimeFormView(event: tummyEvent))
        }
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

struct FussFormView: View {
    @State var fussEvent: FussEvent
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $fussEvent.date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
                Stepper(value: $fussEvent.duration, in: 150.0...3600.0, step: 150.0) {
                    Text("Duration: \(DateComponentsFormatter.durationDisplay.string(from: DateComponents(second: Int(fussEvent.duration))) ?? "0")")
                }
            }
        }
        .navigationBarTitle(Text("Fuss Event"))
        .navigationBarItems(trailing: Button("Save", action: {
            print("Save")
        }
        ))
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

struct NapFormView: View {
    @State var napEvent: NapEvent
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $napEvent.date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
                Stepper(value: $napEvent.duration, in: 150.0...3600.0, step: 150.0) {
                    Text("Duration: \(DateComponentsFormatter.durationDisplay.string(from: DateComponents(second: Int(napEvent.duration))) ?? "0")")
                }
            }
            Section {
                Stepper(value: $napEvent.interruptions, in: 0...10, step: 1) {
                    Text("Interruptions: \(napEvent.interruptions)")
                }
                Toggle(isOn: $napEvent.held) {
                    Text("Held")
                }
            }
        }
        .navigationBarTitle(Text("Nap"))
        .navigationBarItems(trailing: Button("Save", action: {
            print("Save")
        }
        ))
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
        case .bottle(size: let size):
            return AnyView(BottleFeedingView(size: size))
            case .breast(let breastFeed):
            return AnyView(BreastFeedingView(feed: breastFeed))
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
    let feed: FeedEvent.Source.BreastFeedEvent
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

struct TummyTimeFormView: View {
    @State var event: TummyTimeEvent
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $event.date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
                Stepper(value: $event.duration, in: 150.0...3600.0, step: 150.0) {
                    Text("Duration: \(DateComponentsFormatter.durationDisplay.string(from: DateComponents(second: Int(event.duration))) ?? "0")")
                }
            }
        }
        .navigationBarTitle(Text("Tummy Time"))
        .navigationBarItems(trailing: Button("Save", action: {
            print("Save")
        }
        ))
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
            Text("Weigh In: \(event.weight)")
            Spacer()
            TimeDurationView(startDate: event.date, duration: nil)
        }
    }
}

struct WeightFormView: View {
    @State var event: WeightEvent
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Weight")
                    WeightFieldView(weightText: Binding.constant(""))
                }
            }
            Section {
                DatePicker(selection: $event.date, displayedComponents: DatePickerComponents([DatePickerComponents.date, DatePickerComponents.hourAndMinute])) {
                    Text("Date")
                }
            }
        }
    }
    
    struct WeightFieldView: View {
        @Binding var weightText: String
        var body: some View {
            TextField("Weight: ", text: $weightText).keyboardType(.numberPad)
        }
    }
}


