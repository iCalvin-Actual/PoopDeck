//
//  FormViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/3/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

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
            return AnyView(FeedFormView(event: feedEvent))
        case .weight(let weightEvent):
            return AnyView(WeightFormView(event: weightEvent))
        case .diaper(let diaperEvent):
            return AnyView(DiaperFormView(event: diaperEvent))
        case .custom(let customEvent):
            return AnyView(CustomFormView(customEvent: customEvent))
        case .tummyTime(let tummyEvent):
            return AnyView(TummyTimeFormView(event: tummyEvent))
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
    @State var event: FeedEvent
    @State var sourceType: SourceFormViewType = .breast
    @State var breastSide: BreastSides = .both
    
    enum BreastSides: Hashable {
        case left
        case right
        case both
    }
    
    enum SourceFormViewType: Hashable {
        case bottle
        case breast
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $event.date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
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
                        Text("👈 Left").tag(BreastSides.left)
                        Text("Both").tag(BreastSides.both)
                        Text("Right 👉").tag(BreastSides.right)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            Section {
                HStack {
                    Text("Amount")
                    
                    TextField("42.0", value: $event.size.value, formatter: NumberFormatter.weightEntryFormatter)
                    
                    Text(MeasurementFormatter.weightFormatter.string(from: event.size.unit))
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
