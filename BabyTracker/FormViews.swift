//
//  FormViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/3/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Combine
import SwiftUI



struct EventFormView: View {
    var eventID: UUID?
    var eventType: BabyEventType
    var babyLog: BabyLog
    var didUpdate: (() -> Void)
    
    var body: some View {
        ZStack {
            if eventID != nil {
                editForm
            } else {
                newForm
            }
        }
    }
    
    var newForm: AnyView {
        switch eventType {
        case .feed:
            return BabyEventFormView<FeedEvent>(
                event: FeedEvent.new,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .fuss:
            return BabyEventFormView<FussEvent>(
                event: FussEvent.new,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .nap:
            return BabyEventFormView<NapEvent>(
                event: NapEvent.new,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .diaper:
            return BabyEventFormView<DiaperEvent>(
                event: DiaperEvent.new,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .weight:
            return BabyEventFormView<WeightEvent>(
                event: WeightEvent.new,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .tummyTime:
            return BabyEventFormView<TummyTimeEvent>(
                event: TummyTimeEvent.new,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .custom:
            return BabyEventFormView<CustomEvent>(
                event: CustomEvent.new,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        }
    }
    
    var editForm: AnyView {
        switch eventType {
        case .feed:
            return BabyEventFormView<FeedEvent>(
                eventID: self.eventID,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .fuss:
            return BabyEventFormView<FussEvent>(
                eventID: self.eventID,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .nap:
            return BabyEventFormView<NapEvent>(
                eventID: self.eventID,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .diaper:
            return BabyEventFormView<DiaperEvent>(
                eventID: self.eventID,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .weight:
            return BabyEventFormView<WeightEvent>(
                eventID: self.eventID,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .tummyTime:
            return BabyEventFormView<TummyTimeEvent>(
                eventID: self.eventID,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        case .custom:
            return BabyEventFormView<CustomEvent>(
                eventID: self.eventID,
                babyLog: babyLog,
                didUpdate: self.didUpdate).anyify()
        }
    }
}

struct BabyEventFormView<E: BabyEvent>: View {
    var eventID: UUID?
    @State var event: E?
    
    var babyLog: BabyLog
    
    @State var savedEvent: Bool = false
    
    @State var activeError: BabyError? = nil
    
    var didUpdate: (() -> Void)
    
    var body: some View {
        createEventForm()
            .onAppear(perform: {
                self.fetchEvent()
            })
            .onDisappear {
                self.didUpdate()
            }
//            .onTapGesture {
//                self.savedEvent = false
//            }
    }
    
    func createEventForm() -> AnyView {
        if let event = self.event as? CustomEvent {
            return StaticCustomFormView(
                apply: self.apply as? (CustomEvent) -> Void,
                id: event.id,
                date: event.date,
                eventText: event.event,
                details: "")
                .anyify()
        }
        if let event = self.event as? TummyTimeEvent {
            return StaticTummyTimeFormView(
                apply: self.apply as? (TummyTimeEvent) -> Void,
                id: event.id,
                date: event.date,
                endDate: event.date.addingTimeInterval(event.duration))
                .anyify()
        }
        if let event = self.event as? WeightEvent {
            let unit: StaticWeightFormView.Unit = event.weight.unit == UnitMass.kilograms ? .kilograms : .pounds
            let weightString = "\(event.weight.converted(to: unit.massUnit).value)"
            return StaticWeightFormView(
                apply: self.apply as? (WeightEvent) -> Void,
                id: event.id,
                date: event.date,
                weightString: weightString,
                unit: unit)
                .anyify()
        }
        if let event = self.event as? DiaperEvent {
            return StaticDiaperFormView(
                apply: self.apply as? (DiaperEvent) -> Void,
                id: event.id,
                date: event.date,
                pee: event.pee,
                poo: event.poop)
                .anyify()
        }
        if let event = self.event as? FeedEvent {
            let source = event.source
            let sourceType: StaticFeedFormView.SourceOption
            let side: BreastSide
            switch source {
            case .breast(let breastSide):
                sourceType = .breast
                side = breastSide
            case .bottle:
                sourceType = .bottle
                side = .both
            }
            var size: String = "4.0"
            if let measurement = event.size?.converted(to: .fluidOunces) {
                size = String(measurement.value)
            }
            
            return StaticFeedFormView(
                apply: self.apply as? (FeedEvent) -> Void,
                id: event.id,
                date: event.date,
                sourceType: sourceType,
                breastSide: side,
                ounces: size)
                .anyify()
        }
        if let event = self.event as? FussEvent {
            return StaticFussFormView(
                apply: self.apply as? (FussEvent) -> Void,
                id: event.id,
                date: event.date,
                endDate: event.date.addingTimeInterval(event.duration))
                .anyify()
        }
        if let event = self.event as? FussEvent {
            return StaticFussFormView(
                apply: self.apply as? (FussEvent) -> Void,
                id: event.id,
                date: event.date,
                endDate: event.date.addingTimeInterval(event.duration))
                .anyify()
        }
        if let event = self.event as? FussEvent {
            return StaticFussFormView(
                apply: self.apply as? (FussEvent) -> Void,
                id: event.id,
                date: event.date,
                endDate: event.date.addingTimeInterval(event.duration))
                .anyify()
        }
        if let event = self.event as? FussEvent {
            return StaticFussFormView(
                apply: self.apply as? (FussEvent) -> Void,
                id: event.id,
                date: event.date,
                endDate: event.date.addingTimeInterval(event.duration))
                .anyify()
        }
        if let event = self.event as? FussEvent {
            return StaticFussFormView(
                apply: self.apply as? (FussEvent) -> Void,
                id: event.id,
                date: event.date,
                endDate: event.date.addingTimeInterval(event.duration))
                .anyify()
        }
        if let event = self.event as? NapEvent {
            return StaticNapFormView(
                apply: self.apply as? (NapEvent) -> Void,
                id: event.id,
                date: event.date,
                endDate: event.date.addingTimeInterval(event.duration),
                interruptions: event.interruptions)
                .anyify()
        }
        return AnyView(Text("Loading"))
    }
    
    private func apply(_ event: E) {
        babyLog.save(event) { result in
            switch result {
            case .success(let newEvent):
                self.event = newEvent
                self.savedEvent = true
            case .failure(let error):
                self.activeError = error
            }
        }
    }
    
    private func fetchEvent() {
        guard let id = self.eventID else { return }
        babyLog.fetch(id) { (result: Result<E, BabyError>) in
            guard case let .success(event) = result else {
                // Failed to retrieve event
                return
            }
            self.event = event
        }
    }
}

struct StaticFussFormView: View {
    var apply: ((FussEvent) -> Void)?
    var event: FussEvent {
        get {
            return FussEvent(
                id: self.id,
                date: self.date,
                duration: self.endDate.timeIntervalSince(self.date))
        }
    }
    
    var id: UUID
    @State var date: Date = Date() {
        didSet {
            let oldDuration = endDate.timeIntervalSince(oldValue)
            endDate = date.addingTimeInterval(oldDuration)
        }
    }
    @State var endDate: Date = Date()
    
    var body: some View {
        Form {
            Section {
                DateTimePicker(date: $date)
                DateTimePicker(date: $endDate, text: "End Date")
            }
        }
        .navigationBarTitle(Text("Fuss Event"))
        .navigationBarItems(trailing: Button("Save", action: {
            self.apply?(self.event)
        }))
    }
}

struct DateTimePicker: View {
    
    /// State
    @Binding var date: Date
    
    /// Static
    var text: String = "Date"
    var showDate: Bool = true
    
    /// Computed
    
    private var pickerComponents: DatePickerComponents {
        if showDate { return [.date, .hourAndMinute] }
        return .hourAndMinute
    }
    
    /// View Constructors
    
    var body: some View {
        DatePicker(selection: $date,
                   displayedComponents: pickerComponents) {
            Text(text)
        }
    }
}

struct StaticNapFormView: View {
    var apply: ((NapEvent) -> Void)?
    var event: NapEvent {
        get {
            return NapEvent(
                id: self.id,
                date: self.date,
                duration: self.endDate.timeIntervalSince(self.date),
                interruptions: self.interruptions)
        }
    }
    
    var id: UUID
    @State var date: Date = Date()
    @State var endDate: Date = Date()
    
    @State var interruptions: Int = 0
    
    var body: some View {
        Form {
            Section {
                DateTimePicker(date: $date)
                DateTimePicker(date: $endDate, text: "End Date", showDate: false)
            }
            Section {
                Stepper(value: self.$interruptions, in: 0...10, step: 1) {
                    Text("Interruptions: \(self.interruptions)")
                }
            }
        }
        .navigationBarTitle(Text("Nap"))
        .navigationBarItems(trailing: Button("Save", action: {
            self.apply?(self.event)
        }))
    }
}

struct StaticFeedFormView: View {
    enum SourceOption: Hashable {
        case bottle
        case breast
    }
    
    var apply: ((FeedEvent) -> Void)?
    var event: FeedEvent {
        get {
            let source: FeedEvent.Source = {
                switch self.sourceType {
                case .bottle:
                    return .bottle
                case .breast:
                    return .breast(self.breastSide)
                }
            }()
            let size: Measurement<UnitVolume>? = {
                guard self.showMeasureSection else { return nil }
                return Measurement(value: self.ouncesDouble, unit: UnitVolume.fluidOunces)
            }()
            return FeedEvent(
                id: self.id,
                date: self.date,
                source: source,
                size: size)
        }
    }
    
    var id: UUID
    @State var date: Date = Date()
    @State var sourceType: SourceOption = .breast
    @State var breastSide: BreastSide = .both
    @State var ounces: String = "4.0"
    
    @State var measureBreastFeed: Bool = false
    
    var ouncesDouble: Double {
        guard let double = Double(ounces) else {
            return 0.0
        }
        return double
    }
    
    var showMeasureSection: Bool {
        switch sourceType {
        case .bottle:
            return true
        case .breast:
            return self.measureBreastFeed
        }
    }
    
    var body: some View {
        Form {
            Section {
                DateTimePicker(date: $date)
            }
            Section {
                Picker("Feed Source", selection: $sourceType) {
                    Text("Breast").tag(StaticFeedFormView.SourceOption.breast)
                    Text("Bottle").tag(StaticFeedFormView.SourceOption.bottle)
                }.pickerStyle(SegmentedPickerStyle())
                
                if sourceType == .breast {
                    Picker("Breast Sides", selection: $breastSide) {
                        Text("👈 Left").tag(BreastSide.left)
                        Text("Both").tag(BreastSide.both)
                        Text("Right 👉").tag(BreastSide.right)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    Toggle(isOn: $measureBreastFeed) {
                        Text("Measured")
                    }
                }
            }
            
            if showMeasureSection {
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
        }
        .navigationBarTitle(Text("Feed"))
        .navigationBarItems(trailing: Button("Save", action: {
            self.apply?(self.event)
        }))
    }
}

struct StaticDiaperFormView: View {
    var apply: ((DiaperEvent) -> Void)?
    var event: DiaperEvent {
        get {
            return DiaperEvent(
                id: self.id,
                date: self.date,
                pee: self.pee,
                poop: self.poo)
        }
    }
    
    var id: UUID
    @State var date: Date = Date()
    @State var pee: Bool = false
    @State var poo: Bool = false
    
    var body: some View {
        Form {
            Section {
                DateTimePicker(date: $date)
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
            self.apply?(self.event)
        }))
    }
}

struct StaticTummyTimeFormView: View {
    var apply: ((TummyTimeEvent) -> Void)?
    var event: TummyTimeEvent {
        get {
            return TummyTimeEvent(
                id: self.id,
                date: self.date,
                duration: self.endDate.timeIntervalSince(self.date))
        }
    }
    
    var id: UUID
    @State var date: Date = Date()
    @State var endDate: Date = Date()
    
    var body: some View {
        Form {
            Section {
                DateTimePicker(date: $date)
                DateTimePicker(date: $endDate, text: "End Date")
            }
        }
        .navigationBarTitle(Text("Tummy Time"))
        .navigationBarItems(trailing: Button("Save", action: {
            self.apply?(self.event)
        }))
    }
}

struct StaticWeightFormView: View {
    var apply: ((WeightEvent) -> Void)?
    var event: WeightEvent {
        get {
            let weight = Measurement(value: self.weightDouble, unit: self.unit.massUnit)
            return WeightEvent(
                id: self.id,
                date: self.date,
                weight: weight)
        }
    }
    
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
    
    var id: UUID
    @State var date: Date = Date()
    
    @State var weightString: String = "4.0"
    @State var unit: Unit = .kilograms
    
    var body: some View {
        Form {
            Section {
                DateTimePicker(date: $date)
            }
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
        }
        .navigationBarTitle(Text("Weigh In"))
        .navigationBarItems(trailing: Button("Save", action: {
            self.apply?(self.event)
        }))
    }
}

struct StaticCustomFormView: View {
    var apply: ((CustomEvent) -> Void)?
    var event: CustomEvent {
        get {
            return CustomEvent(
                id: self.id,
                date: self.date,
                event: self.eventText)
        }
    }
    
    var id: UUID
    @State var date: Date = Date()
    @State var eventText: String = ""
    @State var details: String = ""
    
    var body: some View {
        Form {
            Section {
                DateTimePicker(date: $date)
            }
            Section {
                TextField("Event", text: $eventText)
            }
//            Section {
//                TextField("Details", text: $details)
//            }
        }
        .navigationBarTitle(Text(eventText.isEmpty ? "Custom" : eventText))
        .navigationBarItems(trailing: Button("Save", action: {
            self.apply?(self.event)
        }))
    }
}

struct FormViews_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
