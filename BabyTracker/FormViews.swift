//
//  FormViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/3/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct EventFormView: View {
    var eventType: BabyEventType
    var eventID: UUID?
    
    var body: some View {
        cardContent
    }
    
    var cardContent: AnyView {
        switch eventType {
        case .feed:
            return AnyView(FeedFormView(eventID))
        default:
            return AnyView(EmptyView())
        }
    }
//        case .fuss:
//            return AnyView(FussFormView(fussEvent: fussEvent))
//        case .nap:
//            return AnyView(NapFormView(napEvent: napEvent))
//        case .feed:
//            return AnyView(FeedFormView(event: feedEvent))
//        case .weight:
//            return AnyView(WeightFormView(event: weightEvent))
//        case .diaper:
//            return AnyView(DiaperFormView(event: diaperEvent))
//        case .custom:
//            return AnyView(CustomFormView(customEvent: customEvent))
//        case .tummyTime:
//            return AnyView(TummyTimeFormView(event: tummyEvent))
//        }
//    }
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

struct FeedFormView: View {
    var id: UUID?
    
    @State var date: Date = Date()
    @State var sourceType: SourceFormViewType = .breast
    @State var breastSide: BreastSide = .both
    
    enum SourceFormViewType: Hashable {
        case bottle
        case breast
    }
    
    init(_ event: FeedEvent) {
        self.id = event.id
        self.configure(with: event)
    }
    
    init(_ id: UUID?) {
        self.id = id
        if let id = id {
            self.fetchEvent(with: id)
        } else {
            // New event, do nothing?
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchFeedEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
//            self.id = event.id
            self.date = event.date
            switch event.source {
            case .bottle:
                self.sourceType = .bottle
            case .breast(let side):
                self.sourceType = .breast
                self.breastSide = side
            }
        }
    }
    
    private mutating func configure(with event: FeedEvent) {
        self.id = event.id
        self.date = event.date
        switch event.source {
        case .bottle:
            sourceType = .bottle
        case .breast(let side):
            sourceType = .breast
            breastSide = side
        }
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
            }
            Section {
                Picker("Feed Source", selection: $sourceType) {
                    Text("Breast").tag(SourceFormViewType.breast)
                    Text("Bottle").tag(SourceFormViewType.bottle)
                }.pickerStyle(SegmentedPickerStyle())
                
                if sourceType == .breast {
                    Picker("Breast Sides", selection: $breastSide) {
                        Text("👈 Left").tag(BreastSide.left)
                        Text("Both").tag(BreastSide.both)
                        Text("Right 👉").tag(BreastSide.right)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .navigationBarTitle(Text("Feed"))
        .navigationBarItems(trailing: Button("Save", action: {
            print("Save")
        }
        ))
    }
}



struct DiaperFormView: View {
    @State var event: DiaperEvent
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $event.date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
            }
            Section {
                Toggle(isOn: $event.pee, label: {
                    Text("Pee 💦")
                })
                Toggle(isOn: $event.poop, label: {
                    Text("Poop 💩")
                })
            }
        }
        .navigationBarTitle(Text("Diaper Change"))
        .navigationBarItems(trailing: Button("Save", action: {
            print("Save")
        }
        ))
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
                Stepper(value: $event.duration, in: 60.0...3600.0, step: 60.0) {
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

struct WeightFormView: View {
    @State var event: WeightEvent
    
    var toggleUnit: UnitMass {
        if self.event.weight.unit == UnitMass.kilograms {
            return .pounds
        }
        return .kilograms
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Weight")
                    
                    TextField("42.0", value: $event.weight.value, formatter: NumberFormatter.weightEntryFormatter)
//                        .keyboardType(.decimalPad)
                    
                    Text(MeasurementFormatter.weightFormatter.string(from: event.weight.unit))
                }
            }
            Section {
                DatePicker(selection: $event.date, displayedComponents: DatePickerComponents([DatePickerComponents.date, DatePickerComponents.hourAndMinute])) {
                    Text("Date")
                }
            }
        }
        .navigationBarTitle(Text("Weight"))
        .navigationBarItems(trailing: Button("Save", action: {
            print("Save")
        }
        ))
    }
}
