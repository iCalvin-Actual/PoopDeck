//
//  FormViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/3/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Combine
import SwiftUI

protocol EventForm: View {
    var id: UUID? { get }
    var onSave: (() -> Void) { get }
    
    func fetchEvent()
}

struct EventFormView: View {
    var eventType: BabyEventType
    var eventID: UUID?
    var didUpdate: (() -> Void)
    
    var body: some View {
        cardContent
            .onDisappear {
                self.didUpdate()
            }
    }
    
    var cardContent: AnyView {
        switch eventType {
        case .feed:
            return AnyView(FeedFormView(id: eventID))
        case .fuss:
            return AnyView(FussFormView(id: eventID))
        case .nap:
            return AnyView(NapFormView(id: eventID))
        case .diaper:
            return AnyView(DiaperFormView(id: eventID))
        case .weight:
            return AnyView(WeightFormView(id: eventID))
        case .tummyTime:
            return AnyView(TummyTimeFormView(id: eventID))
        case .custom:
            return AnyView(CustomFormView(id: eventID))
        }
    }
}

struct AltEventFormView<E: BabyEvent>: View {
    var eventID: UUID?
    var didUpdate: (() -> Void)
    
    @State var event: E?
    
    
    var body: some View {
        Text("Hello")
            .onAppear(perform: {
                self.fetchEvent()
            })
            .onDisappear {
                self.didUpdate()
            }
    }
    
    func createEventForm() -> AnyView {
        switch self.event?.type {
        case .feed:
            return AnyView(FeedFormView(id: eventID))
        case .fuss:
            return AnyView(FussFormView(id: eventID))
        case .nap:
            return AnyView(NapFormView(id: eventID))
        case .diaper:
            return AnyView(DiaperFormView(id: eventID))
        case .weight:
            return AnyView(WeightFormView(id: eventID))
        case .tummyTime:
            return AnyView(TummyTimeFormView(id: eventID))
        case .custom:
            return AnyView(CustomFormView(id: eventID))
        case .none:
            return AnyView(Text("Loading..."))
        }
    }
    
    private func fetchEvent() {
        guard let id = self.eventID else { return }
        EventManager.shared.fetch(id: id, type: self.event!.type) { (result: Result<E, BabyError>) in
            guard case let .success(event) = result else {
                // Failed to retrieve event
                return
            }
            self.event = event
        }
    }
}

struct FussFormView: View {
    var id: UUID?
    @State var date: Date = Date()
    @State var duration: Double = 300
    
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
                Stepper(value: $duration, in: 150.0...3600.0, step: 150.0) {
                    Text("Duration: \(DateComponentsFormatter.durationDisplay.string(from: DateComponents(second: Int(duration))) ?? "0")")
                }
            }
        }
        .navigationBarTitle(Text("Fuss Event"))
        .navigationBarItems(trailing: Button("Save", action: {
            
            var event = FussEvent(date: self.date, duration: self.duration)
            if let id = self.id {
                event.id = id
            }
            if self.id != nil {
                EventManager.shared.updateFussEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            } else {
                EventManager.shared.addFussEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            }
        }
        ))
        .onAppear {
            guard let id = self.id else { return }
            self.fetchEvent(with: id)
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchFussEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
            self.date = event.date
            self.duration = event.duration
        }
    }
}

let defaultNapDuration: Double = 3600
struct NapFormView: View {
    var id: UUID?
    
    @State var date: Date = Date()
    @State var endDate: Date = Date(timeIntervalSinceNow: defaultNapDuration)
    
    var duration: Double { return endDate.timeIntervalSince(date) }
    
    @State var interruptions: Int = 0
    @State var held: Bool = false
    var body: some View {
        Form {
            Section {
                DatePicker(selection: self.$date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
                DatePicker(selection: self.$endDate, displayedComponents: DatePickerComponents([.hourAndMinute])) {
                    Text("End Time")
                }
            }
            Section {
                Stepper(value: self.$interruptions, in: 0...10, step: 1) {
                    Text("Interruptions: \(self.interruptions)")
                }
            }
        }
        .navigationBarTitle(Text("Nap"))
        .navigationBarItems(trailing: Button("Save", action: {
            var event = NapEvent(date: self.date, duration: self.duration, interruptions: self.interruptions)
            if let id = self.id {
                event.id = id
            }
            if self.id != nil {
                EventManager.shared.updateNapEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            } else {
                EventManager.shared.addNapEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            }
        }
        ))
        .onAppear {
            guard let id = self.id else { return }
            self.fetchEvent(with: id)
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchNapEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
            self.date = event.date
            self.endDate = event.date.addingTimeInterval(event.duration)
            self.interruptions = event.interruptions
        }
    }
}

struct FeedFormView: View {
    
    enum SourceOption: Hashable {
        case bottle
        case breast
    }
    
    var id: UUID?
    @State var date: Date = Date()
    @State var sourceType: SourceOption = .breast
    @State var breastSide: BreastSide = .both
    @State var ounces: String = "4.0"
    
    var ouncesDouble: Double {
        guard let double = Double(ounces) else {
            return 0.0
        }
        return double
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
                    Text("Breast").tag(FeedFormView.SourceOption.breast)
                    Text("Bottle").tag(FeedFormView.SourceOption.bottle)
                }.pickerStyle(SegmentedPickerStyle())
                
                if sourceType == .breast {
                    Picker("Breast Sides", selection: $breastSide) {
                        Text("👈 Left").tag(BreastSide.left)
                        Text("Both").tag(BreastSide.both)
                        Text("Right 👉").tag(BreastSide.right)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            Section {
                HStack {
                    Text("Size (fl oz)")
                    TextField("Size", text: $ounces)
                        .keyboardType(.decimalPad)
                        .onReceive(Just(ounces)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.ounces = filtered
                            }
                        }
                }
            }
        }
        .navigationBarTitle(Text("Feed"))
        .navigationBarItems(trailing: Button("Save", action: {
            let source: FeedEvent.Source = {
                switch self.sourceType {
                case .bottle:
                    return .bottle
                case .breast:
                    return .breast(self.breastSide)
                }
            }()
            var event = FeedEvent(source: source)
            if let id = self.id {
                event.id = id
            }
            event.date = self.date
            event.size = Measurement(value: self.ouncesDouble, unit: UnitVolume.fluidOunces)
            if self.id != nil {
                EventManager.shared.updateFeedEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            } else {
                EventManager.shared.addFeedEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            }
        }
        ))
        .onAppear {
            guard let id = self.id else { return }
            self.fetchEvent(with: id)
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchFeedEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
            self.date = event.date
            switch event.source {
            case .bottle:
                self.sourceType = .bottle
                self.breastSide = .both
            case .breast(let side):
                self.sourceType = .breast
                self.breastSide = side
            }
        }
    }
}



struct DiaperFormView: View {
    var id: UUID?
    @State var date: Date = Date()
    @State var pee: Bool = false
    @State var poo: Bool = false
    
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
            }
            Section {
                Toggle(isOn: $pee, label: {
                    Text("Pee 💦")
                })
                Toggle(isOn: $poo, label: {
                    Text("Poop 💩")
                })
            }
        }
        .navigationBarTitle(Text("Diaper Change"))
        .navigationBarItems(trailing: Button("Save", action: {
            var event = DiaperEvent(date: self.date, pee: self.pee, poop: self.poo)
            if let id = self.id {
                event.id = id
            }
            if self.id != nil {
                EventManager.shared.updateDiaperEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            } else {
                EventManager.shared.addDiaperEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            }
        }
        ))
        .onAppear {
            guard let id = self.id else { return }
            self.fetchEvent(with: id)
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchDiaperEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
            self.date = event.date
            self.pee = event.pee
            self.poo = event.poop
        }
    }
}

struct TummyTimeFormView: View {
    var id: UUID?
    @State var date: Date = Date()
    @State var duration: Double = 300
    var body: some View {
        Form {
            Section {
                DatePicker(selection: self.$date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
                Stepper(value: $duration, in: 60.0...3600.0, step: 60.0) {
                    Text("Duration: \(DateComponentsFormatter.durationDisplay.string(from: DateComponents(second: Int(duration))) ?? "0")")
                }
            }
        }
        .navigationBarTitle(Text("Tummy Time"))
        .navigationBarItems(trailing: Button("Save", action: {
            var event = TummyTimeEvent(date: self.date, duration: self.duration)
            if let id = self.id {
                event.id = id
            }
            if self.id != nil {
                EventManager.shared.updateTummyTimeEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            } else {
                EventManager.shared.addTummyTimeEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            }
        }
        ))
        .onAppear {
            guard let id = self.id else { return }
            self.fetchEvent(with: id)
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchTummyTimeEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
            self.date = event.date
            self.duration = event.duration
        }
    }
}

struct WeightFormView: View {
    var id: UUID?
    @State var date: Date = Date()
    
    @State var weightString: String = "4.0"
    @State var unit: Unit = .kilograms
    
    var weightDouble: Double {
        guard let double = Double(weightString) else {
            return 0.0
        }
        return double
    }
    
    enum Unit: String {
        case kilograms = "kg"
        case pounds = "lb"
        
        var massUnit: UnitMass {
            switch self {
            case .kilograms:    return .kilograms
            case .pounds:       return .pounds
            }
        }
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Weight")
                    
                    TextField("42.0", text: $weightString)
                        .keyboardType(.decimalPad)
                        .onReceive(Just(weightString)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.weightString = filtered
                            }
                        }
                    
                    Text(MeasurementFormatter.weightFormatter.string(from: self.unit.massUnit))
                }
                
                Picker(selection: $unit, label: Text("Unit")) {
                    Text(Unit.kilograms.rawValue).tag(Unit.kilograms)
                    Text(Unit.pounds.rawValue).tag(Unit.pounds)
                }.pickerStyle(SegmentedPickerStyle())
                
            }
            Section {
                DatePicker(selection: $date, displayedComponents: DatePickerComponents([DatePickerComponents.date, DatePickerComponents.hourAndMinute])) {
                    Text("Date")
                }
            }
        }
        .navigationBarTitle(Text("Weight"))
        .navigationBarItems(trailing: Button("Save", action: {
            let weight = Measurement(value: self.weightDouble, unit: self.unit.massUnit)
            var event = WeightEvent(date: self.date, weight: weight)
            if let id = self.id {
                event.id = id
            }
            if self.id != nil {
                EventManager.shared.updateWeightEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            } else {
                EventManager.shared.addWeightEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            }
        }
        ))
        .onAppear {
            guard let id = self.id else { return }
            self.fetchEvent(with: id)
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchWeightEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
            self.date = event.date
            self.unit = event.weight.unit == UnitMass.kilograms ? .kilograms : .pounds
            self.weightString = "\(event.weight.converted(to: self.unit.massUnit).value)"
        }
    }
}

struct CustomFormView: View {
    var id: UUID?
    @State var date: Date = Date()
    @State var event: String = ""
    @State var details: String = "Some really really unreasonably long text thtat would in no circumstances fit on a single line"
    
    var body: some View {
        Form {
            Section {
                DatePicker(selection: $date, displayedComponents: DatePickerComponents([.date, .hourAndMinute])) {
                    Text("Date")
                }
            }
            Section {
                TextField("Event", text: $event)
            }
            Section {
                TextField("Details", text: $details)
                .lineLimit(0)
            }
        }
        .navigationBarTitle(Text("Custom Event"))
        .navigationBarItems(trailing: Button("Save", action: {
            
            var event = CustomEvent(date: self.date, event: self.event)
            if let id = self.id {
                event.id = id
            }
            if self.id != nil {
                EventManager.shared.updateCustomEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            } else {
                EventManager.shared.addCustomEvent(event) { (event) in
                    // Feedback
                    print("")
                }
            }
        }
        ))
        .onAppear {
            guard let id = self.id else { return }
            self.fetchEvent(with: id)
        }
    }
    
    private func fetchEvent(with id: UUID) {
        EventManager.shared.fetchCustomEvent(id) { event in
            guard let event = event else {
                // Failed to retrieve event
                return
            }
            self.date = event.date
            self.event = event.event
        }
    }
}
